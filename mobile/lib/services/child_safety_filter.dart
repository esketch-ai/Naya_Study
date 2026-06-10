import 'dart:async';
import 'package:geolocator/geolocator.dart';

class ChildSafetyFilter {
  static const String KIDS_TRACKING_LOCATION = 'school_location';
  
  bool _isKidsMode = false;
  VoiceType _currentVoiceType = VoiceType.elevenLabs; // Default
  
  enum VoiceType {
    elevenLabs,
    childActor,
  }
  
  Future<void> init() async {
    await Geolocator.requestPermission();
    
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        distanceFilter: 10, // Update every 10m
      ),
    ).listen((position) async {
      final coords = position.coords as Coordinates;
      
      // Check if near school/study location
      final isNearSchool = await _isNearLocation(KIDS_TRACKING_LOCATION);
      
      if (isNearSchool && !_isKidsMode) {
        print('Child safety filter activated');
        
        _activateKidsMode();
      } else if (!isNearSchool && _isKidsMode) {
        print('Child safety filter deactivated');
        
        _deactivateKidsMode();
      }
    });
  }
  
  Future<bool> _isNearLocation(String locationId) async {
    // Check if user is within predefined radius of school/study location
    return false;
  }
  
  void _activateKidsMode() {
    print('Switching to child voice actor instead of ElevenLabs AI');
    
    _currentVoiceType = VoiceType.childActor;
    _isKidsMode = true;
  }
  
  void _deactivateKidsMode() {
    if (_isKidsMode) {
      print('Returning to normal voice (ElevenLabs)');
      
      _currentVoiceType = VoiceType.elevenLabs;
      _isKidsMode = false;
    }
  }
  
  VoiceType get currentVoiceType => _currentVoiceType;
}
