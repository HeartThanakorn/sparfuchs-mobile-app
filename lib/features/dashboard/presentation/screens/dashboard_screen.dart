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

/// Dashboard screen showing spending overview and recent receipts
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  TimePeriod _selectedPeriod = TimePeriod.months;
  DateTime _currentDate = DateTime.now();

  /// German currency format
  static final _germanCurrencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  /// German date formats
  String get _dayFormat => DateFormat('EEEE, d. MMMM yyyy', 'en_US').format(_currentDate);
  String get _weekFormat => 'KW ${_getWeekNumber(_currentDate)}, ${_currentDate.year}';
  String get _monthFormat => DateFormat('MMMM yyyy', 'en_US').format(_currentDate);

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case TimePeriod.days:
        return _dayFormat;
      case TimePeriod.weeks:
        return _weekFormat;
      case TimePeriod.months:
        return _monthFormat;
    }
  }

  void _navigatePeriod(int direction) {
    setState(() {
      switch (_selectedPeriod) {
        case TimePeriod.days:
          _currentDate = _currentDate.add(Duration(days: direction));
          break;
        case TimePeriod.weeks:
          _currentDate = _currentDate.add(Duration(days: 7 * direction));
          break;
        case TimePeriod.months:
          _currentDate = DateTime(
            _currentDate.year,
            _currentDate.month + direction,
            1,
          );
          break;
      }
    });
  }

  double _calculateTotalSpending(List<Receipt> receipts) {
    return receipts.where((receipt) {
      try {
        final date = DateTime.parse(receipt.receiptData.transaction.date);
      
        switch (_selectedPeriod) {
          case TimePeriod.days:
            return DateUtils.isSameDay(date, _currentDate);
          case TimePeriod.weeks:
            final weekStart = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
            final weekEnd = weekStart.add(const Duration(days: 6));
            // Normalize dates to remove time component for comparison
            final receiptDate = DateUtils.dateOnly(date);
            final start = DateUtils.dateOnly(weekStart);
            final end = DateUtils.dateOnly(weekEnd);
            return receiptDate.isAtSameMomentAs(start) || 
                   receiptDate.isAtSameMomentAs(end) || 
                   (receiptDate.isAfter(start) && receiptDate.isBefore(end));
          case TimePeriod.months:
            return date.year == _currentDate.year && date.month == _currentDate.month;
        }
      } catch (e) {
        debugPrint('Error parsing date: ${receipt.receiptData.transaction.date}');
        return false;
      }
    }).fold(0.0, (sum, receipt) => sum + receipt.receiptData.totals.grandTotal);
  }

  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Finances Overview'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(AppColors.darkNavy),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
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
          // Filter Tabs (All, Expenses, Income, Submitted)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildFilterTabs(),
          ),
          
          // Toggle: Show only expenses not in statistics
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Show only expenses that are not\nyet in the statistics.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Switch(
                  value: false,
                  onChanged: (_) {},
                  activeColor: const Color(AppColors.primaryTeal),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Month Header + Balance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'This month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.darkNavy),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_alt_outlined, size: 20, color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Balance Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: receiptsAsync.when(
              loading: () => const SizedBox(height: 30),
              error: (_, __) => const Text('Error'),
              data: (receipts) {
                final total = _calculateTotalSpending(receipts);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(fontSize: 15, color: Color(AppColors.darkNavy)),
                    ),
                    Row(
                      children: [
                        Text(
                          _germanCurrencyFormat.format(total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.darkNavy),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.info_outline, size: 18, color: Colors.grey.shade400),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
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

  int _selectedTabIndex = 0;

  Widget _buildFilterTabs() {
    final tabs = ['All', 'Expenses', 'Income', 'Submitted'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == _selectedTabIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tabs[index]),
                  if (index == 3) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.primaryTeal),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedTabIndex = index);
              },
              selectedColor: const Color(AppColors.darkNavy),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(AppColors.darkNavy),
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Your expenses will be displayed here',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptList(List<Receipt> receipts) {
    // Sort by date descending
    final sorted = List<Receipt>.from(receipts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) => _buildReceiptCard(sorted[index]),
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    DateTime? date;
    DateTime? time;
    
    try {
      date = DateFormat('yyyy-MM-dd').parse(receipt.receiptData.transaction.date);
      time = DateFormat('HH:mm:ss').parse(receipt.receiptData.transaction.time);
    } catch (_) {}

    final dateStr = date != null 
        ? DateFormat('dd.MM.yy', 'en_US').format(date)
        : receipt.receiptData.transaction.date;
    final timeStr = time != null 
        ? DateFormat('HH:mm').format(time)
        : receipt.receiptData.transaction.time.substring(0, 5);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
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
            // User avatar overlay (placeholder for household)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.person, size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Icon(
              receipt.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 16,
              color: receipt.isBookmarked 
                  ? const Color(AppColors.darkNavy)
                  : Colors.grey.shade400,
            ),
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
          '$dateStr • $timeStr',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _germanCurrencyFormat.format(receipt.receiptData.totals.grandTotal),
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

  void _openReceiptDetail(Receipt receipt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailScreen(receipt: receipt),
      ),
    );
    // Refresh after return
    if (mounted) setState(() {});
  }

  String _getPeriodTypeLabel() {
    switch (_selectedPeriod) {
      case TimePeriod.days:
        return 'Heute';
      case TimePeriod.weeks:
        return 'Diese Woche';
      case TimePeriod.months:
        return 'Diesen Monat';
    }
  }
}

/// Loading state for spending card
class _LoadingSpendingCard extends StatelessWidget {
  const _LoadingSpendingCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          height: 160,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
             color: const Color(AppColors.primaryTeal).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

/// Error state for spending card
class _ErrorSpendingCard extends StatelessWidget {
  final String error;
  const _ErrorSpendingCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: const Color(AppColors.errorRed).withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Color(AppColors.errorRed), size: 32),
              const SizedBox(height: 8),
              Text('Error loading', style: TextStyle(color: Color(AppColors.errorRed))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle buttons for selecting time period
class _TimePeriodToggle extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onPeriodChanged;

  const _TimePeriodToggle({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(AppColors.lightMint),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: TimePeriod.values.map((period) {
            final isSelected = period == selectedPeriod;
            return Expanded(
              child: GestureDetector(
                onTap: () => onPeriodChanged(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(AppColors.primaryTeal)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPeriodLabel(period),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : const Color(AppColors.darkNavy),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.days:
        return 'Tage';
      case TimePeriod.weeks:
        return 'Wochen';
      case TimePeriod.months:
        return 'Monate';
    }
  }
}

/// Date navigator with previous/next buttons
class _DateNavigator extends StatelessWidget {
  final String periodLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _DateNavigator({
    required this.periodLabel,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: const Color(AppColors.lightMint),
            ),
          ),
          Text(
            periodLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: const Color(AppColors.lightMint),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card showing total spending amount
class _TotalSpendingCard extends StatelessWidget {
  final double amount;
  final String formattedAmount;
  final String periodLabel;

  const _TotalSpendingCard({
    required this.amount,
    required this.formattedAmount,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                const Color(AppColors.primaryTeal),
                const Color(AppColors.primaryTeal).withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Text(
                periodLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedAmount,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total Spending',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
