import 'package:flutter/material.dart';

import '../utils/history_manager.dart';
import 'detail.dart';
import 'home.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  void _openDetail(Country country) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(country: country),
      ),
    ).then((_) {
      // Refresh urutan karena buka ulang memindahkan item ke atas.
      if (mounted) setState(() {});
    });
  }

  void _removeItem(Country country) {
    setState(() {
      HistoryManager.remove(country.name);
    });
  }

  void _clearAll() {
    setState(() {
      HistoryManager.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = HistoryManager.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus Semua',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('Belum ada riwayat'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, i) {
                final country = history[i];
                return Card(
                  child: ListTile(
                    leading: country.flagsPng != null
                        ? Image.network(country.flagsPng!, width: 50)
                        : const SizedBox(width: 50),
                    title: Text(country.name),
                    subtitle: Text(country.region),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(country),
                    ),
                    onTap: () => _openDetail(country),
                  ),
                );
              },
            ),
    );
  }
}
