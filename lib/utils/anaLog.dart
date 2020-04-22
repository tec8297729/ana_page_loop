bool _isTest = false;

class AnaLog {
  static p(String text) {
    if (_isTest) {
      print(text);
    }
  }
}
