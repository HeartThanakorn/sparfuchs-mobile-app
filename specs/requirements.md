# Requirements Document

## Introduction

SparFuchs AI is a German receipt scanning and expense tracking mobile application targeting the DACH region. The app uses AI-powered multimodal scanning (GPT-4o/Claude 3.5 Sonnet) to extract structured data from German receipts, with special handling for German-specific elements like Pfand (bottle deposits), VAT rates (7%/19%), and common retailer formats (Aldi, Lidl, Rewe, DM). The app differentiates from competitors like "Bonsy Bon Scan" through killer features: Inflation Tracker, Smart Recipe Suggestions, and Warranty/Return Monitoring.

## Glossary

- **SparFuchs_App**: The mobile application built with Flutter (Dart) for iOS and Android
- **AI_Scanner**: The multimodal AI engine (GPT-4o or Claude 3.5 Sonnet) that processes receipt images
- **Receipt_Parser**: The component that converts AI output into structured Receipt data
- **Expense_Dashboard**: The analytics view showing spending charts and category breakdowns
- **Receipt_Archive**: The searchable digital storage for receipt images and extracted data
- **Household_Manager**: The component managing multi-user account sharing and sync
- **Inflation_Tracker**: The feature tracking product price changes over time
- **Recipe_Engine**: The AI component suggesting recipes based on purchased groceries
- **Warranty_Monitor**: The component detecting electronics/clothing and setting return/warranty reminders
- **Pfand**: German bottle deposit system (typically €0.25 per bottle)
- **LineItem**: A single product entry on a receipt
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
7. WHEN a user confirms the receipt, THE SparFuchs_App SHALL persist both the image and structured data to Firestore

### Requirement 3: Expense Dashboard

**User Story:** As a user, I want to view my spending patterns through charts and category breakdowns, so that I can understand and manage my finances.

#### Acceptance Criteria

1. WHEN a user opens the dashboard, THE Expense_Dashboard SHALL display a bar chart of expenses by time period (Days/Weeks/Months)
2. WHEN displaying the chart, THE Expense_Dashboard SHALL stack categories with distinct colors (Groceries, Household, Beverages, Housing & Living, Electronics, Fashion, Mobility)
3. WHEN a user selects a time period, THE Expense_Dashboard SHALL show category breakdown with percentage and Euro amount
4. WHEN displaying category totals, THE Expense_Dashboard SHALL calculate percentages relative to total spending
5. WHEN a user taps a category, THE Expense_Dashboard SHALL navigate to filtered receipt list for that category

### Requirement 4: Digital Receipt Archive

**User Story:** As a user, I want to search and browse my saved receipts, so that I can find past purchases and reference them when needed.

#### Acceptance Criteria

1. WHEN a user opens the archive, THE Receipt_Archive SHALL display receipts sorted by date (newest first)
2. WHEN displaying a receipt entry, THE Receipt_Archive SHALL show merchant name, date, time, and grand_total
3. WHEN a user searches, THE Receipt_Archive SHALL filter by merchant name, product description, or date range
4. WHEN a user taps a receipt, THE Receipt_Archive SHALL display the full Receipt Detail View with original image
5. WHEN a user bookmarks a receipt, THE Receipt_Archive SHALL mark it for quick access in a Bookmarks view

### Requirement 5: Household Sharing

**User Story:** As a household member, I want to share expense data with my partner/family, so that we can track our combined spending.

#### Acceptance Criteria

1. WHEN a user creates a household, THE Household_Manager SHALL generate a unique invite code
2. WHEN a user joins via invite code, THE Household_Manager SHALL link their account to the household
3. WHEN any household member scans a receipt, THE Household_Manager SHALL sync it to all members
4. WHEN displaying shared receipts, THE SparFuchs_App SHALL show the member avatar who scanned it
5. WHEN viewing the dashboard, THE Expense_Dashboard SHALL aggregate spending from all household members
6. IF a user leaves a household, THEN THE Household_Manager SHALL retain their personal receipts but remove shared access

### Requirement 6: Inflation Tracker (Killer Feature)

**User Story:** As a price-conscious shopper, I want to track how specific product prices change over time, so that I can identify inflation trends and find the best deals.

