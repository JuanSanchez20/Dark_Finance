class RecentTransaction {
  const RecentTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.bucketName,
    required this.categoryName,
    required this.date,
    this.merchant,
  });

  final int id;
  final double amount;
  final String description;
  final String bucketName;
  final String categoryName;
  final DateTime date;
  final String? merchant;
}
