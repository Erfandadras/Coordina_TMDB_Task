//
//  ImageCache.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation
import UIKit
import CryptoKit

/// Thread-safe image caching system for efficient image loading and storage
final class ImageCache {
    
    // MARK: - Singleton
    static let shared = ImageCache()
    
    // MARK: - Properties
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let diskQueue = DispatchQueue(label: "ImageCache.disk", qos: .utility)
    
    // MARK: - Configuration
    private let maxMemoryCacheSize: Int = 100 * 1024 * 1024 // 100 MB
    private let maxDiskCacheSize: Int = 500 * 1024 * 1024   // 500 MB
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    
    // MARK: - Initialization
    private init() {
        // Setup cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure memory cache
        cache.totalCostLimit = maxMemoryCacheSize
        cache.countLimit = 200 // Maximum number of images in memory
        
        // Setup cache cleanup observers
        setupNotifications()
        
        Logger.log(.info, "ImageCache initialized with directory: \(cacheDirectory.path)")
    }
    
    // MARK: - Public Methods
    
    /// Retrieves an image from cache (memory first, then disk)
    /// - Parameter key: Unique identifier for the image
    /// - Returns: Cached image if found, nil otherwise
    func image(for key: String) -> UIImage? {
        let cacheKey = NSString(string: key)
        
        // Check memory cache first
        if let memoryImage = cache.object(forKey: cacheKey) {
            Logger.log(.info, "Image found in memory cache for key: \(key)")
            return memoryImage
        }
        
        // Check disk cache
        let diskImage = diskImage(for: key)
        if let diskImage = diskImage {
            // Store back in memory cache for faster access
            cache.setObject(diskImage, forKey: cacheKey, cost: diskImage.memoryCost)
            Logger.log(.info, "Image found in disk cache for key: \(key)")
        }
        
        return diskImage
    }
    
    /// Stores an image in both memory and disk cache
    /// - Parameters:
    ///   - image: The image to cache
    ///   - key: Unique identifier for the image
    func setImage(_ image: UIImage, for key: String) {
        let cacheKey = NSString(string: key)
        
        // Store in memory cache
        cache.setObject(image, forKey: cacheKey, cost: image.memoryCost)
        
        // Store in disk cache asynchronously
        diskQueue.async { [weak self] in
            self?.setDiskImage(image, for: key)
        }
        
        Logger.log(.info, "Image cached for key: \(key)")
    }
    
    /// Removes an image from both memory and disk cache
    /// - Parameter key: Unique identifier for the image
    func removeImage(for key: String) {
        let cacheKey = NSString(string: key)
        
        // Remove from memory cache
        cache.removeObject(forKey: cacheKey)
        
        // Remove from disk cache
        diskQueue.async { [weak self] in
            self?.removeDiskImage(for: key)
        }
        
        Logger.log(.info, "Image removed from cache for key: \(key)")
    }
    
    /// Clears all cached images from memory and disk
    func clearCache() {
        // Clear memory cache
        cache.removeAllObjects()
        
        // Clear disk cache
        diskQueue.async { [weak self] in
            self?.clearDiskCache()
        }
        
        Logger.log(.info, "All cached images cleared")
    }
    
    /// Returns the current cache size information
    /// - Parameter completion: Closure called with cache size info
    func getCacheSize(completion: @escaping (CacheSizeInfo) -> Void) {
        diskQueue.async { [weak self] in
            guard let self = self else { return }
            
            let diskSize = self.calculateDiskCacheSize()
            let memorySize = self.cache.totalCostLimit
            
            let sizeInfo = CacheSizeInfo(
                memorySize: memorySize,
                diskSize: diskSize,
                totalSize: memorySize + diskSize
            )
            
            DispatchQueue.main.async {
                completion(sizeInfo)
            }
        }
    }
}

// MARK: - Private Methods
private extension ImageCache {
    
    /// Sets up notification observers for cache management
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppTermination),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc func handleMemoryWarning() {
        cache.removeAllObjects()
        Logger.log(.warning, "Memory cache cleared due to memory warning")
    }
    
    @objc func handleAppTermination() {
        cleanupExpiredCache()
    }
    
    @objc func handleAppBackground() {
        diskQueue.async { [weak self] in
            self?.cleanupExpiredCache()
        }
    }
    
    /// Generates file URL for disk cache
    func diskCacheURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }
    
    /// Retrieves image from disk cache
    func diskImage(for key: String) -> UIImage? {
        let url = diskCacheURL(for: key)
        
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // Update file access date
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
        
        return image
    }
    
    /// Stores image to disk cache
    func setDiskImage(_ image: UIImage, for key: String) {
        let url = diskCacheURL(for: key)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            Logger.log(.error, "Failed to convert image to data for key: \(key)")
            return
        }
        
        do {
            try data.write(to: url)
            Logger.log(.info, "Image saved to disk for key: \(key)")
        } catch {
            Logger.log(.error, "Failed to save image to disk: \(error.localizedDescription)")
        }
    }
    
    /// Removes image from disk cache
    func removeDiskImage(for key: String) {
        let url = diskCacheURL(for: key)
        try? fileManager.removeItem(at: url)
    }
    
    /// Clears all disk cache
    func clearDiskCache() {
        guard let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for url in contents {
            try? fileManager.removeItem(at: url)
        }
        
        Logger.log(.info, "Disk cache cleared")
    }
    
    /// Calculates total disk cache size
    func calculateDiskCacheSize() -> Int {
        guard let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        return contents.reduce(0) { total, url in
            let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + fileSize
        }
    }
    
    /// Removes expired cache files
    func cleanupExpiredCache() {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else {
            return
        }
        
        let cutoffDate = Date().addingTimeInterval(-maxCacheAge)
        var removedCount = 0
        
        for url in contents {
            guard let resourceValues = try? url.resourceValues(forKeys: [.contentModificationDateKey]),
                  let modificationDate = resourceValues.contentModificationDate else {
                continue
            }
            
            if modificationDate < cutoffDate {
                try? fileManager.removeItem(at: url)
                removedCount += 1
            }
        }
        
        Logger.log(.info, "Cleanup completed: removed \(removedCount) expired cache files")
    }
}

// MARK: - Supporting Types
struct CacheSizeInfo {
    let memorySize: Int
    let diskSize: Int
    let totalSize: Int
    
    var formattedMemorySize: String {
        ByteCountFormatter.string(fromByteCount: Int64(memorySize), countStyle: .memory)
    }
    
    var formattedDiskSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(diskSize), countStyle: .file)
    }
    
    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
    }
}

// MARK: - UIImage Extension
private extension UIImage {
    /// Calculates approximate memory cost of the image
    var memoryCost: Int {
        guard let cgImage = self.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
