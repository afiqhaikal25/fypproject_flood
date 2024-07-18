import 'package:flutter/material.dart';
import 'monitor.dart';
import 'profile.dart'; // Import your Profile page here

class RegisterPPS extends StatefulWidget {
  @override
  _RegisterPPSState createState() => _RegisterPPSState();
}

class _RegisterPPSState extends State<RegisterPPS> {
  final _formKey = GlobalKey<FormState>();
  String district = 'Select District';
  String selectedCenter = '';
  int _selectedIndex = 1;

  List<String> districts = [
    'Select District',
    'Besut',
    'Dungun',
    'Hulu Terengganu',
    'Kemaman',
    'Kuala Nerus',
    'Kuala Terengganu',
    'Marang',
    'Setiu',
  ];

  Map<String, List<Map<String, String>>> evacuationCenters = {
    'Besut': [
      {'name': 'Dewan Serbaguna Besut', 'status': 'Available'},
      {'name': 'Dewan Orang Ramai Kampung Raja', 'status': 'Full'},
      {'name': 'Dewan Sekolah Kebangsaan Besut', 'status': 'Available'},
    ],
    'Dungun': [
      {'name': 'Dewan Serbaguna Dungun', 'status': 'Available'},
      {'name': 'Dewan Orang Ramai Paka', 'status': 'Full'},
      {'name': 'Dewan Sekolah Menengah Kebangsaan Dungun', 'status': 'Available'},
    ],
    'Hulu Terengganu': [
      {'name': 'Dewan Serbaguna Kuala Berang', 'status': 'Available'},
      {'name': 'Dewan Orang Ramai Ajil', 'status': 'Full'},
      {'name': 'Dewan Sekolah Kebangsaan Kuala Berang', 'status': 'Available'},
    ],
    'Kemaman': [
      {'name': 'Dewan Seri Amar', 'status': 'Available'},
      {'name': 'Dewan Orang Ramai Kemasik', 'status': 'Full'},
      {'name': 'Dewan Sekolah Menengah Kebangsaan Kemaman', 'status': 'Available'},
    ],
    'Kuala Nerus': [
      {'name': 'Dewan Serbaguna Seberang Takir', 'status': 'Available'},
      {'name': 'Dewan Orang Ramai Batu Rakit', 'status': 'Full'},
      {'name': 'Dewan Sekolah Kebangsaan Kuala Nerus', 'status': 'Available'},
    ],
    'Kuala Terengganu': [
      {'name': 'Dewan Seri Negeri', 'status': 'Available'},
      {'name': 'Dewan Orang Ramai Chabang Tiga', 'status': 'Full'},
      {'name': 'Dewan Sekolah Menengah Kebangsaan Kuala Terengganu', 'status': 'Available'},
    ],
    'Marang': [
      {'name': 'Dewan Serbaguna Marang', 'status': 'Available'},
      {'name': 'Dewan Orang Ramai Rusila', 'status': 'Full'},
      {'name': 'Dewan Sekolah Kebangsaan Marang', 'status': 'Available'},
    ],
    'Setiu': [
      {'name': 'Dewan Serbaguna Permaisuri', 'status': 'Available'},
      {'name': 'Dewan Orang Ramai Guntong', 'status': 'Full'},
      {'name': 'Dewan Sekolah Kebangsaan Setiu', 'status': 'Available'},
    ],
  };

  void register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Process the registration data here. For now, we just display a snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful')),
      );
      // Add the actual registration logic here.
      // For example, sending the data to a server or saving it locally.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MonitorPage()),
        );
        break;
      case 1:
        // Already on this page, no action needed.
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Evacuation Center'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
                value: district,
                items: districts.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    district = newValue!;
                    selectedCenter = ''; // Reset selected center when district changes
                  });
                },
                validator: (value) {
                  if (value == 'Select District') {
                    return 'Please select a district';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Evacuation Centers:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (district != 'Select District')
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: evacuationCenters[district]!.length,
                  itemBuilder: (context, index) {
                    final center = evacuationCenters[district]![index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: CheckboxListTile(
                        title: Text(center['name']!),
                        subtitle: Text(
                          center['status']!,
                          style: TextStyle(
                            color: center['status'] == 'Available' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: selectedCenter == center['name']!,
                        onChanged: center['status'] == 'Available'
                            ? (bool? value) {
                                setState(() {
                                  selectedCenter = value! ? center['name']! : '';
                                });
                              }
                            : null,
                      ),
                    );
                  },
                ),
              if (selectedCenter.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Register for $selectedCenter:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Number of Family Members'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter number of family members';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
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
}
