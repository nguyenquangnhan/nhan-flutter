import 'expense_category.dart';

class ExpenseItem {
  final String id;
  final double amount;
  final String transferContent;
  final ExpenseCategory category;
  final String? recipientName;
  final String? bankName;
  final DateTime transactionTime;
  final String? localImagePath;
  final String? cloudImageUrl;
  final String syncStatus; // 'pending' | 'synced'
  final DateTime createdAt;

  const ExpenseItem({
    required this.id,
    required this.amount,
    required this.transferContent,
    required this.category,
    this.recipientName,
    this.bankName,
    required this.transactionTime,
    this.localImagePath,
    this.cloudImageUrl,
    this.syncStatus = 'synced',
    required this.createdAt,
  });

  ExpenseItem copyWith({
    String? id,
    double? amount,
    String? transferContent,
    ExpenseCategory? category,
    String? recipientName,
    String? bankName,
    DateTime? transactionTime,
    String? localImagePath,
    String? cloudImageUrl,
    String? syncStatus,
    DateTime? createdAt,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      transferContent: transferContent ?? this.transferContent,
      category: category ?? this.category,
      recipientName: recipientName ?? this.recipientName,
      bankName: bankName ?? this.bankName,
      transactionTime: transactionTime ?? this.transactionTime,
      localImagePath: localImagePath ?? this.localImagePath,
      cloudImageUrl: cloudImageUrl ?? this.cloudImageUrl,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'transfer_content': transferContent,
      'category': category.name,
      'recipient_name': recipientName,
      'bank_name': bankName,
      'transaction_time': transactionTime.toIso8601String(),
      'image_path': localImagePath,
      'cloud_image_url': cloudImageUrl,
      'sync_status': syncStatus,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      transferContent: (map['transfer_content'] ?? '') as String,
      category: ExpenseCategory.fromString(map['category'] as String?),
      recipientName: map['recipient_name'] as String?,
      bankName: map['bank_name'] as String?,
      transactionTime: map['transaction_time'] != null
          ? DateTime.tryParse(map['transaction_time'] as String) ?? DateTime.now()
          : DateTime.now(),
      localImagePath: map['image_path'] as String?,
      cloudImageUrl: map['cloud_image_url'] as String?,
      syncStatus: (map['sync_status'] ?? 'synced') as String,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : DateTime.now(),
    );
  }

  /// Map dành cho Supabase Cloud PostgreSQL
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'amount': amount,
      'transfer_content': transferContent,
      'category': category.name,
      'recipient_name': recipientName,
      'bank_name': bankName,
      'transaction_time': transactionTime.toIso8601String(),
      'image_url': cloudImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
