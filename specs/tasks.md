# Implementation Plan: SparFuchs AI

## Overview

This implementation plan breaks down the SparFuchs AI receipt scanning app into four phases: Infrastructure & Backend, Flutter App Skeleton & Camera, UI Implementation, and Logic & Polish. Each task includes a Copilot Prompt for direct code generation.

**Tech Stack:**

- Frontend: Flutter (Dart)
- Backend: n8n (self-hosted on Hostinger VPS via Docker)
- AI: Gemini 3 Flash (Google AI Studio API) or GPT-4o fallback
- Database: Firestore
- Storage: Firebase Cloud Storage

## Tasks

### Phase 1: Infrastructure & Backend (The Foundation)

- [ ] 1. Set up VPS and deploy n8n

  - [ ] 1.1 Configure Hostinger VPS with Docker & Docker Compose

    - SSH into VPS, install Docker Engine and Docker Compose
    - Create docker-compose.yml for n8n with persistent volumes
    - Configure nginx reverse proxy with SSL (Let's Encrypt)
    - **Copilot Prompt:** `Create a docker-compose.yml for n8n with traefik reverse proxy, SSL, and persistent PostgreSQL database`
    - _Requirements: 9.1, 9.2_

  - [ ] 1.2 Deploy n8n self-hosted instance
    - Pull n8n Docker image and start container
    - Configure environment variables (N8N_HOST, WEBHOOK_URL)
    - Set up basic authentication for n8n dashboard
    - **Copilot Prompt:** `Create n8n environment configuration with webhook URL, encryption key, and timezone settings for German locale`
    - _Requirements: 9.1, 9.2_

- [ ] 2. Configure Firebase infrastructure

  - [ ] 2.1 Set up Firestore security rules

    - Create rules for users, households, receipts, products, warranty_items collections
    - Implement household-based access control
    - **Copilot Prompt:** `Write Firestore security rules where users can read/write their own receipts, and household members can read receipts with matching household_id`
    - _Requirements: 5.3, 5.6, 9.3_

  - [ ] 2.2 Create Firestore indexes
    - Composite indexes for receipt queries (household_id + date, user_id + date)
    - Index for product price_history queries
    - **Copilot Prompt:** `Create firestore.indexes.json with composite indexes for receipts by household_id and transaction.date descending`
    - _Requirements: 4.1, 4.3_

- [ ] 3. Create n8n Receipt Scanning Workflow

  - [ ] 3.1 Implement Webhook Node for image receipt

    - Configure POST endpoint /webhook/scan-receipt
    - Accept image_url, user_id, household_id, language parameters
    - **Copilot Prompt:** `Create n8n webhook node configuration that accepts JSON body with image_url, user_id, household_id fields`
    - _Requirements: 1.1_

  - [ ] 3.2 Implement AI Node with Gemini 3 Flash

    - Configure HTTP Request to Google AI Studio API (generativelanguage.googleapis.com)
    - Send image as base64 with the "Golden Prompt" from design
    - Handle multimodal input (image + text prompt)
    - **Copilot Prompt:** `Create n8n HTTP Request node to call Gemini 3 Flash API with multimodal input: base64 image and system prompt for German receipt parsing`
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.6, 1.8_

  - [ ] 3.3 Implement JSON Validation Node

    - Validate AI response matches receipt_data schema
    - Add confidence_score threshold check
    - Enrich with processing_time_ms and model_used
    - **Copilot Prompt:** `Create n8n Function node that validates receipt JSON schema, checks confidence_score >= 0.5, and adds ai_metadata.processing_time_ms`
    - _Requirements: 1.7, 11.1_

  - [ ] 3.4 Implement Firestore Write Node

    - Write validated receipt to receipts collection
    - Generate unique receipt_id
    - Set created_at and updated_at timestamps
    - **Copilot Prompt:** `Create n8n Firestore node to write receipt document with auto-generated ID, timestamps, and return receipt_id in response`
    - _Requirements: 2.7_

  - [ ] 3.5 Write property test for JSON validation

    - **Property 7: Receipt Serialization Round-Trip**
    - **Validates: Requirements 2.7, 11.1, 11.2, 11.3**

  - [ ] 3.6 Write property test for malformed JSON handling
    - **Property 24: Malformed JSON Error Handling**
    - **Validates: Requirements 11.4**

- [ ] 4. Checkpoint - Verify n8n workflow
  - Test webhook with sample receipt image
  - Verify Firestore document creation
  - Ensure all tests pass, ask the user if questions arise.

### Phase 2: Flutter App Skeleton & Camera

- [ ] 5. Initialize Flutter project structure

  - [ ] 5.1 Create Flutter project with Clean Architecture

    - Set up folder structure: lib/core, lib/features, lib/shared
    - Configure pubspec.yaml with dependencies (firebase_core, cloud_firestore, camera, http)
    - **Copilot Prompt:** `Create Flutter Clean Architecture folder structure with features/receipt, features/dashboard, features/household, core/services, shared/widgets directories`
    - _Requirements: 10.1_

  - [ ] 5.2 Implement Receipt data models in Dart

    - Create Receipt, ReceiptData, LineItem, Merchant, Transaction, Totals, TaxEntry, AiMetadata classes
    - Implement fromJson/toJson serialization
    - Add isPfand and needsReview computed properties
    - **Copilot Prompt:** `Create Dart freezed classes for Receipt with nested ReceiptData, LineItem with isPfand getter returning type == 'pfand_bottle', and AiMetadata with needsReview getter for confidence < 0.8`
    - _Requirements: 11.1, 11.2, 11.3_

  - [ ] 5.3 Write property test for Receipt serialization round-trip
    - **Property 7: Receipt Serialization Round-Trip**
    - **Validates: Requirements 2.7, 11.1, 11.2, 11.3**

- [ ] 6. Implement Camera functionality

  - [ ] 6.1 Create CameraService

    - Implement captureImage() with camera package
    - Implement pickFromGallery() with image_picker
    - Add image compression (max 1MB for API efficiency)
    - **Copilot Prompt:** `Create Flutter CameraService class with captureImage() using camera package, pickFromGallery() using image_picker, and compressImage() reducing to max 1MB using flutter_image_compress`
    - _Requirements: 1.1_

  - [ ] 6.2 Build Camera Screen UI
    - Full-screen camera preview with receipt guide overlay
    - Bottom bar with Gallery, Capture, Flash buttons
    - **Copilot Prompt:** `Create Flutter CameraScreen widget with CameraPreview, blue rectangle overlay guide for receipt alignment, and bottom action bar with IconButtons for gallery, capture, and flash toggle`
    - _Requirements: 1.1_

- [ ] 7. Implement Receipt Repository

  - [ ] 7.1 Create ReceiptRepository with image upload

    - Upload image to Firebase Storage
    - Return download URL
    - **Copilot Prompt:** `Create Flutter ReceiptRepository with uploadImage(File) method that uploads to Firebase Storage path 'receipts/{userId}/{timestamp}.jpg' and returns download URL`
    - _Requirements: 2.7_

  - [ ] 7.2 Implement scanReceipt API call to n8n

    - POST to n8n webhook with image_url
    - Parse response into Receipt object
    - Handle errors (timeout, invalid JSON)
    - **Copilot Prompt:** `Create scanReceipt(String imageUrl, String userId) method that POSTs to n8n webhook, parses receipt_data JSON response into Receipt object, throws ReceiptParseException on error`
    - _Requirements: 1.1, 1.2, 1.3_

  - [ ] 7.3 Write property test for Pfand classification

    - **Property 2: Pfand Item Classification**
    - **Validates: Requirements 1.4**

  - [ ] 7.4 Write property test for discount consistency
    - **Property 3: Discount Field Consistency**
    - **Validates: Requirements 1.5**

- [ ] 8. Checkpoint - Camera to API flow
  - Test camera capture → upload → n8n → Firestore flow
  - Verify Receipt object parsing
  - Ensure all tests pass, ask the user if questions arise.

### Phase 3: UI Implementation (Screens)

- [ ] 9. Build Verification Screen (Receipt Detail View)

  - [ ] 9.1 Create VerificationScreen layout

    - Review Needed banner (conditional on confidence < 0.8)
    - Purchase Info card (merchant, date, time, discount, sum)
    - **Copilot Prompt:** `Create Flutter VerificationScreen with conditional ReviewNeededBanner when receipt.aiMetadata.needsReview, PurchaseInfoCard showing merchant name with logo placeholder, date in DD.MM.YYYY format, time, and grand_total`
    - _Requirements: 1.7, 2.1, 2.2, 2.5_

  - [ ] 9.2 Implement LineItem list with Pfand separation

    - Regular items section
    - Visual separator with recycle icon for Deposit section
    - Pfand items with ♻️ icon and distinct background color
    - **Copilot Prompt:** `Create Flutter ItemsList widget that separates items into two sections: regular items and Pfand items (where item.isPfand), with a 'DEPOSIT' header and RecycleIcon for Pfand section, each item showing description, quantity x unit_price, and total_price`
    - _Requirements: 2.2, 2.3_

  - [ ] 9.3 Implement discount highlighting

    - Show discount amount in red/green next to discounted items
    - Display original price struck through
    - **Copilot Prompt:** `Create Flutter LineItemTile that shows discount amount in Colors.red with '-' prefix when item.isDiscounted, positioned next to the total_price`
    - _Requirements: 2.4_

  - [ ] 9.4 Implement Totals section

    - Subtotal, Pfand Total (with ♻️), Grand Total
    - German number formatting (1.234,56 €)
    - **Copilot Prompt:** `Create Flutter TotalsCard showing subtotal, pfand_total with recycle icon, and grand_total with German locale NumberFormat using comma as decimal separator and € suffix`
    - _Requirements: 2.5, 10.2_

  - [ ] 9.5 Implement editable fields with recalculation

    - Tap to edit quantity, unit_price
    - Auto-recalculate total_price and totals on change
    - **Copilot Prompt:** `Create Flutter EditableLineItem with TextFormFields for quantity and unit_price that trigger onChanged callback to recalculate total_price = quantity * unit_price - discount`
    - _Requirements: 2.6_

  - [ ] 9.6 Write property test for total recalculation

    - **Property 6: Total Recalculation on Edit**
    - **Validates: Requirements 2.6**

  - [ ] 9.7 Write property test for confidence score review trigger
    - **Property 5: Confidence Score Review Trigger**
    - **Validates: Requirements 1.7**

- [ ] 10. Build Dashboard Screen

  - [ ] 10.1 Create Dashboard layout with time period tabs

    - Days/Weeks/Months toggle
    - Date display and total amount
    - **Copilot Prompt:** `Create Flutter DashboardScreen with ToggleButtons for Days/Weeks/Months, current date display, and total spending amount in Euro`
    - _Requirements: 3.1_

  - [ ] 10.2 Implement stacked bar chart with fl_chart

    - Category colors matching design palette
    - Monthly expense bars
    - **Copilot Prompt:** `Create Flutter ExpenseChart using fl_chart BarChart with stacked bars, each segment colored by category (Groceries=#4ECDC4, Household=#F39C12, Beverages=#3498DB, etc.), x-axis showing month names`
    - _Requirements: 3.2_

  - [ ] 10.3 Implement category breakdown list

    - Percentage, category name, Euro amount
    - Tap to filter receipts by category
    - **Copilot Prompt:** `Create Flutter CategoryBreakdownList with ListTiles showing percentage badge, category name, and amount, onTap navigates to ReceiptListScreen filtered by category`
    - _Requirements: 3.3, 3.4, 3.5_

  - [ ] 10.4 Write property test for category percentage calculation
    - **Property 8: Category Percentage Calculation**
    - **Validates: Requirements 3.3, 3.4**

- [ ] 11. Build Receipt Archive Screen

  - [ ] 11.1 Create ReceiptArchiveScreen with list

    - Receipts sorted by date (newest first)
    - Show merchant, date, time, grand_total
    - Member avatar for household receipts
    - **Copilot Prompt:** `Create Flutter ReceiptArchiveScreen with StreamBuilder listening to Firestore receipts ordered by transaction.date descending, ListTile showing merchant name, date, time, grand_total, and CircleAvatar for scanned_by user`
    - _Requirements: 4.1, 4.2, 5.4_

  - [ ] 11.2 Implement search functionality

    - Search by merchant name, product description, date range
    - **Copilot Prompt:** `Create Flutter ReceiptSearchDelegate with SearchBar that filters receipts where merchant.name contains query OR any item.description contains query, with DateRangePicker for date filtering`
    - _Requirements: 4.3_

  - [ ] 11.3 Implement bookmark functionality

    - Bookmark icon toggle on receipt
    - Bookmarks tab/filter
    - **Copilot Prompt:** `Create Flutter BookmarkButton IconButton that toggles receipt.isBookmarked in Firestore, with filled/outlined icon state, and BookmarksView filtering where isBookmarked == true`
    - _Requirements: 4.5_

  - [ ] 11.4 Write property test for archive sort order

    - **Property 9: Receipt Archive Sort Order**
    - **Validates: Requirements 4.1**

  - [ ] 11.5 Write property test for search filter accuracy

    - **Property 10: Search Filter Accuracy**
    - **Validates: Requirements 4.3**

  - [ ] 11.6 Write property test for bookmark persistence
    - **Property 11: Bookmark Persistence**
    - **Validates: Requirements 4.5**

- [ ] 12. Build Inflation Tracker Screen

  - [ ] 12.1 Create InflationTrackerScreen with search

    - Product search bar
    - Trending price changes section
    - Tracked products list
    - **Copilot Prompt:** `Create Flutter InflationTrackerScreen with SearchBar for products, TrendingPriceChanges section showing products with >10% price change, and TrackedProductsList from user's scanned products`
    - _Requirements: 6.1, 6.3_

  - [ ] 12.2 Implement ProductDetailScreen with price chart

    - Line chart showing price history over time
    - Price by merchant comparison
    - **Copilot Prompt:** `Create Flutter ProductDetailScreen with fl_chart LineChart plotting price_history dates on x-axis and prices on y-axis, and MerchantPriceList showing latest price per merchant with 'Cheapest' badge`
    - _Requirements: 6.2, 6.4_

  - [ ] 12.3 Implement price change percentage calculation

    - Calculate and display percentage change
    - Warning indicator for >10% increase
    - **Copilot Prompt:** `Create Flutter PriceChangeIndicator that calculates ((newPrice - oldPrice) / oldPrice * 100), displays with up/down arrow icon, red color for increases >10%`
    - _Requirements: 6.5, 6.3_

  - [ ] 12.4 Write property test for price history recording

    - **Property 17: Price History Recording**
    - **Validates: Requirements 6.1**

  - [ ] 12.5 Write property test for inflation alert threshold

    - **Property 18: Inflation Alert Threshold**
    - **Validates: Requirements 6.3**

  - [ ] 12.6 Write property test for price comparison calculation
    - **Property 19: Price Comparison and Percentage Calculation**
    - **Validates: Requirements 6.4, 6.5**

- [ ] 13. Checkpoint - UI screens complete
  - Test all screens with mock data
  - Verify German locale formatting
  - Ensure all tests pass, ask the user if questions arise.

### Phase 4: Logic & Polish

- [ ] 14. Implement state management

  - [ ] 14.1 Set up Riverpod providers

    - ReceiptProvider, HouseholdProvider, UserProvider
    - **Copilot Prompt:** `Create Flutter Riverpod providers: receiptProvider as StreamProvider listening to Firestore receipts, householdProvider for current household, userProvider for authenticated user`
    - _Requirements: 2.6_

  - [ ] 14.2 Implement receipt editing state
    - Local state for editing receipt before save
    - Recalculation logic for totals
    - **Copilot Prompt:** `Create Flutter Riverpod StateNotifier for ReceiptEditState with methods updateItemQuantity(itemId, quantity), updateItemPrice(itemId, price) that recalculate totals.subtotal and totals.grandTotal`
    - _Requirements: 2.6_

- [ ] 15. Implement Household Sharing

  - [ ] 15.1 Create HouseholdRepository

    - createHousehold(), joinHousehold(code), leaveHousehold()
    - Generate unique 8-character invite codes
    - **Copilot Prompt:** `Create Flutter HouseholdRepository with createHousehold(name) generating unique join_code using nanoid, joinHousehold(code) adding user to members array, leaveHousehold() removing user and clearing household_id`
    - _Requirements: 5.1, 5.2, 5.6_

  - [ ] 15.2 Implement household receipt sync

    - Query receipts by household_id
    - Real-time sync with StreamBuilder
    - **Copilot Prompt:** `Create Flutter HouseholdReceiptsStream that queries Firestore receipts where household_id equals current user's household_id, ordered by date descending`
    - _Requirements: 5.3_

  - [ ] 15.3 Implement household spending aggregation

    - Sum grand_total for all household receipts
    - Display in dashboard
    - **Copilot Prompt:** `Create Flutter HouseholdSpendingCalculator that sums grand_total from all receipts with matching household_id for the selected time period`
    - _Requirements: 5.5_

  - [ ] 15.4 Write property test for invite code uniqueness

    - **Property 12: Household Invite Code Uniqueness**
    - **Validates: Requirements 5.1**

  - [ ] 15.5 Write property test for household membership

    - **Property 13: Household Membership After Join**
    - **Validates: Requirements 5.2**

  - [ ] 15.6 Write property test for household receipt sync

    - **Property 14: Household Receipt Sync**
    - **Validates: Requirements 5.3**

  - [ ] 15.7 Write property test for household spending aggregation

    - **Property 15: Household Spending Aggregation**
    - **Validates: Requirements 5.5**

  - [ ] 15.8 Write property test for household leave data isolation
    - **Property 16: Household Leave Data Isolation**
    - **Validates: Requirements 5.6**

- [ ] 16. Implement Recipe Suggestions

  - [ ] 16.1 Create RecipeService

    - Extract food items from receipt
    - Call recipe API (or n8n workflow)
    - Return 3 recipe suggestions sorted by ingredient match
    - **Copilot Prompt:** `Create Flutter RecipeService with suggestRecipes(List<LineItem> items) that filters food categories, calls n8n /webhook/suggest-recipes, returns List<Recipe> sorted by matchedIngredients.length descending, limited to 3`
    - _Requirements: 7.1, 7.2_

  - [ ] 16.2 Build RecipeSuggestionsSheet

    - Bottom sheet modal after receipt save
    - Recipe cards with image, name, matched ingredients
    - **Copilot Prompt:** `Create Flutter RecipeSuggestionsBottomSheet showing 3 RecipeCards with thumbnail image, recipe name, 'Uses: ingredient1, ingredient2' text, cooking time and servings badges`
    - _Requirements: 7.3, 7.4_

  - [ ] 16.3 Write property test for recipe suggestion count
    - **Property 20: Recipe Suggestion Count and Relevance**
    - **Validates: Requirements 7.1, 7.2**

- [ ] 17. Implement Warranty Monitor

  - [ ] 17.1 Create WarrantyService

    - Detect electronics/fashion items from receipt
    - Create warranty_item records with reminders
    - **Copilot Prompt:** `Create Flutter WarrantyService with trackWarrantyItems(Receipt) that filters items where category is 'Electronics' or 'Fashion', creates warranty_item document with return_deadline = purchaseDate + 14 days, warranty_expiry = purchaseDate + 2 years for Electronics`
    - _Requirements: 8.1, 8.2, 8.3_

  - [ ] 17.2 Build WarrantyListScreen

    - List tracked items with days remaining
    - Mark as returned functionality
    - **Copilot Prompt:** `Create Flutter WarrantyListScreen showing warranty_items with item_description, days remaining until return_deadline and warranty_expiry, SwipeAction to mark as returned updating status to 'returned'`
    - _Requirements: 8.5, 8.6_

  - [ ] 17.3 Implement push notification reminders

    - Schedule local notifications 3 days before deadlines
    - **Copilot Prompt:** `Create Flutter WarrantyNotificationService using flutter_local_notifications to schedule notification 3 days before return_deadline and warranty_expiry dates`
    - _Requirements: 8.4_

  - [ ] 17.4 Write property test for warranty detection and reminders

    - **Property 21: Warranty Item Detection and Reminder Setup**
    - **Validates: Requirements 8.1, 8.2, 8.3**

  - [ ] 17.5 Write property test for days remaining calculation

    - **Property 22: Days Remaining Calculation**
    - **Validates: Requirements 8.5**

  - [ ] 17.6 Write property test for reminder cancellation
    - **Property 23: Reminder Cancellation on Return**
    - **Validates: Requirements 8.6**

- [ ] 18. Implement Localization

  - [ ] 18.1 Set up flutter_localizations
    - English and German translations
    - German date format (DD.MM.YYYY)
    - German number format (1.234,56 €)
    - **Copilot Prompt:** `Create Flutter l10n configuration with app_en.arb and app_de.arb, DateFormat('dd.MM.yyyy') for German dates, NumberFormat.currency(locale: 'de_DE', symbol: '€') for prices`
    - _Requirements: 10.1, 10.2, 10.3_

- [ ] 19. Implement GDPR compliance features

  - [ ] 19.1 Create data export functionality

    - Export all user data as JSON
    - **Copilot Prompt:** `Create Flutter DataExportService that queries all user's receipts, households, warranty_items from Firestore and exports as downloadable JSON file`
    - _Requirements: 9.4_

  - [ ] 19.2 Create account deletion functionality
    - Delete all user data from Firestore and Storage
    - **Copilot Prompt:** `Create Flutter AccountDeletionService that deletes all documents where user_id matches, removes user from household members, deletes Storage files, and finally deletes Firebase Auth account`
    - _Requirements: 9.5_

- [ ] 20. Final checkpoint - Full integration test
  - End-to-end test: Scan → Verify → Save → Dashboard → Archive
  - Test household sharing flow
  - Test all killer features (Inflation, Recipes, Warranty)
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- All tasks including property-based tests are required for comprehensive coverage
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- **Copilot Prompts** are one-line instructions for Github Copilot code generation
- AI model can be switched between Gemini 3 Flash and GPT-4o in n8n workflow configuration
