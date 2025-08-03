void main() {
  const String test = 'hello';
  final DateTime now = DateTime.now();
  // Use the variables to avoid unused warnings
  assert(test.isNotEmpty);
  assert(now.isBefore(DateTime.now().add(const Duration(seconds: 1))));
}