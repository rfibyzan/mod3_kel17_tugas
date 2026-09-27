import 'package:flutter/material.dart';

import '../utils/favorite_manager.dart';
import 'detail.dart';
import 'home.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  void _openDetail(Country country) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(country: country),
      ),
    ).then((_) {
      // Refresh karena status favorit bisa berubah dari Detail.
      if (mounted) setState(() {});
    });
  }

  void _removeFavorite(Country country) {
    setState(() {
      FavoriteManager.remove(country.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = FavoriteManager.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: favorites.isEmpty
          ? const Center(child: Text('Belum ada favorit'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, i) {
                final country = favorites[i];
                return Card(
                  child: ListTile(
                    leading: country.flagsPng != null
                        ? Image.network(country.flagsPng!, width: 50)
                        : const SizedBox(width: 50),
                    title: Text(country.name),
                    subtitle: Text(country.region),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFavorite(country),
                    ),
                    onTap: () => _openDetail(country),
                  ),
                );
              },
            ),
    );
  }
}
