# Listin - Collaborative Shopping List App

## Project Description

This project is a Flutter application that helps users create and manage collaborative shopping lists. It leverages Firebase as a backend to provide real-time data synchronization, user authentication, and cloud storage for user profile pictures.

### Key Features

- **User Authentication:** Secure sign-up, sign-in, and password reset functionalities.
- **Collaborative Lists:** Users can create and manage multiple shopping lists.
- **Product Management:** Add, edit, and remove products within each list, with options for price and amount.
- **Real-time Synchronization:** Data is synchronized across devices in real-time using Cloud Firestore.
- **Profile Management:** Users can update their profile picture, which is stored in Firebase Storage.

---

## Getting Started

This guide will help you set up the project for local development.

### Prerequisites

- Flutter SDK (version 3.8.1 or higher)
- A Firebase project
- Firebase CLI installed
- FlutterFire CLI installed

### Local Development Setup

Follow these steps to run the app on your local machine:

1.  **Clone the repository:**

    ```bash
    git clone [your_repository_url]
    cd listin
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Configure Firebase:**
    This project uses Firebase for its backend services. You need to configure your own Firebase project to run the application.

    a. **Set up your Firebase project**: Go to the [Firebase console](https://console.firebase.google.com/) and create a new project.

    b. **Install platform apps**: Add an Android and an iOS app to your Firebase project. Follow the on-screen instructions, providing your package name (`com.example.listin`).

    c. **Generate configuration files**: With the FlutterFire CLI, run the following command in your project's root directory:

    ```bash
    flutterfire configure
    ```

    Follow the prompts to link your Flutter project with the Firebase project you just created. This will generate a `lib/firebase_options.dart` file and platform-specific configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS/macOS).

    d. **Important**: Because the configuration files are sensitive, they are not included in the repository. The `.gitignore` file is configured to prevent them from being committed.

4.  **Run the application:**
    ```bash
    flutter run
    ```

---

## App Screenshots

![Auth Screen](https://github.com/joeltonmats/flutter-listin/blob/main/assets/images/screenshot1.png)

_The authentication screen, where users can sign in or register for a new account._

![Sign Up Screen](https://github.com/joeltonmats/flutter-listin/blob/main/assets/images/screenshot2.png)

_The sign up screen, where users can register for a new account._

![Profile Screen](https://github.com/joeltonmats/flutter-listin/blob/main/assets/images/screenshot3.png)

_The profile screen allows users to manage their profile picture history._

![Menu Screen](https://github.com/joeltonmats/flutter-listin/blob/main/assets/images/screenshot4.png)

_The menu screen, where users can remove, sign out and access the profile screen._

![Home Screen](https://github.com/joeltonmats/flutter-listin/blob/main/assets/images/screenshot5.png)

_The home screen displays the user's shopping lists._

![Home Screen](https://github.com/joeltonmats/flutter-listin/blob/main/assets/images/screenshot6.png)

_A detailed view of a shopping list, showing planned and purchased products._

---

## About

This project was developed as part of the Alura Flutter formation, titled: "Utilize os serviços do Firebase com Flutter".

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
