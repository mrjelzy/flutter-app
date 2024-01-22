import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/state.dart';
import 'package:provider/provider.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
      final state = context.read<AppStateModel>();
      state.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return  Consumer<AppStateModel> (
    builder: (context, value, child) {
    IconData lumIcon = value.lum != null && double.tryParse(value.lum!)! < 1250 
                           ? CupertinoIcons.moon : CupertinoIcons.sun_max;
    String lumText = "Luminosité: ${value.lum ?? '...'}";

    return CupertinoPageScaffold(
      child : Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: CustomScrollView(
            slivers: <Widget>[
            CupertinoSliverRefreshControl(
            onRefresh: () async { 
              final state = context.read<AppStateModel>();
              await state.refreshData();
            },
            ),
            const SliverToBoxAdapter(  
              child: Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  'Bienvenue, ',
                  textAlign: TextAlign.left, // Alignement du texte au centre
                  style: TextStyle(
                    fontSize: 27.0,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.black,
            )))),
            const SliverToBoxAdapter(  
              child: Padding(
                padding: EdgeInsets.only(top: 10,left: 30.0),
                child: Text(
                  'Vous avez une vue d\'ensemble sur les capteurs ',
                  textAlign: TextAlign.left, // Alignement du texte au centre
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black,
            )))),
            SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.only(top: 30.0), // Ajoute un espace sur les côtés
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                      _buildCard(value.temp, "temperature", context),
                      _buildCard(value.ledState, "light", context),   
                  ],))),
              SliverToBoxAdapter(
                child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildFullWidthCard(lumText, lumIcon, context),
              )),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 30.0, right: 25, left: 25),
                child: TemperatureLuminosityMessage(
                  lum: value.lum,
                  temp: value.temp,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 120.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Icon(CupertinoIcons.down_arrow, color: CupertinoColors.systemGrey),
                      Text(
                        'Tirez vers le bas pour rafraîchir',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16.0,
              ))]))))
          ]
          ),
      )
       );}
  );
  }

  Widget _buildCard(String? data, String type, BuildContext context) {
    IconData displayIcon = CupertinoIcons.question_circle;
    String displayText = '';

    if (type == "light") {
      displayIcon = (data == "ON") ? CupertinoIcons.lightbulb_fill : CupertinoIcons.lightbulb;
      displayText = 'LED ${data ?? '...'}';
    } else if (type == "temperature") {
      displayText = "${data ?? '...'} °C";
      displayIcon = CupertinoIcons.thermometer;
    }
  return 
  Consumer<AppStateModel> (
      builder: (context, value, child) => GestureDetector(
      onTap: () {
        final state = context.read<AppStateModel>();
        if (!value.isRequestInProgress && type == "light") {
          state.toggleLedState();
        }
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2.0,
      child: Container(
        width: 150,
        height: 100,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(displayIcon, size: 28.0, color: CupertinoColors.activeBlue),
            const SizedBox(width: 3),
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 20.0,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ],
        ),
      ),
    ),
  ));
}

Widget _buildFullWidthCard(String text, IconData icon, BuildContext context) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 2.0,
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 28.0, color: CupertinoColors.activeBlue),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 20.0,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ],
      ),
    ),
  );
}
  
}

class TemperatureLuminosityMessage extends StatelessWidget {
  final String? lum;
  final String? temp;

  TemperatureLuminosityMessage({this.lum, this.temp});

  @override
  Widget build(BuildContext context) {
    String lumMessage = getLuminosityMessage();
    String tempMessage = getTemperatureMessage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lumMessage.isNotEmpty) 
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(lumMessage, style: TextStyle(fontSize: 20, color: CupertinoColors.black, fontWeight: FontWeight.w500)),
          ),
        if (tempMessage.isNotEmpty) 
          Text(tempMessage, style: TextStyle(fontSize: 20, color: CupertinoColors.black, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String getLuminosityMessage() {
    if (lum != null && double.tryParse(lum!)! > 1250) {
      return "Vous êtes dans un endroit plutôt éclairé.";
    }
    return "Vous êtes dans un endroit plutôt sombre.";
  }

  String getTemperatureMessage() {
    if (temp != null) {
      double tempValue = double.tryParse(temp!)!;
      if (tempValue < 16) {
        return "Il fait plutôt froid ici.";
      } else if (tempValue > 25) {
        return "Il fait chaud ici.";
      } else if (tempValue >= 20) {
        return "Il fait une température agréable.";
      }
    }
    return "";
  }
}
