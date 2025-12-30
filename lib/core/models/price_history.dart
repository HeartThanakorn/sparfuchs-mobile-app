class PriceHistory {
  final String productId;
  final String productName;
  final List<PriceRecord> records;

  const PriceHistory({
    required this.productId,
    required this.productName,
    this.records = const [],
  });

  /// Adds a new price record and returns a new PriceHistory instance
  /// Records are always sorted by date (newest first)
  PriceHistory addRecord(PriceRecord newRecord) {
    final updatedRecords = List<PriceRecord>.from(records);
    
    // Check if record for this date and store already exists
    final existingIndex = updatedRecords.indexWhere((r) => 
      r.date.year == newRecord.date.year &&
      r.date.month == newRecord.date.month &&
      r.date.day == newRecord.date.day &&
      r.store == newRecord.store
    );

    if (existingIndex != -1) {
      // Update existing record if new one is more recent (or just overwrite)
      updatedRecords[existingIndex] = newRecord;
    } else {
      updatedRecords.add(newRecord);
    }

    // Sort: Newest first
    updatedRecords.sort((a, b) => b.date.compareTo(a.date));

    return PriceHistory(
      productId: productId,
      productName: productName,
      records: updatedRecords,
    );
  }

  /// Get latest price
  double? get currentPrice => records.isNotEmpty ? records.first.price : null;

  /// Get price percentage change compared to [daysAgo]
  double getPriceChangePercentage([int daysAgo = 30]) {
    if (records.isEmpty) return 0.0;

    final current = records.first.price;
    if (records.length == 1) return 0.0;

    // Find record closest to daysAgo
    final targetDate = DateTime.now().subtract(Duration(days: daysAgo));
    
    // Simple logic: find first record that is older than targetDate
    // Since list is sorted newest first, we look for the first one where date <= targetDate
    // Or just the oldest record if history is short
    
    // Use last record as baseline if no specific old record found
    var baseline = records.last.price;

    // Try to find a specific historical point
    for (var record in records) {
      if (record.date.isBefore(targetDate) || record.date.isAtSameMomentAs(targetDate)) {
        baseline = record.price;
        break;
      }
    }

    if (baseline == 0) return 0.0;
    return ((current - baseline) / baseline) * 100;
  }
}

class PriceRecord {
  final double price;
  final DateTime date;
  final String store;

  const PriceRecord({
    required this.price,
    required this.date,
    required this.store,
  });
}
