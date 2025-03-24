class Validators {
  static String? Function(String?) required(String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }
  
  static String? Function(String?) email(String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }
      
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return message;
      }
      
      return null;
    };
  }
  
  static String? Function(String?) password(String message, {int minLength = 6}) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      
      if (value.length < minLength) {
        return message;
      }
      
      return null;
    };
  }
  
  static String? Function(String?) numeric(String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      
      if (double.tryParse(value) == null) {
        return message;
      }
      
      return null;
    };
  }
  
  static String? Function(String?) match(String other, String message) {
    return (value) {
      if (value != other) {
        return message;
      }
      
      return null;
    };
  }
}

