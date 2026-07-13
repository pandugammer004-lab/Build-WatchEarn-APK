class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateReferralCode(String? code) {
    if (code != null && code.isNotEmpty && code.length != 6) {
      return 'Referral code must be 6 characters long';
    }
    return null;
  }

  static String? validatePaypalEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'PayPal email is required';
    }
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Enter a valid PayPal email address';
    }
    return null;
  }

  static String? validateAmount(String? amount, double min) {
    if (amount == null || amount.isEmpty) {
      return 'Amount is required';
    }
    final double? parsed = double.tryParse(amount);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < min) {
      return 'Minimum withdrawal amount is \$${min.toStringAsFixed(2)}';
    }
    return null;
  }
}
