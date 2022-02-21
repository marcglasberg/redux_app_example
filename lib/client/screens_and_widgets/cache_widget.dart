import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';

class Cache_Widget extends StatelessWidget {
  //
  final IMap<int, String> descriptions;
  final VoidCallback onClearCache;
  final VoidCallback onBack;
  final ValueSetter<int> onTapCacheItem;

  Cache_Widget({
    required this.descriptions,
    required this.onClearCache,
    required this.onBack,
    required this.onTapCacheItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cache')),
      body: Box(
        child: Column(
          children: [
            _header(),
            Expanded(child: _list()),
            Box(
              height: 56,
              color: Colors.black,
              padding: const Pad(all: 8),
              child: Row(
                children: [
                  Expanded(child: _clearButton()),
                  const Box(width: 10),
                  Expanded(child: _backButton()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const Pad(top: 20.0, bottom: 20, horizontal: 12.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            descriptions.isEmpty
                ? 'The memory cache is empty.'
                : 'These are the numbers in memory:',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );

  Widget _list() => ListView(
        children: descriptions.entries
            .map(
              (MapEntry<int, String> entry) => _listTile(entry),
            )
            .toList(),
      );

  Widget _listTile(MapEntry<int, String> entry) {
    return Column(
      children: [
        ListTile(
          title: Text('Number ${entry.key}'),
          subtitle: Text(entry.value),
          onTap: () => onTapCacheItem(entry.key),
        ),
        const Divider(),
      ],
    );
  }

  Widget _clearButton() => ElevatedButton(
        child: const Text('Clear Cache'),
        onPressed: onClearCache,
      );

  Widget _backButton() => ElevatedButton(
        child: const Text('Back'),
        onPressed: onBack,
      );
}
