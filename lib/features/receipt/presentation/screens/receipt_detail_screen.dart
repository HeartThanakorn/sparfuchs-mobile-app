import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/providers/receipt_providers.dart';

/// Premium Receipt Detail Screen matching reference design
class ReceiptDetailScreen extends ConsumerStatefulWidget {
  final Receipt receipt;

  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
  });

  @override
  ConsumerState<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  static final _dateFormat = DateFormat('dd.MM.yyyy', 'en_US');
  static final _timeFormat = DateFormat('HH:mm');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.receipt.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    final receipt = widget.receipt;
    final data = receipt.receiptData;
    final items = data.items.where((item) => !item.isPfand).toList();
    final pfandItems = data.items.where((item) => item.isPfand).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Receipt details'),
        centerTitle: true,
        backgroundColor: const Color(AppColors.primaryTeal),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Image button
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: _viewReceiptImage,
          ),
          // Bookmark button
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purchase Info Section
            _buildSectionTitle('Purchase info'),
            const SizedBox(height: 8),
            _buildPurchaseInfoCard(data),
            
            const SizedBox(height: 24),
            
            // Goods Bought Section
            _buildGoodsHeader(items.length + pfandItems.length),
            const SizedBox(height: 8),
            
            // Regular Items
            ...items.map((item) => _buildLineItemCard(item)),
            
            // Pfand Section (if any)
            if (pfandItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPfandSectionHeader(),
              ...pfandItems.map((item) => _buildLineItemCard(item, isPfand: true)),
            ],
            
            const SizedBox(height: 24),
            
            // Totals Section
            _buildTotalsCard(data.totals),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(AppColors.darkNavy),
      ),
    );
  }

  Widget _buildPurchaseInfoCard(ReceiptData data) {
    DateTime? date;
    DateTime? time;
    
    try {
      date = DateFormat('yyyy-MM-dd').parse(data.transaction.date);
      time = DateFormat('HH:mm:ss').parse(data.transaction.time);
    } catch (_) {}

    // Calculate discount
    double totalDiscount = 0;
    for (final item in data.items) {
      if (item.discount != null) {
        totalDiscount += item.discount!;
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Merchant Row
          _buildInfoRow(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(AppColors.lightMint),
                borderRadius: BorderRadius.circular(8),
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
            title: data.merchant.name,
            trailing: 'Supermarket',
            showArrow: true,
          ),
          const Divider(height: 1),
          
          // Date & Time Row
          _buildInfoRow(
            leading: const Icon(Icons.calendar_today, size: 20, color: Color(AppColors.neutralGray)),
            title: date != null ? _dateFormat.format(date) : data.transaction.date,
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 18, color: Color(AppColors.neutralGray)),
                const SizedBox(width: 4),
                Text(
                  time != null ? _timeFormat.format(time) : data.transaction.time.substring(0, 5),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Color(AppColors.neutralGray)),
              ],
            ),
          ),
          
          // Discount Row (if any)
          if (totalDiscount != 0) ...[
            const Divider(height: 1),
            _buildInfoRow(
              title: 'Discount:',
              trailing: _currencyFormat.format(totalDiscount),
              trailingColor: const Color(AppColors.successGreen),
              showArrow: true,
            ),
          ],
          
          // Saved Overall Row (placeholder)
          const Divider(height: 1),
          _buildInfoRow(
            title: 'Saved overall:',
            trailing: totalDiscount != 0 
                ? _currencyFormat.format(totalDiscount)
                : '-',
            trailingColor: totalDiscount != 0 
                ? const Color(AppColors.successGreen)
                : null,
            showArrow: true,
          ),
          
          // Sum Row
          const Divider(height: 1),
          _buildInfoRow(
            title: 'Sum:',
            trailing: _currencyFormat.format(data.totals.grandTotal),
            titleBold: true,
            trailingBold: true,
            showArrow: true,
          ),
          
          // Note Row
          const Divider(height: 1),
          _buildInfoRow(
            title: 'Note (Optional)',
            titleColor: const Color(AppColors.neutralGray),
            trailing: 'Add',
            trailingColor: const Color(AppColors.primaryTeal),
            showArrow: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    Widget? leading,
    required String title,
    String? trailing,
    Widget? trailingWidget,
    Color? titleColor,
    Color? trailingColor,
    bool titleBold = false,
    bool trailingBold = false,
    bool showArrow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: titleBold ? FontWeight.w600 : FontWeight.normal,
                color: titleColor ?? const Color(AppColors.darkNavy),
              ),
            ),
          ),
          if (trailingWidget != null)
            trailingWidget
          else if (trailing != null) ...[
            Text(
              trailing,
              style: TextStyle(
                fontSize: 15,
                fontWeight: trailingBold ? FontWeight.w600 : FontWeight.normal,
                color: trailingColor ?? const Color(AppColors.darkNavy),
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Color(AppColors.neutralGray)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildGoodsHeader(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Goods bought'),
        Text(
          '$itemCount items',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPfandSectionHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(AppColors.lightMint),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.recycling, size: 20, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(
            'DEPOSIT SECTION',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemCard(LineItem item, {bool isPfand = false}) {
    // Category color mapping
    final categoryColors = {
      'Beverages': Colors.blue,
      'Groceries': Colors.purple,
      'Snacks': Colors.orange,
      'Household': Colors.teal,
      'Electronics': Colors.indigo,
      'Fashion': Colors.pink,
      'Deposit': Colors.green,
      'Other': Colors.grey,
    };

    final categoryColor = categoryColors[item.category] ?? Colors.grey;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onItemTap(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Color Bar
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(AppColors.darkNavy),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.quantity} x ${_currencyFormat.format(item.unitPrice)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    // Discount indicator
                    if (item.isDiscounted && item.discount != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.successGreen).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '🏷️ ${_currencyFormat.format(item.discount)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(AppColors.successGreen),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Price & Arrow
              Row(
                children: [
                  Text(
                    _currencyFormat.format(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.darkNavy),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Color(AppColors.neutralGray)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsCard(Totals totals) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal:', totals.subtotal),
            if (totals.pfandTotal > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow('♻️ Pfand Total:', totals.pfandTotal),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _buildTotalRow(
              'GRAND TOTAL:',
              totals.grandTotal,
              isBold: true,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(AppColors.darkNavy),
          ),
        ),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(AppColors.darkNavy),
          ),
        ),
      ],
    );
  }

  void _toggleBookmark() async {
    final newValue = !_isBookmarked;
    setState(() => _isBookmarked = newValue);
    
    final repository = ref.read(receiptRepositoryProvider);
    await repository.toggleBookmark(widget.receipt.receiptId, newValue);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue ? 'Bookmark added!' : 'Bookmark removed'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _viewReceiptImage() {
    final imageUrl = widget.receipt.imageUrl;
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image available')),
      );
      return;
    }

    // Show image in dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl.startsWith('/') 
              ? Image.file(File(imageUrl), fit: BoxFit.contain)
              : Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _onItemTap(LineItem item) {
    // TODO: Navigate to item edit or details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item: ${item.description}')),
    );
  }
}
