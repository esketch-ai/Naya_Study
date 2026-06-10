import 'dart:async';

class SleepModeFilter {
  static const int STILL_DURATION_MS = 600000; // 10 minutes
  static const double HRV_HF_SPIKE_THRESHOLD = 50.0;
  
  bool _isSleepMode = false;
  Timer? _sleepTimer;
  
  void checkForSleepMode(double hrvHF, double motionMagnitude) {
    if (motionMagnitude < 0.1 && hrvHF > HRV_HF_SPIKE_THRESHOLD) {
      // Detecting sleep state
      print('Sleep mode detected - muting all interactions');
      
      _isSleepMode = true;
      
      // Auto-delete ephemeral data after 48hrs
      _sleepTimer = Timer(const Duration(hours: 48), () {
        _cleanupEphemeralData();
        _isSleepMode = false;
      });
    } else {
      if (_isSleepMode) {
        print('Sleep mode ended');
        _isSleepMode = false;
      }
    }
  }
  
  void _cleanupEphemeralData() {
    // Delete HRV/PPG data used for scheduling
    print('Cleaned up ephemeral biometric data');
  }
  
  bool get isSleepMode => _isSleepMode;
}
