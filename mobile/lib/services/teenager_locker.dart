import 'dart:async';
import 'package:geolocator/geolocator.dart';

class TeenagerLocker {
  static const double GEOFENCE_RADIUS_M = 50;
  static const int LOCK_DURATION_SECONDS = 30;
  
  bool _isLocked = false;
  Timer? _lockTimer;
  
  Future<void> init() async {
    // Setup geofence for study location
    final geolocator = Geolocator();
    
    await geolocator.createGeofences(
      [
        Geofence(
          id: 'study_location',
          latitude: 37.7749, // Study location lat
          longitude: -122.4194, // Study location lon
          radius: GEOFENCE_RADIUS_M,
        ),
      ],
    );
    
    geolocator.geofenceMonitor.listen((event) {
      if (event.type == GeofenceTransition.ENTERED && event.gefence.id == 'study_location') {
        print('Entered study location - Teenager Locker activated');
        
        _activateLocker();
      } else if (event.type == GeofenceTransition.EXITED) {
        if (_isLocked) {
          print('Left study location - Teenager Locker deactivated');
          _deactivateLocker();
        }
      }
    });
  }
  
  void _activateLocker() {
    // Disable close button for 30 seconds
    _isLocked = true;
    
    _lockTimer = Timer(Duration(seconds: LOCK_DURATION_SECONDS), () {
      _isLocked = false;
      print('Teenager Locker deactivated');
    });
  }
  
  void _deactivateLocker() {
    if (_lockTimer != null) {
      _lockTimer!.cancel();
      _lockTimer = null;
    }
  }
  
  bool get isLocked => _isLocked;
}
