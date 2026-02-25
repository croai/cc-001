import 'package:intl/intl.dart';

String formatPrice(int cents, String currency) {
  if (cents == 0) return 'Besplatno';
  final euros = cents / 100;
  final formatter = NumberFormat('#,##0.00', 'hr');
  return '${formatter.format(euros)} $currency';
}

String formatPriceShort(int cents, String currency) {
  if (cents == 0) return 'Free';
  final euros = cents / 100;
  final formatter = NumberFormat('#,##0.00', 'hr');
  return '${formatter.format(euros)} $currency';
}
