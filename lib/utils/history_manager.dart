import '../screens/home.dart';

class HistoryManager {
  HistoryManager._();

  static final List<Country> _history = [];

  static List<Country> get history => List.unmodifiable(_history);

  static int get count => _history.length;

  static bool get isEmpty => _history.isEmpty;

  static bool contains(String name) =>
      _history.any((c) => c.name == name);

  static void visit(Country country) {
    _history.removeWhere((c) => c.name == country.name);
    _history.insert(0, country);
  }

  static void remove(String name) {
    _history.removeWhere((c) => c.name == name);
  }

  static void clear() {
    _history.clear();
  }
}
