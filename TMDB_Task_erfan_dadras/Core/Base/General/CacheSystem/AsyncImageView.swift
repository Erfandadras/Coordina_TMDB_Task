//
//  AsyncImageView.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import SwiftUI

/// SwiftUI view for loading and displaying images asynchronously with caching
struct AsyncImageView: View {
    
    // MARK: - Properties
    let url: URL?
    let placeholder: AnyView?
    let contentMode: ContentMode
    
    @StateObject private var imageLoader = ImageLoader()
    
    // MARK: - Initializers
    
    /// Creates an async image view with a custom placeholder
    /// - Parameters:
    ///   - url: The URL to load the image from
    ///   - contentMode: How the image should be scaled
    ///   - placeholder: Custom placeholder view
    init<Placeholder: View>(
        url: URL?,
        contentMode: ContentMode = .fit,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = AnyView(placeholder())
    }
    
    /// Creates an async image view with a default placeholder
    /// - Parameters:
    ///   - url: The URL to load the image from
    ///   - contentMode: How the image should be scaled
    init(
        url: URL?,
        contentMode: ContentMode = .fit
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = AnyView(
            Image(systemName: "photo")
                .foregroundColor(.gray)
                .font(.title)
        )
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable(capInsets: .init(.zero),
                               resizingMode: .stretch)
            } else if imageLoader.isLoading {
                loadingView
            } else if imageLoader.error != nil {
                errorView
            } else {
                placeholder
            }
        }
        .onAppear {
            loadImageIfNeeded()
        }
        .onChange(of: url) { _, newURL in
            if newURL != url {
                loadImageIfNeeded()
            }
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
    
    // MARK: - Private Views
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorView: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
                .font(.title2)
            
            Text("Failed to load")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Private Methods
    private func loadImageIfNeeded() {
        guard let url = url else {
            imageLoader.reset()
            return
        }
        
        imageLoader.loadImage(from: url)
    }
}

