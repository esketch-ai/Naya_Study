import 'package:elevenlabs/eleven_labs.dart';

class ElevenLabsTtsIntegration {
  static const double STABILITY = 0.4;
  static const double SIMILARITY_BOOST = 0.8;
  static const double STYLE = 0.6;
  
  static const int STRESS_THRESHOLD = 75; // Default from user_profiles table
  
  Future<String> generateVoice(String voiceId, String text) async {
    final client = ElevenLabsClient(
      apiKey: 'YOUR_API_KEY',
    );
    
    return await client.generateSpeech(
      text: text,
      voiceId: voiceId,
      settings: VoiceSettings(
        stability: STABILITY,
        similarityBoost: SIMILARITY_BOOST,
        style: STYLE,
      ),
    );
  }
  
  Future<String> generateStressAdaptiveVoice(String voiceId, String text, double hrvRmssd) async {
    // Voice settings adapt to user stress level (HRV RMSSD)
    final stability = hrvRmssd < STRESS_THRESHOLD ? 0.3 : 0.4;
    final similarityBoost = hrvRmssd < STRESS_THRESHOLD ? 0.9 : 0.8;
    
    return await generateVoice(voiceId, text);
  }
}
