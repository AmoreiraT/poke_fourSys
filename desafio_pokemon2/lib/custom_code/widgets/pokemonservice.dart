// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// pokemon_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final double height;
  final double weight;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.types,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'],
      height: json['height'] / 10,
      weight: json['weight'] / 10,
      types:
          List<String>.from(json['types'].map((type) => type['type']['name'])),
    );
  }
}

Future<List<Pokemon>> getPokemons({int limit = 20, int offset = 0}) async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Pokemon> pokemons = [];

      for (var pokemon in data['results']) {
        final detailResponse = await http.get(Uri.parse(pokemon['url']));
        if (detailResponse.statusCode == 200) {
          final detailData = json.decode(detailResponse.body);
          pokemons.add(Pokemon.fromJson(detailData));
        }
      }
      return pokemons;
    } else {
      throw Exception('Failed to load pokemons');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
