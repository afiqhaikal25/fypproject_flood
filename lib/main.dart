import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';
import 'monitor.dart';
import 'river.dart';
import 'signup.dart';
import 'mock_backend.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MockBackend backend = MockBackend();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(backend: backend),
      routes: {
        '/login': (context) => LoginScreen(backend: backend),
        '/monitor': (context) => MonitorPage(),
        '/rivers': (context) => RiverListScreen(),
        '/signup': (context) => SignUpPage(backend: backend),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  final MockBackend backend;

  MainScreen({required this.backend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlueAccent, Colors.blue],
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 50), // Space for where the logo was
                FaIcon(
                  FontAwesomeIcons.water,
                  color: Colors.blue,
                  size: 80, // Adjust size as needed
                ),
                SizedBox(height: 10), // Add some space between the icon and the text
                Text(
                  'RiverWatch',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'or',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.facebook),
                      color: Colors.blue,
                      iconSize: 30,
                      onPressed: () {
                        // Handle Facebook login
                      },
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.google),
                      color: Colors.red,
                      iconSize: 30,
                      onPressed: () {
                        // Handle Google login
                      },
                    ),
                  ],
                ),
                SizedBox(height: 50), // Space to balance the layout
              ],
            ),
          ),
        ),
      ),
    );
  }
}
