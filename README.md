# summeryme-ai

## About The Project

読みたいのに読めない人が読めるようになるAIサービス

## Getting Started

This project consists of a backend built with Ruby on Rails and a frontend built with Flutter.

### Prerequisites

- Docker
- Docker Compose
- Flutter SDK

### Backend Setup

1. Clone the repository.
2. Navigate to the `backend` directory.
3. Build the Docker containers:
   ```bash
   docker compose build
   ```
4. Set up the database:
   ```bash
   docker compose run --rm api rails db:drop db:create db:migrate db:seed
   ```
   *Note: If you are running this for the first time and `db:drop` fails, you can ignore the error and proceed.*
5. Start the backend server:
   ```bash
   docker compose up
   ```
The backend will be accessible at <http://localhost:3000>.

### Frontend Setup

1. Navigate to the `frontend` directory.
2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the Flutter application (choose one of the following based on your target platform):

   For Web:
   ```bash
   flutter run -d chrome
   ```

   For Mobile (ensure you have an emulator running or a device connected):
   ```bash
   flutter run
   ```

   For Desktop (macOS, Linux, Windows):
   ```bash
   flutter run -d [macos|linux|windows]
   ```

   Refer to the [Flutter documentation](https://docs.flutter.dev/) for more detailed instructions on running Flutter apps.


## Technologies Used

*   **Backend:** Ruby on Rails
*   **Frontend:** Flutter
*   **Containerization:** Docker, Docker Compose

## Contributing

[Information about how to contribute to the project can be added here.]

## License

[Specify the license for your project here, e.g., MIT License.]
