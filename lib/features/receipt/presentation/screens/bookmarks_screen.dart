import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/core/services/local_database_service.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/screens/receipt_detail_screen.dart';

/// Bookmarks Screen showing bookmarked receipts
class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String _sortOption = 'Newest first';
  final List<String> _sortOptions = ['Newest first', 'Oldest first', 'Highest amount', 'Lowest amount'];

  static final _dateFormat = DateFormat('dd.MM.yy', 'en_US');
  static final _timeFormat = DateFormat('HH:mm');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final allReceipts = _loadReceiptsFromHive();
    final bookmarkedReceipts = allReceipts.where((r) => r.isBookmarked).toList();
    
    // Apply sorting
    _sortReceipts(bookmarkedReceipts);
    
    // Group by month
    final groupedReceipts = _groupByMonth(bookmarkedReceipts);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(AppColors.darkNavy),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sort & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Sort Dropdown
                _buildSortDropdown(),
                const Spacer(),
                // Date Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Last 30 days',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                // Calendar Button
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
                  onPressed: _openDatePicker,
                ),
              ],
            ),
          ),

          // Receipt List
          Expanded(
            child: bookmarkedReceipts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupedReceipts.length,
                    itemBuilder: (context, index) {
                      final monthYear = groupedReceipts.keys.elementAt(index);
                      final receipts = groupedReceipts[monthYear]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month Header
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              monthYear,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(AppColors.neutralGray),
                              ),
                            ),
                          ),
                          // Receipts in this month
                          ...receipts.map((receipt) => _buildReceiptCard(receipt)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _sortOption = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 18),
            const SizedBox(width: 8),
            Text(_sortOption, style: const TextStyle(fontSize: 14)),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => _sortOptions.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (option == _sortOption)
                const Icon(Icons.check, size: 18, color: Color(AppColors.primaryTeal))
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(option),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    DateTime? date;
    DateTime? time;
    
    try {
      date = DateFormat('yyyy-MM-dd').parse(receipt.receiptData.transaction.date);
      time = DateFormat('HH:mm:ss').parse(receipt.receiptData.transaction.time);
    } catch (_) {}

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(AppColors.lightMint),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              receipt.receiptData.merchant.name.isNotEmpty
                  ? receipt.receiptData.merchant.name[0].toUpperCase()
                  : 'M',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.primaryTeal),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.bookmark, size: 16, color: Color(AppColors.darkNavy)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                receipt.receiptData.merchant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(AppColors.darkNavy),
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${date != null ? _dateFormat.format(date) : receipt.receiptData.transaction.date} • ${time != null ? _timeFormat.format(time) : receipt.receiptData.transaction.time.substring(0, 5)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currencyFormat.format(receipt.receiptData.totals.grandTotal),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.darkNavy),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(AppColors.neutralGray)),
          ],
        ),
        onTap: () => _openReceiptDetail(receipt),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookmark receipts to see them here',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _sortReceipts(List<Receipt> receipts) {
    switch (_sortOption) {
      case 'Newest first':
        receipts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest first':
        receipts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Highest amount':
        receipts.sort((a, b) => b.receiptData.totals.grandTotal.compareTo(a.receiptData.totals.grandTotal));
        break;
      case 'Lowest amount':
        receipts.sort((a, b) => a.receiptData.totals.grandTotal.compareTo(b.receiptData.totals.grandTotal));
        break;
    }
  }

  Map<String, List<Receipt>> _groupByMonth(List<Receipt> receipts) {
    final Map<String, List<Receipt>> grouped = {};
    final monthFormat = DateFormat('MMMM yyyy', 'en_US');
    
    for (final receipt in receipts) {
      DateTime? date;
      try {
        date = DateFormat('yyyy-MM-dd').parse(receipt.receiptData.transaction.date);
      } catch (_) {
        date = receipt.createdAt;
      }
      
      final monthKey = monthFormat.format(date);
      grouped.putIfAbsent(monthKey, () => []).add(receipt);
    }
    
    return grouped;
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

  void _openDatePicker() {
    // TODO: Implement date range picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date picker coming soon')),
    );
  }

  void _openReceiptDetail(Receipt receipt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailScreen(receipt: receipt),
      ),
    );
    // Refresh after returning
    if (mounted) setState(() {});
  }
}
