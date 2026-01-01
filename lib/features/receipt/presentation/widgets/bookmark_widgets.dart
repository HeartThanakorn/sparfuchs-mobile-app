import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Bookmark button that toggles receipt bookmark state
class BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onToggle;
  final double size;
  final bool showAnimation;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onToggle,
    this.size = 24,
    this.showAnimation = true,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.showAnimation) {
      _controller.forward().then((_) => _controller.reverse());
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: widget.size,
          color: widget.isBookmarked
              ? const Color(AppColors.warningOrange)
              : const Color(AppColors.neutralGray),
        ),
      ),
    );
  }
}

/// View showing only bookmarked receipts
class BookmarksView extends ConsumerStatefulWidget {
  final List<Receipt> allReceipts;
  final void Function(Receipt) onReceiptTap;
  final void Function(Receipt) onBookmarkToggle;

  const BookmarksView({
    super.key,
    required this.allReceipts,
    required this.onReceiptTap,
    required this.onBookmarkToggle,
  });

  @override
  ConsumerState<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends ConsumerState<BookmarksView> {
  static final _dateFormat = DateFormat('dd.MM.yyyy', 'en_US');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  List<Receipt> get _bookmarkedReceipts =>
      widget.allReceipts.where((r) => r.isBookmarked).toList()
        ..sort((a, b) => b.receiptData.transaction.date
            .compareTo(a.receiptData.transaction.date));

  @override
  Widget build(BuildContext context) {
    final bookmarks = _bookmarkedReceipts;

    if (bookmarks.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final receipt = bookmarks[index];
        return _BookmarkedReceiptTile(
          receipt: receipt,
          dateFormat: _dateFormat,
          currencyFormat: _currencyFormat,
          onTap: () => widget.onReceiptTap(receipt),
          onBookmarkToggle: () => widget.onBookmarkToggle(receipt),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: const Color(AppColors.neutralGray).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Lesezeichen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(AppColors.neutralGray),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mark important receipts with ★',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(AppColors.neutralGray),
                ),
          ),
        ],
      ),
    );
  }
}

/// Tile for bookmarked receipt with swipe-to-remove
class _BookmarkedReceiptTile extends StatelessWidget {
  final Receipt receipt;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const _BookmarkedReceiptTile({
    required this.receipt,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final merchant = receipt.receiptData.merchant;
    final transaction = receipt.receiptData.transaction;
    final totals = receipt.receiptData.totals;

    final date = DateTime.tryParse(transaction.date);
    final dateStr = date != null ? dateFormat.format(date) : transaction.date;

    return Dismissible(
      key: Key('bookmark_${receipt.receiptId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(AppColors.errorRed),
        child: const Icon(
          Icons.bookmark_remove,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        onBookmarkToggle();
        return false; // Don't actually dismiss, just toggle
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(AppColors.warningOrange).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Bookmark icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.warningOrange).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Color(AppColors.warningOrange),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(AppColors.neutralGray),
                            ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(totals.grandTotal),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(AppColors.darkNavy),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wischen zum Entfernen',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(AppColors.neutralGray),
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab bar for switching between All Receipts and Bookmarks
class ReceiptTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const ReceiptTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppColors.lightMint),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(context, 0, Icons.receipt_long, 'Alle'),
          _buildTab(context, 1, Icons.bookmark, 'Lesezeichen'),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(AppColors.primaryTeal)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : const Color(AppColors.darkNavy),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : const Color(AppColors.darkNavy),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
