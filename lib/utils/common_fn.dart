import 'package:intl/intl.dart';

class CommonFn {
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  /// Capitalize the first letter of the string (e.g., "hello world" -> "Hello world")
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalize the first letter of each word (e.g., "hello world" -> "Hello World")
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Convert to uppercase (e.g., "hello" -> "HELLO")
  static String toUpperCase(String text) {
    return text.toUpperCase();
  }

  /// Get initials from a name (e.g., "John Doe" -> "JD")
  static String getInitials(String name) {
    if (name.isEmpty) return "";
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.isEmpty) return "";
    String initials = nameParts[0][0];
    if (nameParts.length > 1) {
      initials += nameParts[nameParts.length - 1][0];
    }
    return initials.toUpperCase();
  }

  /// Truncate text with ellipsis if it exceeds maxLength
  static String truncate(String text, {int maxLength = 20}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
