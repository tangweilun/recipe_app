# Recipe App

A Flutter application for managing and organizing your favorite recipes. Built with clean architecture principles and modern Flutter practices.

## Features

- 📱 Create, read, update, and delete recipes
- 🖼️ Add images to your recipes
- 🔍 Filter recipes by category
- 💾 Local storage using Hive

## Getting Started

### Prerequisites

- Flutter SDK (using FVM)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:

```bash
git clone https://github.com/tangweilun/recipe_app.git
cd recipe_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
├── data/
│   ├── models/         # Data models
│   └── services/       # Business logic and data services
├── presentation/
│   ├── providers/      # State management
│   ├── screens/        # UI screens
│   └── widgets/        # Reusable widgets
└── main.dart          # App entry point
```

## Architecture

The app follows clean architecture principles:

- **Data Layer**: Models and services for data management
- **Presentation Layer**: UI components and state management
- **Domain Layer**: Business logic and use cases

## Dependencies

- **provider**: State management
- **hive**: Local storage
- **image_picker**: Image selection
- **uuid**: Unique ID generation
- **path_provider**: File system access

## Development

### Using FVM (Flutter Version Management)

1. Install FVM:

```bash
dart pub global activate fvm
```

2. Set Flutter version:

```bash
fvm use stable
```

3. Run with FVM:

```bash
fvm flutter run
```

### Running Tests

```bash
flutter test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Hive for the efficient local storage solution
- Provider package for state management
