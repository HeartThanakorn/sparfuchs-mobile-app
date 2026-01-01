import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/providers/receipt_providers.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/screens/camera_screen.dart';
import 'package:sparfuchs_ai/features/dashboard/presentation/screens/statistics_screen.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/screens/receipt_detail_screen.dart';

/// Time period options for dashboard filtering
enum TimePeriod { days, weeks, months }

/// Dashboard Screen - Simplified and Functional Only
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('SparFuchs AI'),
        centerTitle: true,
        backgroundColor: const Color(AppColors.primaryTeal),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          receiptsAsync.when(
            loading: () => const SizedBox(height: 100),
            error: (_, __) => const SizedBox(height: 100),
            data: (receipts) => _buildSummaryCard(receipts),
          ),
          
          const SizedBox(height: 16),
          
          // Recent Receipts Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Receipts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.darkNavy),
                  ),
                ),
                receiptsAsync.maybeWhen(
                  data: (receipts) => Text(
                    '${receipts.length} total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  orElse: () => const SizedBox(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Receipt List
          Expanded(
            child: receiptsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (receipts) {
                if (receipts.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildReceiptList(receipts);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );
        },
        backgroundColor: const Color(AppColors.primaryTeal),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(List<Receipt> receipts) {
    final thisMonth = DateTime.now();
    final monthReceipts = receipts.where((r) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(r.receiptData.transaction.date);
        return date.month == thisMonth.month && date.year == thisMonth.year;
      } catch (_) {
        return false;
      }
    }).toList();
    
    final monthTotal = monthReceipts.fold(0.0, (sum, r) => sum + r.receiptData.totals.grandTotal);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(AppColors.primaryTeal), Color(0xFF4DD0E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryTeal).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'This Month',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(thisMonth),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(monthTotal),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${monthReceipts.length} receipts this month',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No receipts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(AppColors.darkNavy),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to scan your first receipt!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptList(List<Receipt> receipts) {
    // Sort by date (newest first)
    final sortedReceipts = List<Receipt>.from(receipts)
      ..sort((a, b) {
        try {
          final dateA = DateFormat('yyyy-MM-dd').parse(a.receiptData.transaction.date);
          final dateB = DateFormat('yyyy-MM-dd').parse(b.receiptData.transaction.date);
          return dateB.compareTo(dateA);
        } catch (_) {
          return 0;
        }
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedReceipts.length,
      itemBuilder: (context, index) {
        final receipt = sortedReceipts[index];
        return _buildReceiptCard(receipt);
      },
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    final data = receipt.receiptData;
    DateTime? date;
    try {
      date = DateFormat('yyyy-MM-dd').parse(data.transaction.date);
    } catch (_) {}

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onReceiptTap(receipt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Merchant Initial Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(AppColors.lightMint),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    data.merchant.name.isNotEmpty
                        ? data.merchant.name[0].toUpperCase()
                        : 'M',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primaryTeal),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.merchant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(AppColors.darkNavy),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (receipt.isBookmarked)
                          const Icon(Icons.bookmark, size: 18, color: Color(AppColors.primaryTeal)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date != null
                          ? '${DateFormat('dd.MM.yyyy').format(date)} • ${data.transaction.time.length >= 5 ? data.transaction.time.substring(0, 5) : data.transaction.time}'
                          : '${data.transaction.date} • ${data.transaction.time}',
                      style: TextStyle(
                        fontSize: 13,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.darkNavy),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReceiptTap(Receipt receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailScreen(receipt: receipt),
      ),
    );
  }
}
