import 'package:flutter/material.dart';

class River {
  final String name;

  River(this.name);
}

class RiverListScreen extends StatelessWidget {
  final List<River> rivers = [
    River('Terengganu River'),
    River('Kemaman River'),
    River('Setiu River'),
    River('Besut River'),
    River('Dungun River'),
    River('Marang River'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a River to Monitor'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: rivers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(rivers[index].name),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pop(context, rivers[index].name);
            },
          );
        },
      ),
    );
  }
}

class RiverDetailScreen extends StatelessWidget {
  final River river;

  RiverDetailScreen({required this.river});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitor ${river.name}'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Monitoring data for ${river.name} will be shown here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
