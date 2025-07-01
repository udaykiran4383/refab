/*
ReFab Flutter Project Structure

lib/
├── main.dart                          // App entry point
├── app/
│   ├── app.dart                      // Main app widget
│   ├── routes/                       // Navigation setup
│   └── themes/                       // App theming
├── core/
│   ├── constants/                    // App constants
│   ├── errors/                       // Error handling
│   ├── network/                      // API client
│   ├── services/                     // Core services
│   └── utils/                        // Utility functions
├── features/
│   ├── auth/                         // Authentication
│   │   ├── data/                     // Data layer
│   │   ├── domain/                   // Business logic
│   │   └── presentation/             // UI layer
│   ├── tailor/                       // Tailor module
│   ├── logistics/                    // Logistics module
│   ├── warehouse/                    // Warehouse module
│   ├── customer/                     // Customer module
│   ├── volunteer/                    // Volunteer module
│   └── admin/                        // Admin module
├── shared/
│   ├── widgets/                      // Reusable widgets
│   ├── providers/                    // Global providers
│   └── services/                     // Shared services
└── generated/                        // Generated files

Key Architecture Principles:
- Clean Architecture with separation of concerns
- Feature-based modular structure
- Dependency injection with Riverpod
- Repository pattern for data access
- MVVM pattern for UI logic
*/

// Example feature structure for Tailor module
/*
features/tailor/
├── data/
│   ├── datasources/
│   │   ├── tailor_local_datasource.dart
│   │   └── tailor_remote_datasource.dart
│   ├── models/
│   │   ├── pickup_request_model.dart
│   │   └── tailor_model.dart
│   └── repositories/
│       └── tailor_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── pickup_request.dart
│   │   └── tailor.dart
│   ├── repositories/
│   │   └── tailor_repository.dart
│   └── usecases/
│       ├── create_pickup_request.dart
│       ├── get_pickup_history.dart
│       └── update_pickup_status.dart
└── presentation/
    ├── pages/
    │   ├── tailor_dashboard.dart
    │   ├── pickup_request_form.dart
    │   └── pickup_history.dart
    ├── widgets/
    │   ├── pickup_card.dart
    │   └── stats_widget.dart
    └── providers/
        ├── tailor_provider.dart
        └── pickup_provider.dart
*/
