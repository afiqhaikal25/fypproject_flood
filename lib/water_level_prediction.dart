import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class WaterLevelPredictionPage extends StatefulWidget {
  @override
  _WaterLevelPredictionPageState createState() => _WaterLevelPredictionPageState();
}

class _WaterLevelPredictionPageState extends State<WaterLevelPredictionPage> {
  String _predictionMessage = "Fetching predictions...";
  Timer? _predictionTimer;

  @override
  void initState() {
    super.initState();
    _fetchPrediction();
    _predictionTimer = Timer.periodic(Duration(minutes: 1), (timer) => _fetchPrediction());
  }

  @override
  void dispose() {
    _predictionTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrediction() async {
    try {
      final channelID = '2573738';
      final readAPIKey = '6FGVERS9VBJUS832';
      final url = 'https://api.thingspeak.com/channels/$channelID/fields/1.json?api_key=$readAPIKey&results=100';
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final feeds = jsonResponse['feeds'];
        if (feeds != null && feeds.length > 1) {
          List<double> waterLevels = [];
          List<DateTime> timestamps = [];

          for (var feed in feeds) {
            double waterLevel = double.parse(feed['field1']);
            DateTime timestamp = DateTime.parse(feed['created_at']);
            waterLevels.add(waterLevel);
            timestamps.add(timestamp);
          }

          // Perform linear regression to predict future water levels
          List<double> predictedWaterLevels = _performLinearRegression(waterLevels, timestamps);

          setState(() {
            _predictionMessage = 'Predicted water levels for the next 10 minutes:\n';
            for (var i = 0; i < predictedWaterLevels.length; i++) {
              _predictionMessage += '${timestamps.last.add(Duration(minutes: i + 1)).toIso8601String()}: ${predictedWaterLevels[i].toStringAsFixed(2)} cm\n';
            }
          });
        }
      } else {
        setState(() {
          _predictionMessage = "Error fetching prediction data.";
        });
      }
    } catch (e) {
      setState(() {
        _predictionMessage = "Error fetching prediction data.";
      });
    }
  }

  List<double> _performLinearRegression(List<double> waterLevels, List<DateTime> timestamps) {
    int n = waterLevels.length;
    if (n < 2) return [];

    List<double> timeNumeric = timestamps.map((t) => t.millisecondsSinceEpoch.toDouble()).toList();
    double meanTime = timeNumeric.reduce((a, b) => a + b) / n;
    double meanLevel = waterLevels.reduce((a, b) => a + b) / n;

    double numerator = 0.0;
    double denominator = 0.0;

    for (int i = 0; i < n; i++) {
      numerator += (timeNumeric[i] - meanTime) * (waterLevels[i] - meanLevel);
      denominator += (timeNumeric[i] - meanTime) * (timeNumeric[i] - meanTime);
    }

    double slope = numerator / denominator;
    double intercept = meanLevel - slope * meanTime;

    List<double> futurePredictions = [];
    for (int i = 1; i <= 10; i++) {
      double futureTime = timeNumeric.last + i * 60000; // Predicting for the next 10 minutes
      double futureLevel = slope * futureTime + intercept;
      futurePredictions.add(futureLevel);
    }

    return futurePredictions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Level Predictions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.timeline, size: 30, color: Colors.green[700] ?? Colors.green),
                  SizedBox(height: 4),
                  Text(
                    'Water Level Predictions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      _predictionMessage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700] ?? Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
