# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a full-stack application with:
- **Backend**: TypeScript/Node.js using Hono framework with Prisma ORM and MySQL
- **Frontend**: Flutter cross-platform mobile/web application
- **Infrastructure**: Google Cloud Platform managed with Terraform

## Essential Commands

### Backend Development (backend_ts/)
```bash
# Setup & Development
pnpm install                  # Install dependencies
docker compose up -d          # Start MySQL database (port 3306)

# Database Operations (requires DATABASE_URL in .env)
pnpm prisma generate         # Generate Prisma client
pnpm prisma migrate dev      # Apply database migrations
pnpm prisma studio           # Open database GUI (port 5555)
pnpm prisma migrate create --name <migration_name>  # Create new migration

# Development Server
pnpm dev                     # Start development server (port 8787, hot reload)

# Code Quality
pnpm lint                    # Run ESLint
pnpm format                  # Format with Prettier
pnpm build                   # Build TypeScript

# Batch Processing
pnpm run-job:dailySummary    # Run daily summary batch processing
pnpm run-job:articleSummary  # Run article summary batch processing

# API Specification & Code Generation (TypeSpec) - Under development, currently unused
pnpm typespec                # Compile TypeSpec specifications
pnpm typespec:watch          # Watch mode for TypeSpec compilation
pnpm generate:types          # Generate TypeScript type definitions
pnpm generate-api-client     # Generate Dart API client

# Docker-specific Commands
docker compose ps            # Check container status
docker compose logs db       # View MySQL logs
docker compose logs backend  # View backend logs
docker compose down          # Stop and remove containers
docker compose down -v       # Stop containers and remove volumes (WARNING: deletes data)
docker compose exec db mysql -uroot -ppassword summerymeai_development  # Access MySQL CLI

# Alternative: Run without Docker
# If you prefer to run the backend without Docker:
# 1. Ensure MySQL 8.0+ is installed locally
# 2. Create database: summerymeai_development
# 3. Update DATABASE_URL in .env
# 4. Run: pnpm dev
```

**Note**:

- Ensure `.env` file exists with appropriate `DATABASE_URL`
- For Docker: `DATABASE_URL=mysql://root:password@db:3306/summerymeai_development`
- For local MySQL: `DATABASE_URL=mysql://root:password@localhost:3306/summerymeai_development`
- The backend service runs on port 8080 when using Docker, port 8787 when using `pnpm dev` directly

**Environment Variables**:

**Required for Production**:
- `DATABASE_URL`: MySQL connection string
- `GEMINI_API_KEY`: Google Gemini AI API key
- `GCS_AUDIO_BUCKET`: Google Cloud Storage bucket for audio files

**Optional for Development**:
- `USE_MOCK_TTS=true`: Enable mock mode for text-to-speech (no API calls)
- `USE_MOCK_SUMMARY_AI=true`: Enable mock mode for AI text generation (no API calls)

### Frontend Development (frontend/)
```bash
# Setup & Development
flutter pub get              # Install dependencies
flutter run                  # Run on connected device
flutter run -d chrome        # Run in Chrome browser
flutter run -d ios           # Run iOS simulator
flutter run -d android       # Run Android emulator

# Testing & Code Quality
flutter test                 # Run all tests
flutter test test/widget_test.dart  # Run specific test
flutter analyze              # Static analysis
dart format .             # Format code

# Building
flutter build apk            # Android APK
flutter build ios            # iOS build
flutter build web            # Web build
```

### Infrastructure (terraform/)
```bash
# Essential Operations
make init                    # Initialize Terraform
make plan                    # Show changes
make apply                   # Apply changes
make migrate                 # Run database migrations after deployment
```

## Architecture & Structure

### Backend Architecture
- **Framework**: Hono (lightweight Express-like framework)
- **Database**: MySQL 8.0 with Prisma ORM
- **APIs**: RESTful endpoints in `src/apis/`
- **Services**: AI text generation and text-to-speech in `src/services/`
- **Batch Processing**: Parallel processing with chunking for scalability
- **Cloud Storage**: Google Cloud Storage for audio file storage
- **Deployment**: Docker container on Google Cloud Run

Key files:
- `src/index.ts`: Main application entry point and route definitions
- `prisma/schema.prisma`: Database schema
- `src/lib/dbClient.ts`: Prisma client singleton

### Frontend Architecture
- **State Management**: Provider pattern
- **Screens**: Authentication, digest view, saved articles, settings
- **Models**: Article data model
- **Theme**: Custom Material theme in `lib/themes/`

Key screens:
- `lib/screens/main_tab_screen.dart`: Main navigation
- `lib/screens/today_digest_screen.dart`: Today's digest view
- `lib/screens/auth/`: Authentication flows

### Infrastructure Architecture
- **Cloud Run**: Containerized backend service
- **Cloud SQL**: MySQL 8.0 database
- **Secret Manager**: API keys and credentials
- **VPC**: Private networking for database
- **Artifact Registry**: Docker image storage
- **Cloud Storage**: Audio file storage with automatic upload

## Development Workflow

1. **Backend Changes**:
   - Make changes in `backend_ts/src/`
   - Test locally with `pnpm dev`
   - Run `pnpm lint` before committing
   - Database changes require new migration

2. **Frontend Changes**:
   - Make changes in `frontend/lib/`
   - Test on target platform(s)
   - Run `flutter analyze` before committing

3. **Infrastructure Changes**:
   - Modify Terraform files
   - Run `make plan` to preview
   - Apply with `make apply`

4. **Batch Processing Development**:
   - Use mock mode for development: Set `USE_MOCK_TTS=true` and `USE_MOCK_SUMMARY_AI=true`
   - Test batch jobs: `pnpm run-job:dailySummary` or `pnpm run-job:articleSummary`
   - Monitor processing with chunk-based parallel execution

## Important Notes

- The backend uses environment variables from `.env` file locally
- Frontend configuration is in `pubspec.yaml`
- All secrets are managed via Google Secret Manager in production
- Database migrations must be run manually after deployment
- The project uses GitHub Actions for CI/CD (see CICD_SETUP.md)
- Batch processing uses parallel execution with 10-user chunks to handle large datasets efficiently
- Mock modes are available for development to avoid API costs
