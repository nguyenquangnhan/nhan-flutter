import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/parsed_bank_bill.dart';
import '../models/expense_category.dart';
import '../models/expense_item.dart';
import '../state/expense_notifier.dart';
import '../widgets/category_chip_selector.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final ParsedBankBill parsedBill;

  const ReviewScreen({
    super.key,
    required this.parsedBill,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _contentController;
  late final TextEditingController _recipientController;
  late final TextEditingController _bankController;
  late ExpenseCategory _selectedCategory;
  late DateTime _selectedDate;

  final _contentFocus = FocusNode();
  final _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final bill = widget.parsedBill;

    _amountController = TextEditingController(
      text: bill.amount != null ? CurrencyFormatter.formatNumberOnly(bill.amount!) : '',
    );
    _contentController = TextEditingController(text: bill.transferContent ?? '');
    _recipientController = TextEditingController(text: bill.recipientName ?? '');
    _bankController = TextEditingController(text: bill.bankName ?? '');
    _selectedCategory = bill.suggestedCategory;
    _selectedDate = bill.transactionTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _contentController.dispose();
    _recipientController.dispose();
    _bankController.dispose();
    _contentFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final rawAmountText = _amountController.text;
    final amount = CurrencyFormatter.parseAmount(rawAmountText) ?? 0.0;
    final content = _contentController.text.trim();

    final newItem = ExpenseItem(
      id: 'exp_${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      transferContent: content,
      category: _selectedCategory,
      recipientName: _recipientController.text.trim().isNotEmpty
          ? _recipientController.text.trim()
          : null,
      bankName: _bankController.text.trim().isNotEmpty
          ? _bankController.text.trim()
          : null,
      transactionTime: _selectedDate,
      localImagePath: widget.parsedBill.imagePath,
      syncStatus: 'pending',
      createdAt: DateTime.now(),
    );

    // Lưu vào State và Database qua Riverpod
    ref.read(expenseListProvider.notifier).addExpense(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Đã lưu giao dịch thành công!'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bill = widget.parsedBill;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực & Chọn Danh mục'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Xem trước ảnh biên lai vừa quét
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    if (File(bill.imagePath).existsSync())
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Image.file(
                          File(bill.imagePath),
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(child: Text('Không tìm thấy ảnh biên lai')),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đã tự động nhận diện từ ảnh chụp màn hình ngân hàng',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Ô nhập số tiền
              Text(
                'Số tiền chuyển khoản (VNĐ)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocus,
                keyboardType: TextInputType.number,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.payments_outlined),
                  suffixText: 'VNĐ',
                  hintText: 'Nhập số tiền...',
                ),
                validator: (v) {
                  final amount = CurrencyFormatter.parseAmount(v);
                  if (amount == null || amount <= 0) {
                    return 'Vui lòng nhập số tiền hợp lệ (> 0)';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _contentFocus.requestFocus(),
              ),

              const SizedBox(height: 16),

              // 3. Ô nhập nội dung chuyển khoản
              Text(
                'Nội dung chuyển khoản',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                focusNode: _contentFocus,
                maxLines: 2,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Ví dụ: NGUYEN QUANG NHAN chuyen tien...',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập nội dung giao dịch';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // 4. CHỌN DANH MỤC TIÊU SÀI (Trọng tâm yêu cầu)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn danh mục chi tiêu',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Đã gợi ý theo nội dung',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CategoryChipSelector(
                selectedCategory: _selectedCategory,
                onSelected: (cat) => setState(() => _selectedCategory = cat),
              ),

              const SizedBox(height: 20),

              // 5. Thông tin bổ sung (Thời gian & Ngân hàng)
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 8),
                          Text('Thời gian: ${DateFormatter.formatDateTime(_selectedDate)}'),
                        ],
                      ),
                      if (_bankController.text.isNotEmpty) ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.account_balance, size: 18),
                            const SizedBox(width: 8),
                            Text('Ngân hàng: ${_bankController.text}'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 6. Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Xác nhận & Lưu Chi tiêu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
