import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/index_provider.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({required this.child});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  DateTime? _backgroundTime;
  final Duration _backgroundTimeout = const Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
      _performLogout(); // logout when app goes to background
    } else if (state == AppLifecycleState.resumed && _backgroundTime != null) {
      final diff = DateTime.now().difference(_backgroundTime!);
      if (diff >= _backgroundTimeout && ActivityMonitor.count == 0) {
        Provider.of<SessionProvider>(context, listen: false).resetAll();
        Provider.of<IndexProvider>(context, listen: false).setIndex(0);
      }
    } else if (state == AppLifecycleState.detached) {
      _performLogout(); // logout when app is killed/terminated
    }
  }

  Future<void> _performLogout() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final userData = session.userData;
    if (userData == null) return;

    final userToken = userData['user_token'];
    final userId = userData['userId'];
    final profileId = userData['profileId'];
    final sessionId = userData['sessionId'];

    try {
      final response = await ApiService.logout(
        context,
        userToken,
        profileId,
        sessionId,
        userId,
      );

      if (response["status"] == 200) {
        session.resetAll();
        Provider.of<IndexProvider>(context, listen: false).setIndex(0);
        debugPrint("✅ Logout API called successfully on app close.");
      }
    } catch (e) {
      debugPrint("❌ Logout API failed on app close: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ActivityMonitor {
  static int _activeAsyncCount = 0;

  static final _listeners = <VoidCallback>[];

  static int get count => _activeAsyncCount;

  static void start() {
    _activeAsyncCount++;
    _notifyListeners();
  }

  static void setCount(int count) {
    _activeAsyncCount = count;
    _notifyListeners();
  }

  static void end() {
    _activeAsyncCount =
        (_activeAsyncCount - 1).clamp(0, double.infinity).toInt();
    _notifyListeners();
  }

  static bool get isIdle => _activeAsyncCount == 0;

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
    debugPrint("activity status $_activeAsyncCount");
  }
}
