import 'package:flutter/material.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';

/// Widget to display price change percentage with visual indicators
/// Automatically calculates percentage if not provided directly
class PriceChangeIndicator extends StatelessWidget {
  final double currentPrice;
  final double previousPrice;
  final double? percentageOverride;
  final bool showLabel;
  final bool isCompact;

  const PriceChangeIndicator({
    super.key,
    required this.currentPrice,
    required this.previousPrice,
    this.percentageOverride,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = percentageOverride ?? _calculatePercentage();
    final isSignificantIncrease = percentage > 10.0;
    
    // Determine color and icon
    Color color;
    IconData icon;
    
    if (percentage > 0) {
      // Price increase
      color = isSignificantIncrease 
          ? const Color(AppColors.errorRed) 
          : const Color(AppColors.warningOrange);
      icon = Icons.arrow_upward;
    } else if (percentage < 0) {
      // Price decrease (good)
      color = const Color(AppColors.successGreen);
      icon = Icons.arrow_downward;
    } else {
      // No change
      color = const Color(AppColors.neutralGray);
      icon = Icons.remove;
    }

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 2),
            Text(
              '${percentage.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: isSignificantIncrease 
            ? Border.all(color: color.withValues(alpha: 0.5)) 
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '${percentage.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          if (showLabel && isSignificantIncrease && percentage > 0) ...[
            const SizedBox(width: 6),
            Icon(Icons.warning_amber_rounded, size: 16, color: color),
          ],
        ],
      ),
    );
  }

  double _calculatePercentage() {
    if (previousPrice == 0) return 0.0;
    return ((currentPrice - previousPrice) / previousPrice) * 100;
  }
}
