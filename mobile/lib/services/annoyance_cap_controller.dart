import 'dart:async';

class AnnoyanceCapController {
  static const int MAX_MUTE_COUNT = 2;
  static const int MUTE_DURATION_HOURS = 4;
  
  int _muteCount = 0;
  Timer? _muteTimer;
  
  void onUserMutesOrClosesPopup() {
    _muteCount++;
    
    if (_muteCount >= MAX_MUTE_COUNT) {
      // Disable all notifications for 4 hours
      print('Annoyance cap triggered - muting for $MUTE_DURATION_HOURS hours');
      
      _muteTimer = Timer(
        Duration(hours: MUTE_DURATION_HOURS),
        () {
          _muteCount = 0;
          print('Annoyance cap lifted');
        },
      );
    }
  }
  
  void liftCap() {
    if (_muteTimer != null) {
      _muteTimer!.cancel();
      _muteTimer = null;
      _muteCount = 0;
    }
  }
}
