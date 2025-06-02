# TMDB Movies App

A modern iOS application built with SwiftUI that displays movies from The Movie Database (TMDB) API. The app features a clean, user-friendly interface with search functionality, image caching, and comprehensive error handling.

## 📱 Features

- **Movie Discovery**: Browse popular movies from TMDB
- **Search Functionality**: Search for movies with debounced input
- **Image Caching**: Efficient image loading and caching system
- **Error Handling**: Comprehensive error states and user feedback
- **Clean Architecture**: MVVM pattern with repository design
- **Testing**: Unit tests with mock data support
- **Author Information**: About screen with developer details

## 🏗️ Architecture

The app follows Clean Architecture principles with clear separation of concerns:


├── Core/
│   ├── App/                    \# App configuration and entry point
│   ├── Base/
│   │   ├── General/           \# Base classes and utilities
│   │   └── Component/         \# Reusable UI components
├── Scene/
│   ├── MovieList/             \# Movie listing feature
│   │   ├── View/             \# SwiftUI views
│   │   ├── ViewModel/        \# Business logic
│   │   ├── Model/            \# Data models
│   │   ├── Dependencies/     \# Data source and repository
│   │   └── Services/         \# Network clients
│   └── AuthorInfo/           \# About/Info screen
├── Services/
│   └── Networking/           \# Network layer
├── Utils/
│   ├── Extensions/           \# Swift extensions
│   └── Helper/              \# Utility functions
└── Resources/               \# Assets and mock data

bash
git clone https://github.com/erfandadras/TMDB_Task_erfan_dadras.git
cd TMDB_Task_erfan_dadras

2.  Open the project in Xcode:

bash
```swift
open TMDB_Task_erfan_dadras.xcodeproj
```

3.  Configure your TMDB API key:
    
      - Get your API key from [TMDB](https://www.themoviedb.org/settings/api)
      - Update the `API.token` in `Services/Networking/API.swift`

4.  Build and run the project

## 🔧 Configuration

### API Configuration

Update the API configuration in `Services/Networking/API.swift`:

swift
```swift
struct API {
    static let token = "YOUR_TMDB_API_TOKEN"
    static let baseURL = "https://api.themoviedb.org/3"
    static let mediaBaseURL = "https://image.tmdb.org/t/p/w500"
    
    struct Routes {
        static let movieList = baseURL + "/discover/movie"
        static let search = baseURL + "/search/movie"
    }
}
```

### Build Configurations

The app supports different configurations:

  - Debug: Uses `MockMoviesNetworkClient` with local JSON data
  - Release: Uses real TMDB API calls

## 🧪 Testing

The project includes comprehensive unit tests:

bash
```swift
# Run tests in Xcode
CMD + U

# Run specific test suite
# Select test target and run individual test methods
```

### Test Coverage

  - MovieListViewModel functionality
  - Network layer with mock data
  - Search functionality with debouncing
  - Error handling scenarios
  - Data transformation and validation

### Mock Data

Tests use the included `Movies.json` file with real TMDB data structure for reliable testing.

## 📦 Key Components

### NetworkService

Generic networking layer supporting:

  - Type-safe API calls
  - Custom error handling
  - Flexible request configuration

### ImageCache

High-performance image caching system:

  - Memory and disk caching
  - Automatic cleanup
  - Thread-safe operations
  - Memory pressure handling

### MovieListViewModel

Reactive view model with:

  - Debounced search (500ms)
  - State management
  - Error handling
  - Pagination support (ready for implementation)

### Repository Pattern

Clean data layer with:

  - Protocol-based design
  - Mock implementations for testing
  - Separation of network and business logic

## 🎨 UI/UX Features

  - SwiftUI: Modern declarative UI
  - Search: Real-time search with debouncing
  - Loading States: Progress indicators and error states
  - Image Loading: Async image loading with placeholders
  - Safe Area: Proper safe area handling
  - Accessibility: VoiceOver support ready

## 🔮 Future Enhancements

- [ ] Movie detail screen
- [ ] Favorites functionality
- [ ] Offline support
- [ ] Dark mode optimization
- [ ] iPad support
- [ ] Pagination implementation
- [ ] Advanced filtering options
- [ ] User authentication

## 🤝 Contributing

1.  Fork the repository
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 👨‍💻 Author

Erfan Dadras

  - Email: <erfandadras@gmail.com>
  - GitHub: [@erfandadras](https://github.com/erfandadras)
  - Location: Iran

## 📄 License

This project is created for learning and demonstration purposes. The Movie Database (TMDB) API is used under their terms of service.

## 🙏 Acknowledgments

  - [The Movie Database (TMDB)](https://www.themoviedb.org/) for providing the movie data API
  - Apple for SwiftUI and iOS development tools
  - The iOS development community for inspiration and best practices

## 📊 Project Statistics

  - Lines of Code: \~2,000+
  - Files: 25+
  - Test Coverage: Comprehensive unit tests
  - Architecture: Clean Architecture with MVVM
  - Supported Devices: iPhone (iOS 18.2+)

-----

Made with ❤️ for learning and demonstration purposes
