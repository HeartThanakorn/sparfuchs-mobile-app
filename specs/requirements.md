# Requirements Document

## Introduction

SparFuchs AI is a smart receipt scanning and expense tracking mobile application. The app uses AI-powered multimodal scanning (Gemini 2.5 Flash) to extract structured data from German receipts, with special handling for German-specific elements like Pfand (bottle deposits), VAT rates (7%/19%), and common retailer formats (Aldi, Lidl, Rewe, DM). The app is built with a local-first philosophy, ensuring data privacy and offline capability.

## Glossary

- **SparFuchs_App**: The mobile application built with Flutter (Dart) for iOS and Android
- **AI_Scanner**: The multimodal AI engine (Gemini 2.5 Flash) that processes receipt images
- **Receipt_Parser**: The component that converts AI output into structured Receipt data
- **Expense_Dashboard**: The analytics view showing spending charts and category breakdowns
- **Receipt_Archive**: The searchable digital storage for receipt images and extracted data
- **Category_Analysis**: The feature analyzing spending distribution across categories
- **Pfand**: German bottle deposit system (typically €0.25 per bottle)
- **LinesItem**: A single product entry on a receipt
- **Confidence_Score**: AI's certainty level (0.0-1.0) for parsed data accuracy

## Requirements

### Requirement 1: AI Receipt Scanning

**User Story:** As a user, I want to photograph a receipt and have the app automatically extract all purchase data, so that I can digitize my expenses without manual entry.

#### Acceptance Criteria

1. WHEN a user captures a receipt image, THE AI_Scanner SHALL process the image and return structured JSON within 5 seconds
2. WHEN processing a German receipt, THE Receipt_Parser SHALL extract merchant name, branch address, date, time, and payment method
3. WHEN processing line items, THE Receipt_Parser SHALL extract product description, quantity, unit price, and total price for each item
4. WHEN a receipt contains Pfand entries, THE Receipt_Parser SHALL identify and categorize them separately with type "pfand_bottle"
5. WHEN a receipt contains discounts, THE Receipt_Parser SHALL capture the discount amount and mark the item as discounted
6. WHEN processing German tax information, THE Receipt_Parser SHALL separate 7% (food) and 19% (general) VAT amounts
7. IF the AI_Scanner returns a confidence_score below 0.8, THEN THE SparFuchs_App SHALL display a "Review Needed" banner prompting manual verification
8. WHEN common German OCR errors occur (abbreviations like "Mwst", "Stk", "Pfd"), THE AI_Scanner SHALL correct them to full terms

### Requirement 2: Receipt Verification Flow

**User Story:** As a user, I want to review and correct AI-extracted data before saving, so that I can ensure accuracy of my expense records.

#### Acceptance Criteria

1. WHEN AI processing completes, THE SparFuchs_App SHALL display the Receipt Detail View with all extracted data
2. WHEN displaying items, THE SparFuchs_App SHALL show description, quantity, and total_price for each LineItem
3. WHEN an item has type "pfand_bottle", THE SparFuchs_App SHALL display it with a recycle icon and visual separation from groceries
4. WHEN an item has a discount, THE SparFuchs_App SHALL highlight the discount amount in a distinct color
5. WHEN displaying totals, THE SparFuchs_App SHALL show subtotal, pfand_total, and grand_total as separate line items
6. WHEN a user edits any field, THE SparFuchs_App SHALL recalculate affected totals automatically
7. WHEN a user confirms the receipt, THE SparFuchs_App SHALL persist both the image and structured data to Local Storage (Hive)

### Requirement 3: Expense Dashboard

**User Story:** As a user, I want to view my spending patterns through charts and category breakdowns, so that I can understand and manage my finances.

#### Acceptance Criteria

1. WHEN a user opens the dashboard, THE Expense_Dashboard SHALL display a monthly summary of total spending
2. WHEN displaying the summary, THE Expense_Dashboard SHALL show the currency formatted in Euro (€)
3. WHEN a user navigates to Statistics, THE SparFuchs_App SHALL show a bar chart of expenses over time
4. WHEN displaying category breakdowns, THE SparFuchs_App SHALL use distinct colors for Groceries, Household, Beverages, etc.
5. WHEN a user selects a Category, THE SparFuchs_App SHALL show a filtered list of receipts for that category

### Requirement 4: Digital Receipt Archive

**User Story:** As a user, I want to search and browse my saved receipts, so that I can find past purchases and reference them when needed.

#### Acceptance Criteria

