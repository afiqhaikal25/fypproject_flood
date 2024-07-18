import 'package:flutter/material.dart';
import 'package:realtimewater/pps.dart';
import 'monitor.dart';
import 'pps.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 2; // Assuming Profile is at index 2

  final Map<String, String> userProfile = {
    'Full Name': 'John Doe',
    'Email Address': 'john.doe@example.com',
    'Phone Number': '+1234567890',
    'Current Address': '123 Main Street, Springfield, USA',
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic based on the selected index
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MonitorPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPPS()),
        );
        break;
      case 2:
        // Current page is Profile, do nothing
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.white],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
              SizedBox(height: 20),
              Text(
                "User Information",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ...userProfile.entries.map((entry) => _buildInfoCard(entry.key, entry.value)),
              SizedBox(height: 20),
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

  Widget _buildInfoCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: _getIconForTitle(title),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Icon _getIconForTitle(String title) {
    switch (title) {
      case 'Full Name':
        return Icon(Icons.person);
      case 'Email Address':
        return Icon(Icons.email);
      case 'Phone Number':
        return Icon(Icons.phone);
      case 'Current Address':
        return Icon(Icons.home);
      default:
        return Icon(Icons.info);
    }
  }
}
