// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:desafio_pokemon2/pages/home_page/home_page_model.dart';

import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Pokemon> pokemons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Pokemon> tempPokemons = [];

        for (var pokemon in data['results']) {
          final detailResponse = await http.get(Uri.parse(pokemon['url']));
          if (detailResponse.statusCode == 200) {
            final detailData = json.decode(detailResponse.body);
            tempPokemons.add(Pokemon(
              id: detailData['id'],
              name: pokemon['name'],
              imageUrl: detailData['sprites']['other']['official-artwork']
                  ['front_default'],
              height: detailData['height'],
              weight: detailData['weight'],
              types: List<String>.from(
                  detailData['types'].map((type) => type['type']['name'])),
            ));
          }
        }

        setState(() {
          pokemons = tempPokemons;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching pokemon data: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Pokédex',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: DataTable2(
                    columns: const [
                      DataColumn2(
                        label: Text('#'),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Text('Image'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('Name'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Types'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('Height'),
                        size: ColumnSize.S,
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Weight'),
                        size: ColumnSize.S,
                        numeric: true,
                      ),
                    ],
                    rows: pokemons.map((pokemon) {
                      return DataRow(
                        cells: [
                          DataCell(Text('#${pokemon.id}')),
                          DataCell(
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CachedNetworkImage(
                                imageUrl: pokemon.imageUrl,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                          DataCell(Text(
                            pokemon.name.capitalize(),
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          )),
                          DataCell(
                            Wrap(
                              spacing: 4,
                              children: pokemon.types.map((type) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(type),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    type.capitalize(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          DataCell(Text('${pokemon.height / 10}m')),
                          DataCell(Text('${pokemon.weight / 10}kg')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
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
  final int height;
  final int weight;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.types,
  });
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
