import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:realtimewater/historical_data_page.dart';
import 'profile.dart';
import 'pps.dart';
import 'water_level_prediction.dart'; // Import the new water level prediction page
import 'river.dart'; // Import the river list screen

class MonitorPage extends StatefulWidget {
  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  double _waterLevel = 0.0;
  String _status = "Fetching data...";
  String _timestamp = "Fetching time...";
  Timer? _dataTimer;
  Timer? _clockTimer;
  Timer? _locationCheckTimer;
  bool _isDarkMode = false;
  String _selectedRiver = 'Sungai Dungun';
  int _selectedIndex = 0;
  Position? _currentPosition;
  final double defaultLatitude = 5.2623829;
  final double defaultLongitude = 103.1642446;
  final double radius = 250.0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAlarmPlaying = false;
  bool _isPopupShown = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _dataTimer = Timer.periodic(Duration(seconds: 5), (timer) => _fetchData());
    _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) => _updateTime());
    _locationCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) => _getCurrentLocation());
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    _clockTimer?.cancel();
    _locationCheckTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final channelID = '2573738';
      final readAPIKey = '6FGVERS9VBJUS832';
      final url = 'https://api.thingspeak.com/channels/$channelID/fields/1/last.json?api_key=$readAPIKey';
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final waterLevel = double.parse(jsonResponse['field1']);
        setState(() {
          _waterLevel = waterLevel;
          _status = _getStatusLevel(waterLevel);
          _timestamp = jsonResponse['created_at'];
        });
        if (_status == "DANGER LEVEL" && !_isPopupShown) {
          _playAlarmSound();
          _showEvacuationAlert();
        }
      } else {
        setState(() {
          _status = "Error fetching data.";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error fetching data.";
      });
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timestamp = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    });
  }

  String _getStatusLevel(double waterLevel) {
    if (waterLevel == 0.0) {
      return "SAFE LEVEL";
    } else if (waterLevel > 9.0) {
      return "DANGER LEVEL";
    } else if (waterLevel > 6.0) {
      return "WARNING LEVEL";
    } else if (waterLevel > 3.0) {
      return "ALERT LEVEL";
    } else {
      return "SAFE LEVEL";
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "DANGER LEVEL":
        return Colors.red;
      case "WARNING LEVEL":
        return Colors.orange;
      case "ALERT LEVEL":
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {});
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {});
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {});
      return;
    }

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _updateLocationMessage();
  }

  void _updateLocationMessage() {
    if (_currentPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        defaultLatitude,
        defaultLongitude,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      setState(() {});

      if (distanceInMeters > radius) {
        _stopAlarmSound();
      }
    } else {
      setState(() {});
    }
  }

  Future<void> _playAlarmSound() async {
    if (!_isAlarmPlaying) {
      _isAlarmPlaying = true;
      await _audioPlayer.setSource(AssetSource('alarm_sound.mp3'));
      await _audioPlayer.resume();
    }
  }

  Future<void> _stopAlarmSound() async {
    if (_isAlarmPlaying) {
      _isAlarmPlaying = false;
      await _audioPlayer.stop();
    }
  }

  void _showEvacuationAlert() {
    setState(() {
      _isPopupShown = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Evacuation Alert!",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.red, size: 50),
              SizedBox(height: 16),
              Text(
                "The water level has reached the danger level. Please evacuate immediately!",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _stopAlarmSound().then((_) {
                  setState(() {
                    _isPopupShown = false;
                  });
                  Navigator.of(context).pop();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text("Stop Alarm"),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPPS()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
    }
  }

  void _selectRiver() async {
    final selectedRiverName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RiverListScreen()),
    );
    if (selectedRiverName != null) {
      setState(() {
        _selectedRiver = selectedRiverName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _selectRiver,
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white),
                  SizedBox(width: 8),
                  Text(_selectedRiver, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.wb_sunny, color: _isDarkMode ? Colors.white : Colors.yellow),
              Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.yellow,
                inactiveTrackColor: Colors.grey,
              ),
              Icon(Icons.brightness_3, color: _isDarkMode ? Colors.white : Colors.grey),
            ],
          ),
          SizedBox(width: 8),
        ],
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isDarkMode ? [Colors.black, Colors.grey] : [Colors.blue, Colors.white],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildStatusCard(),
              SizedBox(height: 16),
              _buildWaterLevelCard(),
              SizedBox(height: 16),
              _buildTimestampCard(),
              SizedBox(height: 16),
              _buildAdvanceMonitoringCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Register PPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(Icons.warning, size: 30, color: _statusColor(_status)),
            SizedBox(height: 12),
            Text(
              'Status Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              _status,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterLevelCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(Icons.opacity, size: 30, color: Colors.blue),
            SizedBox(height: 12),
            Text(
              'Water Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              '$_waterLevel cm',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(Icons.access_time, size: 30, color: Colors.green),
            SizedBox(height: 12),
            Text(
              'Timestamp',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              _timestamp,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvanceMonitoringCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(Icons.diamond, size: 30, color: Colors.purple[700] ?? Colors.purple),
            SizedBox(height: 12),
            Text(
              'Advance Monitoring (Premium)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoricalDataPage()),
                );
              },
              child: Text('View Historical Data'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WaterLevelPredictionPage()),
                );
              },
              child: Text('Water Level Predictions'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
