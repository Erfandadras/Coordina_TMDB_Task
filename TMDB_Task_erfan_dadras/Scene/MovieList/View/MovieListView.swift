//
//  ContentView.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import SwiftUI

/// Main view displaying a list of movies with search functionality
struct MovieListView: View {
    
    // MARK: - State Properties
    /// Focus state for search functionality
    @FocusState var focused
    /// View model managing movie data and state
    @StateObject var viewModel: MovieListViewModel
    /// Safe area insets from environment
    @Environment(\.safeAreaInsets) var insets
    @State private var navigationButtonID = UUID()
    /// Coordinator managing Navigations
    @StateObject var coordinator = Coordinator()
    // MARK: - Initialization
    /// Initializes the view with appropriate network client based on build configuration
    init() {
        let client: NetworkClientImpl<MoviesNetworkClient>
#if DEBUG
        // Use mock client for development and testing
        client = .init(client: MockMoviesNetworkClient())
#else
        // Use real network client for production
        client = .init(client: MoviesNetworkClient())
#endif
        let dataSource = MoviesDatasource(network: client)
        self._viewModel = .init(wrappedValue: MovieListViewModel(dataSource: dataSource))
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath){
            ScrollView {
                // Error State Display
                if case .failure(let error) = viewModel.state {
                    Text(error.localizedDescription)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.red)
                        .padding(.top, 1)
                }
                // Loading State Display
                else if viewModel.state == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                // Movie List Content
                LazyVStack(spacing: 8){
                    ForEach(viewModel.movies.indices, id: \.self) { index in
                        let item = viewModel.movies[index]
                        MovieListItemView(data: item)
                            .background(.white)
                            .id(item.id)
                        if index == viewModel.movies.count - 1 && viewModel.hasMoreData {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .onAppear {
                                    if viewModel.state == .success {
                                        viewModel.loadMore()
                                    }
                                }
                        }
                    }
                }
                .padding(.bottom, insets.bottom)
            }// scrollView
            .scrollDismissesKeyboard(.automatic)
            .refreshable {
                viewModel.refresh()
            }
            .navigationTitle("Home")
            .toolbar(id: UUID().uuidString, content: {
                ToolbarItem(id: UUID().uuidString ,placement: .topBarTrailing) {
                    Button("About", systemImage: "exclamationmark") {
                        coordinator.append(MovieListCoordinatorPath.authorInfo)
                    }
                }
            })
            .navigationBarTitleDisplayMode(.automatic)
            .background(.white)
            .animation(.linear, value: focused)
            .navigationDestination(for: MovieListCoordinatorPath.self) { item in
                switch item {
                case .authorInfo:
                    AuthorInfoView()
                        .environmentObject(coordinator)
                }
            }
        }// navigation view
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            // Load data when view appears
            viewModel.fetchData()
        }
        .searchable(text: $viewModel.keyword,
                    placement: .navigationBarDrawer,
                    prompt: Text("Search"))
        .focused($focused)
        .background(.white)
    }
}
