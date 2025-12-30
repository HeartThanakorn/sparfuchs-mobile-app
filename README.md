# SparFuchs AI - Smart Receipt Scanner & Expense Tracker 🦊

## 🚀 Project Overview

SparFuchs AI is a Flutter-based mobile application designed to outperform existing solutions like "Bonsy" in the German market. It leverages AI (Gemini 3 Flash / GPT-4o) via self-hosted n8n workflows to parse German receipts with high accuracy, handling specific local nuances like "Pfand" (bottle deposits), dual VAT rates (7%/19%), and common OCR errors.

**Target Market:** DACH Region (Germany, Austria, Switzerland)  
**Languages:** German & English  
**Currency:** Euro (€)

## ✨ Key Features

### Core Features (Bonsy Parity)

- **AI Camera Scanner** - Instantly digitizes receipts from German supermarkets (Aldi, Lidl, Rewe, DM, Edeka, Penny, Netto, Kaufland)
- **German-Specific Parsing** - Accurately separates **Pfand** (deposits) from line items with ♻️ visual indicators
- **Expense Dashboard** - Monthly charts with category breakdown (Groceries, Household, Beverages, etc.)
- **Digital Archive** - Searchable receipt storage with bookmarks
- **Household Sharing** - Multi-user sync for couples/families

### Killer Features (Differentiation)

- **🔥 Inflation Tracker** - Track product price history over time, compare across merchants
- **🍳 Smart Recipe Suggestions** - AI suggests 3 recipes based on purchased groceries
- **⏰ Warranty & Return Monitor** - Auto-detects electronics/clothing, sets 14-day return & 2-year warranty reminders

## 🛠 Tech Stack

| Layer         | Technology                                              |
| ------------- | ------------------------------------------------------- |
| **Frontend**  | Flutter (Dart) with Riverpod                            |
| **Backend**   | n8n Workflows (Self-hosted on Hostinger VPS via Docker) |
| **AI Engine** | Gemini 3 Flash (Google AI Studio) / GPT-4o fallback     |
| **Database**  | Firestore (NoSQL)                                       |
| **Storage**   | Firebase Cloud Storage                                  |
| **Auth**      | Firebase Authentication                                 |

## 📂 Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│  n8n Workflow   │────▶│   Gemini 3 AI   │
│   (Client)      │     │  (Hostinger VPS)│     │   (Google API)  │
└────────┬────────┘     └────────┬────────┘     └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│    Firestore    │◀────│  JSON Validator │
│   (Real-time)   │     │   & Enricher    │
└─────────────────┘     └─────────────────┘
```

This project follows **Clean Architecture** principles with feature-based folder structure.

## 📋 Specification Documents

Complete project specifications are available in `.kiro/specs/sparfuchs-ai/`:

| Document                                                      | Description                                             |
| ------------------------------------------------------------- | ------------------------------------------------------- |
| [`requirements.md`](.kiro/specs/sparfuchs-ai/requirements.md) | 11 requirements with EARS-pattern acceptance criteria   |
| [`design.md`](.kiro/specs/sparfuchs-ai/design.md)             | Technical design, Firestore schema, UI flows, AI prompt |
| [`tasks.md`](.kiro/specs/sparfuchs-ai/tasks.md)               | 20 implementation tasks with Copilot prompts            |

## 🎨 Design System

**Color Palette (Fintech-Inspired)**

| Color          | Hex       | Usage                    |
| -------------- | --------- | ------------------------ |
| Primary Teal   | `#4ECDC4` | Primary actions, headers |
| Dark Navy      | `#2C3E50` | Text, icons              |
| Light Mint     | `#E8F8F5` | Backgrounds              |
| Success Green  | `#27AE60` | Savings, positive        |
| Warning Orange | `#F39C12` | Alerts                   |
| Error Red      | `#E74C3C` | Errors, price increases  |

**Typography:** Poppins (Headlines), Inter (Body), SF Mono (Numbers)

## 🚦 Getting Started

### Prerequisites

- Flutter SDK 3.x
- Firebase CLI
- Docker & Docker Compose (for VPS)
- Google AI Studio API key (Gemini 3 Flash)

### Installation

```bash
# Clone repository
git clone https://github.com/your-org/sparfuchs-ai.git
cd sparfuchs-ai

# Install dependencies
flutter pub get

# Configure Firebase
flutterfire configure

# Run app
flutter run
```

## 📄 License

Copyright © 2025 Thanakorn Thajan. All rights reserved.

This project is proprietary software. Unauthorized copying, modification, distribution, or use of this file and the source code, via any medium, is strictly prohibited.

## 🤝 Contributing

See `.specs/tasks.md` for the implementation roadmap.
