class CurrencyFormatter {
  static String formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';
    
    int number = 0;
    if (amount is int) {
      number = amount;
    } else if (amount is double) {
      number = amount.round();
    } else {
      final digitsOnly = amount.toString().replaceAll(RegExp(r'[^\d]'), '');
      number = int.tryParse(digitsOnly) ?? 0;
    }

    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}
