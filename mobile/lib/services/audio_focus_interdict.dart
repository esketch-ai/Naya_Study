import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:net_info/net_info.dart';

class AudioFocusInterdict {
  static final AudioFocusInterdict _instance = AudioFocusInterdict._();
  
  factory AudioFocusInterdict() => _instance;
  
  bool _isPaused = false;
  
  void onAudioFocusChanged(int audioFocus) async {
    if (audioFocus == AudioFocusEvents.AUDIOFOCUS_LOSS_TRANSIENT) {
      // Pause TTS
      _isPaused = true;
      print('TTS paused due to audio focus loss');
    } else if (audioFocus == AudioFocusEvents.AUDIOFOCUS_GAIN) {
      // Resume TTS
      _isPaused = false;
      print('TTS resumed');
    }
  }
  
  bool get isPaused => _isPaused;
}
