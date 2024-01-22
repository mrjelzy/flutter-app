import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_iot/pages/temp.dart';
import './firebase_options.dart';
import 'package:provider/provider.dart';
import 'models/state.dart';
import 'pages/home.dart';
import 'pages/led.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
      create: (context) => AppStateModel(),
      child: const MyApp()
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Flutter Demo',
      theme: CupertinoThemeData(
        // Vous pouvez personnaliser le thème ici
      ),
      home: MyEntryPoint(),
    );
  }
}

class MyEntryPoint extends StatefulWidget {
  const MyEntryPoint({Key? key}) : super(key: key);

  @override
  _MyEntryPointState createState() => _MyEntryPointState();
}

class _MyEntryPointState extends State<MyEntryPoint> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.lightbulb),
            label: 'LED',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.thermometer),
            label: 'Température',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(CupertinoIcons.chart_bar_circle),
          //   label: 'Luminosité',
          // ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const MyHomePage(title: 'Home',); 
          case 1:
            return LEDPage();
          case 2:
            return TempPage();
          default:
            return const Center(
              child: Text('Page non trouvée'),
            );
        }
      },
    );
  }
}
