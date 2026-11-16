class Validators {
  static String? required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? studentId(String? v) {
    if (v == null || v.trim().isEmpty) return 'Student ID is required';
    if (!RegExp(r'^\d{6,}$').hasMatch(v.trim())) return 'Digits only, at least 6';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!v.contains('@')) return "Email must contain '@'";
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.length < 8) return 'At least 8 characters';
    if (!v.contains('@')) return "Password must include '@'";
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Contact number is required';
    if (!RegExp(r'^0\d{9}$').hasMatch(v.trim())) return 'Enter 10 digits starting with 0';
    return null;
  }

  static String? topic(String? v) {
    if (v == null || v.trim().length < 20) return 'Minimum 20 characters';
    return null;
  }
}