/*import '../data/database_helper.dart';*/

enum AuthState { loggedIn, loggedOut }

abstract class AuthStateListener {
  void onAuthStateChanged(AuthState authState);
}

//a naive implementation of observer and subscriber pattern. will do for now
class AuthStateProvider {
  static final AuthStateProvider _instance = AuthStateProvider.internal();

  List<AuthStateListener> _subscriber = [];

  factory AuthStateProvider() => _instance;
  AuthStateProvider.internal() {
    _subscriber = <AuthStateListener>[];
    // initState();
  }

  void subscribe(AuthStateListener listener) {
    _subscriber.add(listener);
  }

  void dispose(AuthStateListener listener) {
    for (var l in _subscriber) {
      if (l == _subscriber) {
        _subscriber.remove(l);
      }
    }
  }

  void notify(AuthState state) {
    for (var s in _subscriber) {
      s.onAuthStateChanged(state);
    }
  }
}
