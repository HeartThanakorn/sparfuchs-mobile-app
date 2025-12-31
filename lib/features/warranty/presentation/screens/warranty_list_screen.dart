import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/features/warranty/data/services/warranty_service.dart';
import 'package:sparfuchs_ai/shared/theme/app_theme.dart';

/// Screen displaying all warranty items with return/warranty tracking
class WarrantyListScreen extends StatelessWidget {
  const WarrantyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for UI development
    final mockItems = [
      WarrantyItem(
        id: '1',
        receiptId: 'r1',
        userId: 'u1',
        itemDescription: 'Samsung Galaxy Buds Pro',
        category: 'Electronics',
        price: 149.99,
        purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
        returnDeadline: DateTime.now().add(const Duration(days: 4)),
        warrantyExpiry: DateTime.now().add(const Duration(days: 720)),
        merchantName: 'MediaMarkt',
      ),
      WarrantyItem(
        id: '2',
        receiptId: 'r2',
        userId: 'u1',
        itemDescription: 'Nike Air Max 90',
        category: 'Fashion',
        price: 149.00,
        purchaseDate: DateTime.now().subtract(const Duration(days: 12)),
        returnDeadline: DateTime.now().add(const Duration(days: 2)),
        warrantyExpiry: DateTime.now().add(const Duration(days: 170)),
        merchantName: 'Foot Locker',
      ),
      WarrantyItem(
        id: '3',
        receiptId: 'r3',
        userId: 'u1',
        itemDescription: 'Logitech MX Master 3',
        category: 'Electronics',
        price: 99.99,
        purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
        returnDeadline: DateTime.now().add(const Duration(days: 9)),
        warrantyExpiry: DateTime.now().add(const Duration(days: 725)),
        merchantName: 'Saturn',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garantie & Rückgabe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filter options
            },
          ),
        ],
      ),
      body: mockItems.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _WarrantyItemTile(
                item: mockItems[index],
                onMarkReturned: () => _markAsReturned(context, mockItems[index]),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Keine Garantieartikel',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Elektronik- und Modeartikel werden automatisch erfasst',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _markAsReturned(BuildContext context, WarrantyItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.itemDescription} als zurückgegeben markiert'),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () {
            // TODO: Undo
          },
        ),
      ),
    );
  }
}

/// Individual warranty item tile with swipe action
class _WarrantyItemTile extends StatelessWidget {
  final WarrantyItem item;
  final VoidCallback onMarkReturned;

  const _WarrantyItemTile({
    required this.item,
    required this.onMarkReturned,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Zurückgegeben',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onMarkReturned();
        return false; // Don't actually dismiss
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  _buildCategoryIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemDescription,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.merchantName} • ${currencyFormat.format(item.price)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Return deadline
              _buildDeadlineRow(
                context,
                icon: Icons.replay,
                label: 'Rückgabefrist',
                date: item.returnDeadline,
                daysRemaining: item.daysUntilReturnDeadline,
                dateFormat: dateFormat,
              ),
              const SizedBox(height: 8),

              // Warranty expiry
              if (item.warrantyExpiry != null)
                _buildDeadlineRow(
                  context,
                  icon: Icons.verified_user,
                  label: 'Garantie bis',
                  date: item.warrantyExpiry!,
                  daysRemaining: item.daysUntilWarrantyExpiry ?? 0,
                  dateFormat: dateFormat,
                  isWarranty: true,
                ),

              const SizedBox(height: 12),

              // Swipe hint
              Center(
                child: Text(
                  '← Nach links wischen zum Markieren',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    final isElectronics = item.category.toLowerCase() == 'electronics';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isElectronics
            ? Colors.blue.shade100
            : Colors.pink.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isElectronics ? Icons.devices : Icons.checkroom,
        color: isElectronics ? Colors.blue.shade700 : Colors.pink.shade700,
      ),
    );
  }

  Widget _buildDeadlineRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required DateTime date,
    required int daysRemaining,
    required DateFormat dateFormat,
    bool isWarranty = false,
  }) {
    Color statusColor;
    String statusText;

    if (daysRemaining < 0) {
      statusColor = Colors.grey;
      statusText = 'Abgelaufen';
    } else if (daysRemaining <= 3) {
      statusColor = AppTheme.errorRed;
      statusText = '$daysRemaining Tage';
    } else if (daysRemaining <= 7) {
      statusColor = Colors.orange;
      statusText = '$daysRemaining Tage';
    } else {
      statusColor = AppTheme.successGreen;
      statusText = isWarranty
          ? '${(daysRemaining / 365).toStringAsFixed(1)} Jahre'
          : '$daysRemaining Tage';
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          dateFormat.format(date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
