import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/state.dart';
import 'package:provider/provider.dart';

class LEDPage extends StatefulWidget {
  @override
  _LEDPageState createState() => _LEDPageState();
}

class _LEDPageState extends State<LEDPage> {
  double _seuilLum = 1250; // Valeur initiale du seuil

  void _updateLedState(AppStateModel appState) {
    if (appState.lum != null) {
      final lumValue = double.tryParse(appState.lum!) ?? 0;
      if (lumValue < _seuilLum) {
        if (appState.ledState != "ON") {
          appState.toggleLedState();
        }
      } else {
        if (appState.ledState != "OFF") {
          appState.toggleLedState();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, appState, child) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Contrôle de la LED'),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.scale(
                scale: 2,
                child: CupertinoSwitch(
                  value: appState.ledState == "ON",
                  onChanged: (bool newValue) {
                    appState.toggleLedState();
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                appState.ledState == "ON" ? 'La LED est Allumée' : 'La LED est Éteinte',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              SizedBox(height: 20),
              Container(height: 1, color: Colors.grey),
              SizedBox(height: 20),
              Text('Seuil de Luminosité Actuel : ${appState.lum}'),
              Text('Seuil de Luminosité : ${_seuilLum.round()}'),
              CupertinoSlider(
                  value: _seuilLum,
                  min: 0,
                  max: 2500,
                  onChanged: (double newValue) {
                    setState(() {
                      _seuilLum = newValue;
                    });
                    _updateLedState(appState);
                  },
                ),
              Container(height: 1, color: Colors.grey),
              SizedBox(height: 20),
                const Center( // Centrer le texte
                  child: Text("Changements d'états de la led", 
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                ),              
                SizedBox(height: 30),
                Padding( // Ajouter des marges autour du graphique
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child:
                      FutureBuilder<Map<DateTime, int>>(
                        future: appState.fireStoreService.countLedChangesPerDay(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CupertinoActivityIndicator();
                          }
                          if (snapshot.hasError) {
                            return const Text('Erreur lors du chargement des données');
                          }
                          return SizedBox(
                            height: 300, // Hauteur fixe pour le graphique
                            child: LEDChart(changesPerDay: snapshot.data!),
                          );
                        },
                      )
                )
            ],
          ),
        ),
      ),
    );
  }
}

class LEDChart extends StatelessWidget {
  final Map<DateTime, int> changesPerDay;

  LEDChart({required this.changesPerDay});

 @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    List<DateTime> sortedDates = changesPerDay.keys.toList()..sort();
    for (var date in sortedDates) {
      int x = sortedDates.indexOf(date);
      double y = changesPerDay[date]?.toDouble() ?? 0;
      if (y.isNaN || y.isInfinite) {
        y = 0;
      }
      barGroups.add(BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            color: CupertinoColors.activeBlue, // Choisissez votre couleur
            borderRadius: BorderRadius.circular(4), // Bords arrondis
          )
        ],
        // Vous pouvez ajouter un fond pour chaque barre si nécessaire
      ));
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              if (index >= 0 && index < sortedDates.length) {
                DateTime date = sortedDates[index];
                return Text('${date.day}/${date.month}');
              }
              return const Text('');
            }),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text('${value.toInt()}');
            }),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Masquer les titres en haut
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Masquer les titres à droite
        ),
        borderData: FlBorderData(
          show: false,
          border: const Border(
            left: BorderSide.none,
            bottom: BorderSide.none,
            right: BorderSide.none, // Masque la bordure droite
            top: BorderSide.none), // Masque la bordure supérieure // Masquer ou montrer la bordure
        ),
        gridData: FlGridData(
          show: false,
        ),
        ),
    );
  }
}


