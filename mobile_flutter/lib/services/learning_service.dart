import 'dart:convert';
import 'package:http/http.dart' as http;

class LearningService {
  final String _baseUrl = 'https://api.naya.app/api/v1';
  
  // Fetch zombie cards for review (3 daily cards)
  Future<List<Map<String, dynamic>>> getZombieCards() async {
    try {
      print('Fetching zombie cards from API...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/learning/zombie-card'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Convert to list format for UI display
        return List<Map<String, dynamic>>.from(data.map((e) => e));
      } else {
        print('Failed to fetch zombie cards: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching zombie cards: $e');
    }
    
    return [];
  }
  
  // Submit quiz answer with SM-2 algorithm
  Future<Map<String, dynamic>> submitQuiz(String cardId, int answerIndex) async {
    try {
      print('Submitting quiz answer for card: $cardId');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/learning/quiz/submit'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cardId': cardId,
          'answerIndex': answerIndex,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Show feedback to user
        print('Quiz result: ${data['message']}');
        
        return data;
      } else {
        print('Failed to submit quiz: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting quiz: $e');
    }
    
    return {'success': false, 'message': 'Submission failed'};
  }
  
  // Fetch user profile settings
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    
    return {};
  }
  
  // Update user profile settings
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
    
    return {'success': false};
  }
}

// SM-2 Algorithm Implementation for Quiz Results
class Sm2Algorithm {
  static double calculateEF(double quality, double currentEf) {
    // EF = EF + (0.1 - (5 - quality) * (0.8 + (5 - quality) * 0.2))
    final efChange = 0.1 - (5 - quality) * (0.8 + (5 - quality) * 0.2);
    return currentEf + efChange;
  }
  
  static int calculateInterval(int reps, double ef) {
    if (reps == 0) return 1;
    if (reps == 1) return 6;
    return (int)(reps * ef).round();
  }
}