1. WHEN a user opens the archive, THE Receipt_Archive SHALL display receipts sorted by date (newest first)
2. WHEN displaying a receipt entry, THE Receipt_Archive SHALL show merchant name, date, time, and grand_total
3. WHEN a user searches, THE Receipt_Archive SHALL filter by merchant name, product description, or date range
4. WHEN a user taps a receipt, THE Receipt_Archive SHALL display the full Receipt Detail View with original image
5. WHEN a user bookmarks a receipt, THE Receipt_Archive SHALL mark it for quick access in a Bookmarks view

### Requirement 5: Category Analysis

**User Story:** As a user, I want to see exactly how much I spend in specific categories like Groceries or Electronics, so I can budget better.

#### Acceptance Criteria

1. WHEN a user opens Category Analysis, THE SparFuchs_App SHALL display a Pie Chart of spending distribution
2. WHEN viewing the chart, THE SparFuchs_App SHALL show percentage labels for each category
3. WHEN a user scrolls down, THE SparFuchs_App SHALL display detailed cards for each category with total amount and percentage
4. THE App SHALL calculate these statistics locally based on stored receipts

### Requirement 6: Data Privacy & Local-First Architecture

**User Story:** As a user, I want my data stored locally on my device without cloud dependency, so that I maintain full control and privacy.

#### Acceptance Criteria

1. THE SparFuchs_App SHALL use a local-first architecture: Direct calls from Flutter to Gemini API
2. THE SparFuchs_App SHALL store all user data and receipt images in Hive (Local Database)
3. THE SparFuchs_App SHALL NOT require user authentication or login
4. THE SparFuchs_App SHALL NOT store receipt images on external servers (excluding transient processing by Gemini API)
5. WHEN a user clears data, THE SparFuchs_App SHALL permanently delete all local records

### Requirement 7: Localization

**User Story:** As a user, I want the app to handle German receipt formats correctly.

#### Acceptance Criteria

1. THE SparFuchs_App SHALL provide an English user interface
2. WHEN displaying currency, THE SparFuchs_App SHALL format amounts in Euro (€) with German locale (comma as decimal separator)
3. WHEN parsing receipts, THE AI_Scanner SHALL handle German product names and abbreviations

### Requirement 8: Settings & Preferences

**User Story:** As a user, I want to manage my app data.

#### Acceptance Criteria

1. WHEN a user opens Settings, THE SparFuchs_App SHALL display options to clear data or view storage usage
2. WHEN a user taps "Clear All Data", THE SparFuchs_App SHALL show a confirmation dialog
3. WHEN confirmed, THE SparFuchs_App SHALL wipe all data from Hive

### Requirement 9: Receipt Data Serialization

**User Story:** As a developer, I want consistent data serialization for receipts, so that data integrity is maintained across the system.

#### Acceptance Criteria

1. WHEN storing a receipt, THE Receipt_Parser SHALL serialize it to the defined JSON schema
2. WHEN retrieving a receipt, THE Receipt_Parser SHALL deserialize JSON back to Receipt object
3. FOR ALL valid Receipt objects, serializing then deserializing SHALL produce an equivalent object (round-trip property)
4. WHEN AI returns malformed JSON, THE Receipt_Parser SHALL return a descriptive error with the parsing failure location
5. THE Receipt_Parser SHALL conform to the following JSON Schema:

```json
{
  "receipt_data": {
    "merchant": {
      "name": "string", // e.g., "Lidl"
      "branch_id": "string", // e.g., "DE-12345"
      "address": "string", // e.g., "Berliner Str. 10, 10115 Berlin"
      "raw_text": "string" // e.g., "Lidl Vertriebs-GmbH & Co. KG"
    },
    "transaction": {
      "date": "string", // ISO format: "2025-06-16"
      "time": "string", // 24h format: "15:00:00"
      "currency": "EUR",
      "payment_method": "string" // "CASH" | "CARD"
    },
    "items": [
      {
        "description": "string", // Product name
        "category": "string", // "Groceries" | "Beverages" | "Snacks" | "Household" | "Electronics" | "Fashion" | "Deposit"
        "quantity": "number",
        "unit_price": "number",
        "total_price": "number",
        "discount": "number", // Optional: negative value, e.g., -0.90
        "is_discounted": "boolean",
        "type": "string", // Optional: "pfand_bottle" for Pfand items
        "tags": ["string"] // Optional: ["soft_drink", "sugary"]
      }
    ],
    "totals": {
      "subtotal": "number",
      "pfand_total": "number", // Separated Pfand deposit total
      "tax_amount": "number",
      "grand_total": "number"
    },
    "taxes": [
      {
        "rate": "number", // 7.0 for food, 19.0 for general goods
        "amount": "number"
      }
    ],
    "ai_metadata": {
      "confidence_score": "number", // 0.0-1.0, alert if < 0.8
      "model_used": "string", // "gemini-2.5-flash"
      "processing_time_ms": "number"
    }
  }
}
```
