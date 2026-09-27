import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';

import 'detail.dart';
import '../utils/favorite_manager.dart';
import '../utils/history_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countries;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedRegion = 'Semua Benua';

  static const List<String> regions = [
    'Semua Benua',
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
  ];

  @override
  void initState() {
    super.initState();
    countries = fetchCountries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse('https://www.apicountries.com/countries');
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final respBody = await response.transform(utf8.decoder).join();
      final List jsonData = jsonDecode(respBody);
      return jsonData.map((j) => Country.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari negara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _query = '';
                          });
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Text('Benua: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedRegion,
                    isExpanded: true,
                    items: regions
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedRegion = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Country>>(
              future: countries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No countries found'));
                }

                final all = snapshot.data!;
                final q = _query.trim().toLowerCase();
                final list = all.where((c) {
                  final matchQuery =
                      q.isEmpty || c.name.toLowerCase().contains(q);
                  final matchRegion = _selectedRegion == 'Semua Benua' ||
                      c.region == _selectedRegion;
                  return matchQuery && matchRegion;
                }).toList();

                if (list.isEmpty) {
                  return const Center(child: Text('No countries found'));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final country = list[i];
                    return Card(
                      child: ListTile(
                        leading: country.flagsPng != null
                            ? Image.network(country.flagsPng!, width: 50)
                            : const SizedBox(width: 50),
                        title: Text(country.name),
                        subtitle: Text(country.region),
                        trailing: IconButton(
                          icon: Icon(
                            FavoriteManager.isFavorite(country.name)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: FavoriteManager.isFavorite(country.name)
                                ? Colors.red
                                : null,
                          ),
                          onPressed: () {
                            setState(() {
                              FavoriteManager.toggle(country);
                            });
                          },
                        ),
                        onTap: () {
                          HistoryManager.visit(country);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(country: country),
                            ),
                          ).then((_) {
                            // Refresh icon favorit karena bisa diubah dari Detail.
                            if (mounted) setState(() {});
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Country {
  final String name;
  final String region;
  final String? capital;
  final int population;
  final String? flagsPng;
  final List<dynamic>? languages;
  final List<dynamic>? currencies;

  Country({
    required this.name,
    required this.region,
    required this.population,
    this.capital,
    this.flagsPng,
    this.languages,
    this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    List<dynamic>? langs;
    if (json['languages'] != null) {
      langs = (json['languages'] as List)
          .map((l) => l['name'].toString())
          .toList();
    }

    List<dynamic>? cur;
    if (json['currencies'] != null) {
      cur = (json['currencies'] as List)
          .map((c) => c['name'].toString())
          .toList();
    }

    return Country(
      name: json['name'] ?? 'N/A',
      region: json['region'] ?? 'N/A',
      population: json['population'] ?? 0,
      capital: json['capital'],
      flagsPng: json['flags'] != null ? json['flags']['png'] : null,
      languages: langs,
      currencies: cur,
    );
  }
}
