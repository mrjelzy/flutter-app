import 'package:flutter/material.dart';
import 'package:flutter_app_iot/services/firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppStateModel extends ChangeNotifier {
  final FireStoreService fireStoreService = FireStoreService();
  String? ledState;
  String? temp;
  String? lum;
  bool isRequestInProgress = false;

  Future<void> refreshData() async {
    await fetchTemperature();
    await fetchLedState();
    await fetchLum();
  }

Future<void> fetchLedState() async {
    isRequestInProgress = true;
    notifyListeners();

    final response = await http.get(Uri.parse('http://192.168.1.110/led'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      ledState = data['LED'];
    } else {
      throw Exception('Failed to load LED status');
    }

    isRequestInProgress = false;
    notifyListeners();
  }

  Future<void> fetchTemperature() async {
    final response = await http.get(Uri.parse('http://192.168.1.110/sensor/temp'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      temp = data['TEMP'];
      fireStoreService.addTemp(temp!);
    } else {
      throw Exception('Failed to load temperature');
    }

    notifyListeners();
  }

  Future<void> fetchLum() async {
    final response = await http.get(Uri.parse('http://192.168.1.110/sensor/lum'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      lum = data['LUM'];
      fireStoreService.addLum(lum!);
    } else {
      throw Exception('Failed to load light');
    }

    notifyListeners();
  }

  Future<void> toggleLedState() async {
      isRequestInProgress = true;
      notifyListeners();

      final currentState = ledState == "ON" ? "OFF" : "ON";

      final response = await http.post(
        Uri.parse('http://192.168.1.110/led'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'LED': currentState}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        ledState = data['LED'];
        fireStoreService.addLed(ledState!);
      } else {
        throw Exception('Failed to post LED state');
      }

      isRequestInProgress = false;
      notifyListeners();
    }

}