#### Acceptance Criteria

1. WHEN a product is scanned multiple times, THE Inflation_Tracker SHALL record each price point with date and merchant
2. WHEN a user views a product, THE Inflation_Tracker SHALL display a price history chart
3. WHEN prices increase significantly (>10%), THE Inflation_Tracker SHALL highlight the change with a warning indicator
4. WHEN a user searches for a product, THE Inflation_Tracker SHALL show price comparison across different merchants
5. WHEN displaying price history, THE Inflation_Tracker SHALL calculate and show percentage change over selected period

### Requirement 7: Smart Recipe Suggestions (Killer Feature)

**User Story:** As a home cook, I want recipe suggestions based on my grocery purchases, so that I can make the most of ingredients I just bought.

#### Acceptance Criteria

1. WHEN a receipt is confirmed, THE Recipe_Engine SHALL analyze food items and suggest 3 relevant recipes
2. WHEN suggesting recipes, THE Recipe_Engine SHALL prioritize recipes using multiple purchased ingredients
3. WHEN displaying a recipe suggestion, THE SparFuchs_App SHALL show recipe name, image thumbnail, and matched ingredients
4. WHEN a user taps a recipe, THE SparFuchs_App SHALL display full recipe details or link to external source
5. IF no food items are detected, THEN THE Recipe_Engine SHALL skip recipe suggestions for that receipt

### Requirement 8: Warranty & Return Monitor (Killer Feature)

**User Story:** As a consumer, I want automatic reminders for return windows and warranty expiration, so that I never miss a deadline for returns or warranty claims.

#### Acceptance Criteria

1. WHEN electronics or clothing items are detected, THE Warranty_Monitor SHALL flag them for tracking
2. WHEN an item is flagged, THE Warranty_Monitor SHALL set a 14-day return window reminder
3. WHEN an electronics item is detected, THE Warranty_Monitor SHALL set a 2-year warranty expiry reminder
4. WHEN a reminder date approaches (3 days before), THE SparFuchs_App SHALL send a push notification
5. WHEN a user views tracked items, THE Warranty_Monitor SHALL display days remaining for return/warranty
6. WHEN a user marks an item as returned, THE Warranty_Monitor SHALL cancel associated reminders

### Requirement 9: Data Privacy & GDPR Compliance (Self-Hosted Hybrid)

**User Story:** As a German user, I want my data handled according to GDPR regulations with full control over processing, so that my privacy is protected.

#### Acceptance Criteria

1. THE SparFuchs_App SHALL use a self-hosted hybrid architecture: n8n workflows on Hostinger VPS (Dockerized) for AI processing, Firestore for mobile sync
2. WHEN processing receipt images, THE n8n_Workflow SHALL handle AI API calls on the self-hosted VPS to maintain data control
3. THE SparFuchs_App SHALL store user sync data in Firestore while keeping AI processing logs on the VPS
4. WHEN a user requests data export, THE SparFuchs_App SHALL provide all personal data in machine-readable format within 30 days
5. WHEN a user requests account deletion, THE SparFuchs_App SHALL permanently delete all user data from both Firestore and VPS within 30 days
6. THE SparFuchs_App SHALL display clear privacy policy and obtain explicit consent before data collection
7. WHEN processing receipt images, THE AI_Scanner SHALL not retain images on external AI provider servers after processing

### Requirement 10: Localization

**User Story:** As a DACH region user, I want the app in my preferred language with proper currency formatting, so that I can use it comfortably.

#### Acceptance Criteria

1. THE SparFuchs_App SHALL support English and German language interfaces
2. WHEN displaying currency, THE SparFuchs_App SHALL format amounts in Euro (€) with German locale (comma as decimal separator)
3. WHEN displaying dates, THE SparFuchs_App SHALL use German format (DD.MM.YYYY)
4. WHEN parsing receipts, THE AI_Scanner SHALL handle German product names, abbreviations, and special characters (ä, ö, ü, ß)

### Requirement 11: Receipt Data Serialization

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
      "model_used": "string", // "gpt-4o" | "claude-3.5-sonnet"
      "processing_time_ms": "number"
    }
  }
}
```
