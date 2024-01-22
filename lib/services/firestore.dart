import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  
  final CollectionReference leds = FirebaseFirestore.instance.collection('leds');
  final CollectionReference temps = FirebaseFirestore.instance.collection('temps');
  final CollectionReference lums = FirebaseFirestore.instance.collection('lums');

  Future<void> addLed(String state){
    return leds.add({
      'state' : state,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> addTemp(String temp){
    return temps.add({
      'temp' : temp,
      'timestamp': Timestamp.now(),
    });
  }

    Future<void> addLum(String lum){
    return lums.add({
      'lum' : lum,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getLeds(){
      final ledsStream = leds.orderBy('timestamp', descending: true).snapshots();
      return ledsStream;
    }

    Future<Map<DateTime, int>> countLedChangesPerDay() async {
    Map<DateTime, int> changesPerDay = {};
    DateTime today = DateTime.now();
    DateTime startDate = today.subtract(const Duration(days: 7));

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('leds')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startDate))
        .get();

    for (var doc in snapshot.docs) {
      Timestamp timestamp = doc['timestamp'];
      DateTime date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);

      if (!changesPerDay.containsKey(date)) {
        changesPerDay[date] = 1;
      } else {
        changesPerDay[date] = (changesPerDay[date] ?? 0) + 1;
      }
    }

    return changesPerDay;
  }

  Future<Map<DateTime, double>> averageTempPerDay() async {
    Map<DateTime, List<double>> tempData = {};
    DateTime today = DateTime.now();
    DateTime startDate = today.subtract(const Duration(days: 7));

    QuerySnapshot snapshot = await temps
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startDate))
        .get();

    for (var doc in snapshot.docs) {
      Timestamp timestamp = doc['timestamp'];
      DateTime date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);
      double temp = double.tryParse(doc['temp']) ?? 0;

      tempData.putIfAbsent(date, () => []).add(temp);
    }

    Map<DateTime, double> averageTemps = {};
    tempData.forEach((date, temps) {
      averageTemps[date] = temps.reduce((a, b) => a + b) / temps.length;
    });

    return averageTemps;
  }
}