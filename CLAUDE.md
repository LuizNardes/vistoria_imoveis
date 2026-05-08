# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile app for real-estate property inspections (vistorias de imóveis). Users create inspections, add rooms with items and photos, then generate PDF reports. Backend is 100% Firebase (Auth, Firestore, Storage).

## Commands

```bash
# Run the app
flutter run

# Build for release
flutter build apk --release

# Code generation (run after editing any @freezed, @riverpod, or @JsonSerializable annotated file)
dart run build_runner build -d

# Lint / static analysis
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

> After adding/modifying models or providers, always run `build_runner build` — generated `.g.dart` and `.freezed.dart` files must be up to date or the app won't compile.

## Architecture

Feature-based structure under `lib/`:

```
lib/
├── core/           # App-wide: router, theme, services, constants, error types
├── features/       # One folder per feature (auth, home, inspections, inspection_details, reports)
│   └── <feature>/
│       ├── data/           # Repository classes (Firestore/Storage access)
│       ├── domain/         # @freezed models, domain interfaces
│       └── presentation/   # Screens, controllers (Riverpod), widgets
├── shared/         # Reusable widgets (cards, empty states, offline banner)
├── main.dart
└── firebase_options.dart
```

### State management — Riverpod with code generation

All providers use the `@riverpod` / `@Riverpod` annotation from `riverpod_generator`. Controllers use `AsyncValue` and `AsyncValue.guard()` for error handling. UI widgets extend `ConsumerWidget` and read state via `ref.watch()`.

### Data layer

Repositories are annotated Riverpod classes that wrap Firestore/Storage. Real-time data comes from `.snapshots()` streams; write operations return `Future<void>`. No custom backend — Firebase is the only server.

### Navigation

GoRouter (`lib/core/router/router.dart`). Auth-based redirect is in the router's `redirect()` function watching `authStateChangesProvider`. Nested routes follow the pattern `/inspection/:inspectionId/room/:roomId`. Route parameters are passed via path; full objects via `extra`.

### Models

All domain models use `@freezed` + `@JsonSerializable`. Firestore `Timestamp` fields have custom converters. Generated files are `*.freezed.dart` and `*.g.dart` — do not edit them manually.

### Key feature notes

- **inspection_details**: most complex feature; handles rooms → items → photos with local optimistic state before Firestore sync.
- **reports**: `pdf_generator_service.dart` builds multi-page PDFs, downloads images in parallel, and uses the `pdf` + `printing` packages.
- **Offline**: `networkStatusProvider` streams connectivity; `OfflineBannerWrapper` shows a banner. Firestore offline persistence is enabled by default.
- **Firebase errors**: `lib/core/errors/firebase_errors.dart` maps Firebase error codes to user-facing messages.
