import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';

/// Time period options for dashboard filtering
enum TimePeriod { days, weeks, months }

/// Dashboard screen showing spending overview and recent receipts
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TimePeriod _selectedPeriod = TimePeriod.months;
  DateTime _currentDate = DateTime.now();

  /// German currency format
  static final _germanCurrencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  /// German date formats
  String get _dayFormat => DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(_currentDate);
  String get _weekFormat => 'KW ${_getWeekNumber(_currentDate)}, ${_currentDate.year}';
  String get _monthFormat => DateFormat('MMMM yyyy', 'de_DE').format(_currentDate);

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  // TODO: Replace with actual data from repository
  double get _totalSpending => 245.67;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Time Period Toggle
          _TimePeriodToggle(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
          ),

          // Date Navigator
          _DateNavigator(
            periodLabel: _periodLabel,
            onPrevious: () => _navigatePeriod(-1),
            onNext: () => _navigatePeriod(1),
          ),

          // Total Spending Card
          _TotalSpendingCard(
            amount: _totalSpending,
            formattedAmount: _germanCurrencyFormat.format(_totalSpending),
            periodLabel: _getPeriodTypeLabel(),
          ),

          // Placeholder for more content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: const Color(AppColors.neutralGray).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deine Ausgaben werden hier angezeigt',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(AppColors.neutralGray),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          // TODO: Navigate to Camera Screen
        },
        child: const Icon(Icons.camera_alt, size: 32),
      ),
    );
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
                  'Gesamtausgaben',
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
