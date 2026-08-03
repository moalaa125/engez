# Engez (إنجز)

A Flutter app for pre-ordering food and drinks from nearby cafes and restaurants, paying online, and getting notified when the order is ready for pickup — no more waiting in line.

##  Concept

The user opens the app, sees nearby cafes/restaurants based on their location, places and pays for an order online, then gets notified once the order is ready for pickup.

## 📱 Screens

<!-- Add your screenshots below, e.g.: -->
<!-- <img src="screenshots/login.png" width="250" /> -->

| Login | Home | Place Details |
|---|---|---|
| *(add screenshot here)* | *(add screenshot here)* | *(add screenshot here)* |

##  Current Features

- **Auth**
  - Login with Egyptian phone number + OTP via Firebase Phone Auth
  - Google Sign-In
- **Location**
  - Fetches the user's current location and resolves it to a readable address (Geocoding)
  - Handles all location permission states (denied, disabled, permanently denied)
- **Categories**
  - Select a category from a list of place/item categories
- **UI**
  - Responsive design across all screen sizes (flutter_screenutil)
  - Custom color theme with Arabic font support (Google Fonts - Cairo)
  - Reusable UI components (buttons, cards, input fields, bottom nav bar, offers carousel...)

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Core framework |
| Firebase Core / Firebase Auth | Login and authentication |
| Google Sign-In | Google login |
| flutter_bloc (Cubit) | State management |
| equatable | Efficient state comparison |
| flutter_screenutil | Responsive UI |
| google_fonts | Custom fonts (Cairo) |
| geolocator / geocoding | Geolocation and reverse geocoding |
| google_nav_bar | Bottom navigation bar |
| carousel_slider | Offers/slider display |

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point and Firebase initialization
├── firebase_options.dart          # Firebase config (auto-generated)
├── constants/
│   └── my_colors.dart             # Core app colors
├── core/
│   └── theme/
│       └── app_theme.dart         # Global theme (colors, fonts, buttons, input fields)
├── features/
│   ├── auth/
│   │   ├── manager/                       # AuthCubit + AuthState
│   │   └── presentation/screens/          # Login and home screens
│   ├── category/                          # SelectCategoryCubit + State
│   └── location/
│       └── manger/                        # LocationCubit + State
└── widgets/                        # Reusable UI components
    ├── custom_button.dart
    ├── custom_icon_button.dart
    ├── custom_image.dart
    ├── custom_offer_section.dart
    ├── custom_text_bubble.dart
    ├── custom_text_field.dart
    ├── category_list.dart
    ├── menu_item_card.dart
    ├── nav_bar.dart
    └── place_card.dart
```

## ⚙️ Setup & Run

### Requirements
- Flutter SDK installed on your machine
- A Firebase project linked to the app (the `firebase_options.dart` file must be configured for your own Firebase project)
- **Phone Authentication** and **Google Sign-In** enabled in the Firebase Authentication console

### Run Steps

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

> Note: Make sure `firebase_options.dart` is generated from your own Firebase project (via `flutterfire configure`), not used as-is from the repo, since it's tied to a specific Firebase project.

## 🗺️ Suggested Next Steps

- Screens: menu view, cart & checkout, order tracking, order history
- Integrate online payment (Visa)
- Connect a real places list instead of the current placeholder data
- Push notifications when the order is ready

---
