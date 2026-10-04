# Üretim Monitörü

A Flutter application for monitoring and managing factory production processes.

**Üretim Monitörü** allows users to manage products, track daily production, monitor required materials and stock levels, and follow production progress through a simple interface.

## Features

* 📦 **Product Management**

    * Add, update, and delete products
    * Set total production targets
    * Set daily production targets
    * Mark products as completed
    * Track product production progress

* 📊 **Production Tracking**

    * Record daily production quantities
    * View production history
    * Calculate total production for each product
    * Compare current production with the target

* 🧰 **Material & Stock Management**

    * Define materials required for each product
    * Track material quantities
    * Add additional pieces to existing stock
    * Monitor whether available stock is sufficient for production

* 💾 **Local Database**

    * SQLite database for persistent local storage
    * CRUD operations for products and production records
    * Foreign-key relationships between products and related records

* 🎨 **Simple User Interface**

    * Clean and straightforward interface
    * Production status indicators
    * Progress bars for production targets
    * Separate views for active and completed products

## Tech Stack

* **Flutter**
* **Dart**
* **Riverpod** — State management
* **SQLite / sqflite** — Local database
* **Material Design** — User interface

## Architecture

The project follows a layered architecture to separate UI, state management, business logic, and database operations.

```text
UI
│
├── Pages
└── Widgets
      │
      ▼
Riverpod Providers
      │
      ▼
Repositories
      │
      ▼
DAOs
      │
      ▼
DatabaseHelper
      │
      ▼
SQLite
```

### Data Flow

For example, retrieving products follows this flow:

```text
ProductsPage
     ↓
productsProvider
     ↓
ProductRepository
     ↓
ProductDao
     ↓
SQLite
```

Adding a daily production record follows the same pattern:

```text
Production Page
     ↓
dailyProductionsProvider
     ↓
DailyProductionRepository
     ↓
DailyProductionDao
     ↓
SQLite
```

### Why this architecture?

The separation of responsibilities makes the application easier to maintain and extend.

* **Models** represent application data.
* **Pages and Widgets** are responsible for the user interface.
* **Providers** manage application state and communicate with repositories.
* **Repositories** contain application-level operations and business logic.
* **DAOs** handle direct SQLite operations.
* **DatabaseHelper** manages the SQLite database connection and schema.

## Project Structure

```text
lib/
│
├── database/
│   ├── dao/
│   │   ├── daily_production_dao.dart
│   │   ├── product_dao.dart
│   │   └── ...
│   │
│   └── database_helper.dart
│
├── models/
│   ├── daily_production.dart
│   ├── material.dart
│   └── product.dart
│
├── pages/
│   ├── add_product_page.dart
│   ├── product_details_page.dart
│   ├── production_history.dart
│   └── ...
│
├── providers/
│   ├── daily_production_provider.dart
│   ├── product_provider.dart
│   └── ...
│
├── repositories/
│   ├── daily_production_repository.dart
│   ├── product_repository.dart
│   └── ...
│
├── widgets/
│   ├── product_container.dart
│   └── ...
│
└── main.dart
```

## Database

The application uses SQLite for local data persistence.

### Products

The `products` table stores information about products:

| Column         | Description                      |
| -------------- | -------------------------------- |
| `id`           | Product ID                       |
| `name`         | Product name                     |
| `total_target` | Total production target          |
| `daily_target` | Daily production target          |
| `image`        | Product image path               |
| `is_finished`  | Whether the product is completed |

### Daily Productions

The `daily_productions` table stores individual production records:

| Column       | Description               |
| ------------ | ------------------------- |
| `id`         | Production record ID      |
| `product_id` | ID of the related product |
| `created_at` | Production date/time      |
| `unit`       | Number of units produced  |

A product can have multiple daily production records.

```text
Product
   │
   └── 1 ──────── * DailyProduction
```

## Installation

### Requirements

Make sure you have the following installed:

* Flutter SDK
* Dart SDK
* Android Studio or another Flutter-compatible IDE
* Android SDK for Android development

Check your Flutter installation:

```bash
flutter doctor
```

### Clone the repository

```bash
git clone <repository-url>
```

Navigate to the project:

```bash
cd uretim_monitoru
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Development

After making changes to the project, you can run:

```bash
flutter analyze
```

To run tests:

```bash
flutter test
```

To build an Android release:

```bash
flutter build apk --release
```

Or generate an Android App Bundle:

```bash
flutter build appbundle --release
```

## State Management

Riverpod is used to manage application state.

For example, products are accessed through:

```dart
final productsState = ref.watch(productsProvider);
```

Product operations are performed through the notifier:

```dart
ref.read(productsProvider.notifier).deleteProduct(productId);
```

Daily production is scoped to a product:

```dart
final productionState =
    ref.watch(dailyProductionsProvider(productId));
```

This allows each product to maintain its own production records.

## CRUD Operations

The application follows the same pattern for database operations:

```text
Create
  ↓
Provider
  ↓
Repository
  ↓
DAO
  ↓
SQLite
```

The same structure is used for:

* Create
* Read
* Update
* Delete

This keeps direct database operations out of the UI layer.

## Production Progress

Production progress is calculated using the total amount produced compared with the product's target:

```text
Progress = Current Production / Total Target
```

For example:

```text
Current Production: 75
Total Target:       100

Progress: 75%
```

The UI represents this using a progress indicator.

## Future Improvements

Potential future improvements include:

* [ ] Material stock transaction history
* [ ] Automatic material consumption based on production
* [ ] Production reports
* [ ] Production statistics and charts
* [ ] Search and filtering
* [ ] Export production data
* [ ] Backup and restore
* [ ] Cloud synchronization
* [ ] User authentication and roles
* [ ] Improved database migrations
* [ ] Automated tests


```text
screenshots/
├── products.png
├── product_details.png
├── production.png
├── production_history.png
└── materials.png
```

## License

This project is currently for development and portfolio purposes.

If you intend to distribute the application publicly, add an appropriate license here.

## Author

**Amr Walidi**

Software Engineer

GitHub: [github.com/AmrWalidi](https://github.com/AmrWalidi)
