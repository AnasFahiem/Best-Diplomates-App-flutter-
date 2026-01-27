# Best Diplomats App Clone

## Setup & Run

1.  **Prerequisites**: Ensure you have Flutter installed and set up.
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

## Features Implemented

*   **Clean Architecture**: Folder structure organized by features (`auth`, `home`, `events`, `profile`, `onboarding`) and core (`constants`, `theme`).
*   **State Management**: `Provider` (Mock logic in `AuthViewModel`).
*   **UI/UX**: Modern design with Navy Blue & Gold palette, Google Fonts (Poppins), and `animate_do` for animations.
*   **Screens**:
    *   Splash Screen (Animated Logo Reveal)
    *   Onboarding (3 Slides)
    *   Login & Sign Up (Validation, Secure Fields)
    *   Home (Dashboard, Drawer, Featured Events, News)
    *   Event Details (Scrollable info, Register button)
    *   Profile (User info, mocked settings)

## Notes
- Images are placeholders (icons or asset paths that need actual files if you want images).
- Backend logic is mocked for demonstration purposes.
