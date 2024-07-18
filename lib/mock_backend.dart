class User {
  final String email;
  final String password;

  User({required this.email, required this.password});
}

class MockBackend {
  List<User> _users = [];

  bool signUp(String email, String password) {
    if (_users.any((user) => user.email == email)) {
      return false; // User already exists
    }
    _users.add(User(email: email, password: password));
    return true; // Sign-up successful
  }

  bool login(String email, String password) {
    return _users.any((user) => user.email == email && user.password == password);
  }

  void updateUser(String email, String fullName, String email2, String password) {}

  getUser(String email) {}
}
