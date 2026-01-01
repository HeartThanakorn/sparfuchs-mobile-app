import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/providers/receipt_providers.dart';
import 'package:sparfuchs_ai/core/services/local_database_service.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/screens/receipt_detail_screen.dart';

/// Receipt Archive Screen with WORKING filter
class ReceiptArchiveScreen extends ConsumerStatefulWidget {
  const ReceiptArchiveScreen({super.key});

  @override
  ConsumerState<ReceiptArchiveScreen> createState() => _ReceiptArchiveScreenState();
}

class _ReceiptArchiveScreenState extends ConsumerState<ReceiptArchiveScreen> {
  static final _dateFormat = DateFormat('dd.MM.yyyy', 'en_US');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  // FILTER STATE
  bool _showBookmarksOnly = false;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    try {
      final List<Receipt> allReceipts = _loadReceiptsFromHive();
      final List<Receipt> filteredReceipts = _applyFilters(allReceipts);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Receipt Archive'),
          centerTitle: true,
          backgroundColor: const Color(AppColors.primaryTeal),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => setState(() {}),
            ),
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: _hasActiveFilters ? Colors.amber : Colors.white,
              ),
              tooltip: 'Filter',
              onPressed: () => _showFilterSheet(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Active Filters Indicator
            if (_hasActiveFilters) _buildActiveFiltersBar(),
            
            // Receipt List
            Expanded(
              child: filteredReceipts.isEmpty
                  ? _buildEmptyState(allReceipts.isNotEmpty)
                  : _buildReceiptList(filteredReceipts),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Archive build error: $e');
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt Archive')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $e', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }

  bool get _hasActiveFilters => _showBookmarksOnly || _dateRange != null;

  List<Receipt> _applyFilters(List<Receipt> receipts) {
    var filtered = List<Receipt>.from(receipts);

    // Filter by bookmarks
    if (_showBookmarksOnly) {
      filtered = filtered.where((r) => r.isBookmarked).toList();
    }

    // Filter by date range
    if (_dateRange != null) {
      filtered = filtered.where((r) {
        try {
          final date = DateFormat('yyyy-MM-dd').parse(r.receiptData.transaction.date);
          return date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
                 date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        } catch (_) {
          return true; // Include if date parsing fails
        }
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) {
      try {
        final dateA = DateFormat('yyyy-MM-dd').parse(a.receiptData.transaction.date);
        final dateB = DateFormat('yyyy-MM-dd').parse(b.receiptData.transaction.date);
        return dateB.compareTo(dateA);
      } catch (_) {
        return 0;
      }
    });

    return filtered;
  }

  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(AppColors.lightMint),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16, color: Color(AppColors.primaryTeal)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFilterDescription(),
              style: const TextStyle(fontSize: 13, color: Color(AppColors.darkNavy)),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _showBookmarksOnly = false;
              _dateRange = null;
            }),
            child: const Text('Clear', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _getFilterDescription() {
    final parts = <String>[];
    if (_showBookmarksOnly) parts.add('Bookmarks only');
    if (_dateRange != null) {
      parts.add('${_dateFormat.format(_dateRange!.start)} - ${_dateFormat.format(_dateRange!.end)}');
    }
    return parts.join(' • ');
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Receipts',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showBookmarksOnly = false;
                          _dateRange = null;
                        });
                        setModalState(() {});
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Bookmarks Toggle
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bookmark, color: Color(AppColors.primaryTeal)),
                  title: const Text('Bookmarks only'),
                  trailing: Switch(
                    value: _showBookmarksOnly,
                    activeColor: const Color(AppColors.primaryTeal),
                    onChanged: (value) {
                      setState(() => _showBookmarksOnly = value);
                      setModalState(() {});
                    },
                  ),
                ),
                
                const Divider(),
                
                // Date Range
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Color(AppColors.primaryTeal)),
                  title: const Text('Date range'),
                  subtitle: _dateRange != null
                      ? Text(
                          '${_dateFormat.format(_dateRange!.start)} - ${_dateFormat.format(_dateRange!.end)}',
                          style: const TextStyle(color: Color(AppColors.primaryTeal)),
                        )
                      : const Text('All dates'),
                  trailing: _dateRange != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _dateRange = null);
                            setModalState(() {});
                          },
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: now,
                      initialDateRange: _dateRange,
                      helpText: 'Select date range',
                      cancelText: 'Cancel',
                      confirmText: 'Apply',
                      saveText: 'Apply',
                    );
                    if (picked != null) {
                      setState(() => _dateRange = picked);
                      setModalState(() {});
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasReceiptsBeforeFilter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasReceiptsBeforeFilter ? Icons.filter_list_off : Icons.receipt_long_outlined,
            size: 64,
            color: const Color(AppColors.neutralGray),
          ),
          const SizedBox(height: 8),
          Text(
            hasReceiptsBeforeFilter ? 'No receipts match filters' : 'No receipts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(AppColors.darkNavy),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            hasReceiptsBeforeFilter 
                ? 'Try adjusting your filters'
                : 'Scan your first receipt!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(AppColors.neutralGray),
                ),
          ),
          if (hasReceiptsBeforeFilter) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() {
                _showBookmarksOnly = false;
                _dateRange = null;
              }),
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceiptList(List<Receipt> receipts) {
    // Group receipts by date
    final Map<String, List<Receipt>> grouped = {};
    for (final receipt in receipts) {
      final dateKey = receipt.receiptData.transaction.date;
      grouped.putIfAbsent(dateKey, () => []).add(receipt);
    }

    final dateKeys = grouped.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('yyyy-MM-dd').parse(a);
          final dateB = DateFormat('yyyy-MM-dd').parse(b);
          return dateB.compareTo(dateA);
        } catch (_) {
          return 0;
        }
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final dateReceipts = grouped[dateKey]!;
        
        String formattedDate;
        try {
          final date = DateFormat('yyyy-MM-dd').parse(dateKey);
          formattedDate = _dateFormat.format(date);
        } catch (_) {
          formattedDate = dateKey;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ...dateReceipts.map((receipt) => _buildReceiptCard(receipt)),
          ],
        );
      },
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    final data = receipt.receiptData;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onReceiptTap(receipt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Merchant Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(AppColors.lightMint),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    data.merchant.name.isNotEmpty 
                        ? data.merchant.name[0].toUpperCase()
                        : 'M',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primaryTeal),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.merchant.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.darkNavy),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.transaction.time.substring(0, 5)} • ${data.transaction.paymentMethod}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Amount
              Text(
                _currencyFormat.format(data.totals.grandTotal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.darkNavy),
                ),
              ),
              const SizedBox(width: 8),
              
              // Bookmark Icon
              GestureDetector(
                onTap: () => _onBookmarkTap(receipt),
                child: Icon(
                  receipt.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 22,
                  color: receipt.isBookmarked 
                      ? const Color(AppColors.primaryTeal)
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Receipt> _loadReceiptsFromHive() {
    try {
      final box = LocalDatabaseService.receiptsBox;
      final receipts = <Receipt>[];
      
      for (final key in box.keys) {
        try {
          final rawData = box.get(key);
          if (rawData != null) {
            final data = _deepCopyMap(rawData as Map);
            data['receiptId'] = key.toString();
            receipts.add(Receipt.fromJson(data));
          }
        } catch (e) {
          debugPrint('Error parsing receipt $key: $e');
        }
      }
      
      return receipts;
    } catch (e) {
      debugPrint('Error loading receipts: $e');
      return [];
    }
  }

  Map<String, dynamic> _deepCopyMap(Map original) {
    final result = <String, dynamic>{};
    for (final entry in original.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is Map) {
        result[key] = _deepCopyMap(value);
      } else if (value is List) {
        result[key] = _deepCopyList(value);
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  List<dynamic> _deepCopyList(List original) {
    return original.map((item) {
      if (item is Map) {
        return _deepCopyMap(item);
      } else if (item is List) {
        return _deepCopyList(item);
      } else {
        return item;
      }
    }).toList();
  }

  void _onReceiptTap(Receipt receipt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailScreen(receipt: receipt),
      ),
    );
    if (mounted) setState(() {});
  }

  void _onBookmarkTap(Receipt receipt) async {
    final repository = ref.read(receiptRepositoryProvider);
    await repository.toggleBookmark(receipt.receiptId, !receipt.isBookmarked);
    setState(() {});
  }
}
