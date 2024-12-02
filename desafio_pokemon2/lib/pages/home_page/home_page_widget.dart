// home_page_widget.dart
import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final List<Pokemon> _pokemons = [];
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 151;

  @override
  void initState() {
    super.initState();
    _loadPokemons();
  }

  FutureOr<void> _loadPokemons() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://pokeapi.co/api/v2/pokemon?limit=$_limit&offset=$_offset'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        for (var pokemon in data['results']) {
          final detailResponse = await http.get(Uri.parse(pokemon['url']));
          if (detailResponse.statusCode == 200) {
            final pokemonData = jsonDecode(detailResponse.body);
            setState(() {
              _pokemons.add(Pokemon.fromJson(pokemonData));
            });
          }
        }

        setState(() {
          _offset += _limit;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading Pokémon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FourSys Pokédex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _pokemons.clear();
                _offset = 0;
              });
              _loadPokemons();
            },
          ),
        ],
      ),
      body: _isLoading && _pokemons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable2(
                columns: [
                  DataColumn2(
                    label: const Text('ID'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: const Text('Imagem'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: const Text('Nome'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: const Text('Elementos'),
                    size: ColumnSize.L,
                  ),
                ],
                rows: _pokemons.map((pokemon) {
                  return DataRow2(
                    cells: [
                      DataCell(
                          Text('#${pokemon.id.toString().padLeft(3, '0')}')),
                      DataCell(
                        CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          height: 50,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      DataCell(Text(pokemon.name.toUpperCase())),
                      DataCell(
                        Wrap(
                          spacing: 8,
                          children: pokemon.types.map((type) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(type),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Color _getTypeColor(String type) {
    final colors = {
      'normal': const Color(0xFFA8A878),
      'fire': const Color(0xFFF08030),
      'water': const Color(0xFF6890F0),
      'electric': const Color(0xFFF8D030),
      'grass': const Color(0xFF78C850),
      'ice': const Color(0xFF98D8D8),
      'fighting': const Color(0xFFC03028),
      'poison': const Color(0xFFA040A0),
      'ground': const Color(0xFFE0C068),
      'flying': const Color(0xFFA890F0),
      'psychic': const Color(0xFFF85888),
      'bug': const Color(0xFFA8B820),
      'rock': const Color(0xFFB8A038),
      'ghost': const Color(0xFF705898),
      'dragon': const Color(0xFF7038F8),
      'dark': const Color(0xFF705848),
      'steel': const Color(0xFFB8B8D0),
      'fairy': const Color(0xFFEE99AC),
    };
    return colors[type.toLowerCase()] ?? Colors.grey;
  }
}

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'],
      types:
          List<String>.from(json['types'].map((type) => type['type']['name'])),
    );
  }
}
