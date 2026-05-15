import 'package:intl/intl.dart';

String formatMessageDate(DateTime value) {
  final now = DateTime.now();
  final local = value.toLocal();
  if (now.difference(local).inDays == 0 && now.day == local.day) {
    return DateFormat.Hm().format(local);
  }
  if (now.year == local.year) {
    return DateFormat('MMM d').format(local);
  }
  return DateFormat.yMMMd().format(local);
}
