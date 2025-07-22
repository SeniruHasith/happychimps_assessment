# XYZ Shop Mobile App

A Flutter e-commerce mobile application for XYZ company. The app allows users to browse recommended products, manage their profile, and access location-based features.

## Features

- User authentication with session management
- OAuth flow with refresh token support
- Location-based services
- Infinite scroll product list
- Profile management
- Modern UI with Material 3 design

## Architecture & Design Patterns

The project follows Clean Architecture principles and uses the following design patterns:

1. **BLoC Pattern**: For state management, providing a clear separation between UI and business logic.
2. **Repository Pattern**: Abstracts data sources and provides a clean API for data access.
3. **Dependency Injection**: Using Provider for dependency injection and service locator pattern.
4. **Observer Pattern**: Implemented through BLoC for reactive state management.
5. **Factory Pattern**: Used in model classes for JSON serialization.

### Project Structure

```
lib/
  ├── core/
  │   ├── api/
  │   ├── config/
  │   ├── constants/
  │   ├── errors/
  │   ├── services/
  │   └── utils/
  ├── data/
  │   ├── models/
  │   └── repositories/
  ├── domain/
  │   ├── entities/
  │   └── repositories/
  ├── features/
  │   ├── auth/
  │   ├── home/
  │   └── profile/
  └── presentation/
      ├── bloc/
      └── widgets/
```

## Dependencies

- `flutter_bloc`: State management
- `dio`: HTTP client with interceptor support
- `shared_preferences`: Local storage
- `geolocator`: Location services
- `cached_network_image`: Image caching
- And more (see pubspec.yaml)

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Testing

The project includes unit tests for the authentication BLoC. Run tests with:

```bash
flutter test
```

## Error Handling

- HTTP error handling with proper error messages
- Location permission handling
- Token refresh mechanism
- Network error handling
- Proper error UI feedback

## Future Improvements

1. Add more unit tests and widget tests
2. Implement caching for offline support
3. Add product search functionality
4. Implement cart and checkout features
5. Add push notifications

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
