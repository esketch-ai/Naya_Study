import 'dart:async';

class LowPowerHybridSampling {
  static const int STILL_DURATION_MS = 600000; // 10 minutes
  static const int PPG_SAMPLE_DURATION_MS = 30000; // 30 seconds
  
  bool _isLowPowerMode = false;
  
  void onStillDetected() {
    print('Device still detected - entering low power mode');
    
    _activateLowPowerMode();
  }
  
  void onMotionDetected() {
    if (_isLowPowerMode) {
      print('Motion detected - exiting low power mode');
      
      _deactivateLowPowerMode();
    }
  }
  
  void _activateLowPowerMode() {
    // Wake PPG sensor for 30 seconds only, then deep sleep
    
    Timer(Duration(seconds: 5), () {
      print('PPG sampling in progress...');
      
      Timer(const Duration(seconds: 25), () {
        print('PPG sampling complete - returning to deep sleep');
        
        _isLowPowerMode = false;
      });
    });
    
    _isLowPowerMode = true;
  }
  
  void _deactivateLowPowerMode() {
    if (_isLowPowerMode) {
      print('Exiting low power mode - full sensor suite active');
      
      _isLowPowerMode = false;
    }
  }
}
