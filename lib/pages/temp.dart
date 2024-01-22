import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/state.dart';

class TempPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, appState, child) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Mesure de la Température'),
        ),
        child: FutureBuilder<Map<DateTime, double>>(
          future: appState.fireStoreService.averageTempPerDay(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator()); // Cupertino style
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text('Erreur ou pas de données', 
                style: TextStyle(fontSize: 18, color: CupertinoColors.systemRed)),
              );
            }

            var tempsData = snapshot.data!;
            DateTime? hottestDay;
            DateTime? coldestDay;
            double highestTemp = -double.infinity;
            double lowestTemp = double.infinity;

            // Trouvez la journée la plus chaude et la plus froide
            tempsData.forEach((date, temp) {
              if (temp > highestTemp) {
                highestTemp = temp;
                hottestDay = date;
              }
              if (temp < lowestTemp) {
                lowestTemp = temp;
                coldestDay = date;
              }
            });

            return SingleChildScrollView(
              child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tempsData.length,
                    itemBuilder: (context, index) {
                      DateTime date = tempsData.keys.elementAt(index);
                      double avgTemp = tempsData[date]!;
                      return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: CupertinoColors.systemGrey),
                            ),
                          ),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${date.day}/${date.month}/${date.year}",
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                "Température : ${avgTemp.toStringAsFixed(2)}°C",
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ), 
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10), // Espacement entre les lignes
                      Text(
                        "Journée la plus froide : ${coldestDay!.day}/${coldestDay!.month}/${coldestDay!.year} ${lowestTemp.toStringAsFixed(2)}°C",
                        style: TextStyle(
                          fontSize: 18,
                          color: CupertinoColors.activeBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                        Text(
                        "Journée la plus chaude : ${hottestDay!.day}/${hottestDay!.month}/${hottestDay!.year} ${highestTemp.toStringAsFixed(2)}°C",
                        style: TextStyle(
                          fontSize: 18,
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            )); 
          },
        ),
      ),
    );
  }
}
