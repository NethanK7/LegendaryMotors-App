# Shared Components Architecture

This directory contains all reusable code and widgets, organized simply into a Model-View-Controller (MVC) structure to ensure separation of concerns.

## Structure

### /widgets (View)
Contains the visual elements (widgets). These are "dumb" components that simply render data provided to them.
- **Atoms**: `PremiumButton`, `PremiumTextField`, `SectionLabel`
- **Molecules**: `CarCard`, `SectionHeader`, `GlassContainer`, `PremiumListTile`, `LocationListItem`, `LiveClock`
- **Organisms**: `HeroBanner`, `PremiumCarCard`, `OfflineBanner`, `WeatherDisplay`, `SliverPageHeader`

### /models (Model)
Contains the data structures that are shared across multiple widgets and features.
- `Car` (Core domain model)
- `User` (Core domain model)
- `Location` (Location data model)

### /controllers (Controller)
Contains the logic and state management for shared components.
- *(For example, a `ThemeController` or `ConnectivityController` to manage state for `OfflineBanner` could live here)*

## Usage
Import widgets from `lib/shared/widgets/`.
Example:
```dart
import '../../shared/widgets/premium_button.dart';
```
