import '../screens/home.dart';

class FavoriteManager {
  FavoriteManager._();

  static final Map<String, Country> _favorites = {};

  static List<Country> get favorites => _favorites.values.toList();

  static int get count => _favorites.length;

  static bool isFavorite(String name) => _favorites.containsKey(name);

  static void add(Country country) {
    _favorites[country.name] = country;
  }

  static void remove(String name) {
    _favorites.remove(name);
  }

  static bool toggle(Country country) {
    if (isFavorite(country.name)) {
      remove(country.name);
      return false;
    }
    add(country);
    return true;
  }

  static void clear() {
    _favorites.clear();
  }
}
