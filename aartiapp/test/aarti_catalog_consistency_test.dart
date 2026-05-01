import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aartiapp/data/repositories/aarti_repository.dart';

void main() {
  group('aarti catalog asset', () {
    const allowedTypes = <String>{
      'aarti',
      'abhang',
      'bhajan',
      'chalisa',
      'chant',
      'mantra',
      'shloka',
      'stotra',
      'vandana',
    };

    late Map<String, dynamic> root;

    setUpAll(() {
      final jsonStr = File('assets/data/aarti_catalog.json').readAsStringSync();
      root = json.decode(jsonStr) as Map<String, dynamic>;
    });

    test('parses through the repository loader', () {
      final repository = AartiRepository.instance;
      expect(
        () => repository.loadFromJsonString(
          json.encode(root),
          source: 'test',
        ),
        returnsNormally,
      );
      expect(repository.aartis, isNotEmpty);
      expect(repository.deities, isNotEmpty);
    });

    test('declares every aarti deity in the top-level deity list', () {
      final deityLabels = ((root['deities'] as List<dynamic>?) ?? const [])
          .map((entry) => (entry as Map<String, dynamic>)['label'] as String)
          .toSet();

      final aartis = (root['aartis'] as List<dynamic>?) ?? const [];
      final undeclared = aartis
          .map((entry) => entry as Map<String, dynamic>)
          .where((entry) => !deityLabels.contains(entry['deity']))
          .map((entry) => '${entry['id']}:${entry['deity']}')
          .toList();

      expect(undeclared, isEmpty);
    });

    test('uses unique aarti ids', () {
      final aartis = (root['aartis'] as List<dynamic>?) ?? const [];
      final ids = aartis
          .map((entry) => (entry as Map<String, dynamic>)['id'] as String)
          .toList();

      final duplicates = ids
          .where((id) => ids.where((candidate) => candidate == id).length > 1)
          .toSet()
          .toList()
        ..sort();

      expect(duplicates, isEmpty);
    });

    test('declares an allowed type for every aarti', () {
      final aartis = (root['aartis'] as List<dynamic>?) ?? const [];
      final invalid = aartis
          .map((entry) => entry as Map<String, dynamic>)
          .where((entry) => !allowedTypes.contains(entry['type']))
          .map((entry) => '${entry['id']}:${entry['type']}')
          .toList();

      expect(invalid, isEmpty);
    });
  });
}