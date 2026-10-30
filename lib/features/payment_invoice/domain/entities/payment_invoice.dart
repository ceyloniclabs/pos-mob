class PaymentInvoice {
  final double totalRental;
  final double totalLateFee;
  final double totalDamageFee;
  final double totalCharged;
  final double totalPaid;
  final double totalAdvance;
  final double totalDeposit;
  final double balanceDue;

  PaymentInvoice({
    required this.totalRental,
    required this.totalLateFee,
    required this.totalDamageFee,
    required this.totalCharged,
    required this.totalPaid,
    required this.totalAdvance,
    required this.totalDeposit,
    required this.balanceDue,
  });
}
