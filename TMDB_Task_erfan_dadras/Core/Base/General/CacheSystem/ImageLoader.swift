//
//  ImageLoader.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation
import UIKit
import Combine

/// Observable image loader that handles downloading and caching images
final class ImageLoader: ObservableObject {
    
    // MARK: - Published Properties
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Private Properties
    private let cache = ImageCache.shared
    private var cancellables = Set<AnyCancellable>()
    private let session = URLSession.shared
    
    // MARK: - Public Methods
    
    /// Loads an image from URL with caching support
    /// - Parameter url: The URL to load the image from
    func loadImage(from url: URL) {
        let urlString = url.absoluteString
        
        // Check cache first
        if let cachedImage = cache.image(for: urlString) {
            self.image = cachedImage
            self.isLoading = false
            self.error = nil
            return
        }
        
        // Start loading
        isLoading = true
        error = nil
        
        // Download image
        session.dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.error = error
                        Logger.log(.error, "Failed to load image from \(url): \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] downloadedImage in
                    self?.image = downloadedImage
                    self?.cache.setImage(downloadedImage, for: urlString)
                    Logger.log(.success, "Image loaded and cached from: \(url)")
                }
            )
            .store(in: &cancellables)
    }
    
    /// Cancels any ongoing image loading
    func cancel() {
        cancellables.removeAll()
        isLoading = false
    }
    
    /// Resets the loader state
    func reset() {
        cancel()
        image = nil
        error = nil
    }
}