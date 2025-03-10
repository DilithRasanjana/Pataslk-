# PatasLK

## Overview

PatasLK is a mobile application built with Flutter that connects service providers with customers. The app allows users to browse available services, book appointments, and manage their bookings efficiently. The platform streamlines the process of finding and scheduling services, providing a seamless experience for both customers and service providers.

## Features

### Customer Features
- **Service Browsing**: Browse through various services offered by different providers
- **Booking Management**: Create, view, and manage service bookings
- **Booking Status Tracking**: Track bookings with different statuses (Pending, In Progress, Completed, Draft)
- **Provider Communication**: Direct call functionality to contact service providers
- **Booking History**: View past, upcoming, and draft bookings

### Provider Features
- Service management
- Booking acceptance and scheduling
- Customer communication
- Work history tracking

## Installation

### Prerequisites
- Flutter (latest stable version)
- Dart SDK
- Firebase account
- Android Studio / VS Code

### Setup Instructions

1. Clone the repository:
```bash
git clone https://github.com/DilithRasanjana/Pataslk-.git
cd pataslk
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the `google-services.json` file to the `/android/app/` directory
   - Download and add the `GoogleService-Info.plist` file to the `/ios/Runner/` directory

4. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── booking.dart
│   ├── service.dart
│   └── user.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── customer/
│   │   ├── services_screen.dart
│   │   └── booking_screen.dart
│   └── provider/
│       ├── dashboard_screen.dart
│       └── bookings_screen.dart
├── services/
│   ├── auth_service.dart
│   └── booking_service.dart
└── widgets/
    ├── booking_card.dart
    └── service_card.dart
```

## How to Use

### Customer Journey
1. Sign up or log in to your account
2. Browse available services
3. Select a service and book an appointment 
4. Track your booking status under "Bookings"
5. View upcoming appointments, booking history, and draft bookings
6. Contact service providers directly through the app

### Provider Journey
1. Sign up or log in as a service provider
2. Set up your service profile
3. Manage incoming booking requests
4. Update booking statuses as you progress
5. Communicate with customers

## Dependencies

The project relies on several key dependencies:

- **Firebase Authentication**: For user authentication
- **Cloud Firestore**: For database storage
- **Flutter**: For the UI framework
- **Intl**: For date and time formatting

See the `pubspec.yaml` file for a complete list of dependencies.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
