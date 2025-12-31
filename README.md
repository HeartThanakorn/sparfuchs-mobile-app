# SparFuchs AI

A receipt scanning and expense tracking app for the German market. Built with Flutter and powered by Gemini 2.5 Flash for accurate German receipt parsing.

## What it does

SparFuchs AI takes a photo of your receipt and automatically extracts all the purchase data. It handles German-specific things like Pfand (bottle deposits), the two VAT rates (7% and 19%), and common OCR errors from receipt printers.

### Core functionality

- Camera-based receipt scanning with AI extraction
- Expense dashboard with category breakdowns
- Searchable receipt archive
- Household sharing for couples/families
- Inflation tracker (price history over time)
- Recipe suggestions based on purchased groceries
- Warranty and return deadline reminders

## Tech stack

| Component | Technology |
|-----------|------------|
| Frontend | Flutter (Dart) with Riverpod |
| AI | Gemini 2.5 Flash (Direct REST API) |
| Database | Firestore (Production Mode) |
| Storage | Firebase Cloud Storage (Primary) / Local Device Storage (Fallback) |
| Auth | Firebase Authentication |

## Architecture

```
Flutter App  -->  Gemini 2.5 Flash API  -->  Firestore
                      (direct call)
```

No backend server required. The app calls the Gemini API directly from Flutter, which keeps things simple and free.

## Project structure

```
lib/
  core/           # Shared models, utils, config
  features/       # Feature-based modules
    receipt/      # Scanning, archive, verification
    dashboard/    # Expense charts and stats
    household/    # Multi-user sharing
    inflation/    # Price tracking
    recipe/       # Recipe suggestions
    warranty/     # Return/warranty reminders
    gdpr/         # Data export and deletion
```

## Getting started

### Requirements

- Flutter SDK 3.x
- A Gemini API key from Google AI Studio

### Setup

```bash
git clone https://github.com/HeartThanakorn/sparfuchs-mobile-app.git
cd sparfuchs-mobile-app

flutter pub get

# Create .env file with your API key
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY

flutter run
```

For release builds, pass the API key at compile time:

```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_key_here
```

## Testing

```bash
flutter test
```

Currently has 187 tests covering receipt parsing, household membership, search/filter, GDPR compliance, and more.

## Specs

The full specification documents are in `specs/`:

- `requirements.md` - Feature requirements
- `design.md` - Technical design and data models
- `tasks.md` - Implementation checklist

## License

Copyright 2025 Thanakorn Thajan. All rights reserved.

Proprietary software. Do not copy, modify, or distribute without permission.
