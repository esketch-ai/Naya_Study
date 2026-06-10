import 'dart:convert';
import 'package:http/http.dart' as http;

class Gpt4oStructuredOutput {
  static const String SCHEMA = '''
  {
    "buddy_reply_english": "string - Character's affectionate English response",
    "buddy_reply_korean": "string - Korean chat feedback in same tone", 
    "has_grammatical_error": "boolean - Did user make grammar mistakes?",
    "grammar_correction_tip": "string|null - Gentle correction if error exists"
  }
  ''';
  
  Future<Map<String, dynamic>> generateWeekendFreeTalk(String userMessage) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': '''
            You are Buddy, a friendly AI learning companion. 
            Respond in the specified JSON format with affectionate English and Korean feedback.
            
            If the user makes grammatical errors, gently correct them.
            ''',
          },
          {
            'role': 'user',
            'content': userMessage,
          },
        ],
        'response_format': {'type': 'json_schema'},
        'tools': [
          {
            'type': 'function',
            'function': {
              'name': 'buddy_reply',
              'description': 'Generate Buddy\'s response in the specified format',
              'parameters': {
                'type': 'object',
                'properties': SCHEMA,
                'required': ['buddy_reply_english', 'buddy_reply_korean'],
              },
            },
          },
        ],
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      return {
        'buddy_reply_english': data['choices'][0]['message']['content'],
        'buddy_reply_korean': '', // Extract Korean from content
        'has_grammatical_error': false,
        'grammar_correction_tip': null,
      };
    } else {
      throw Exception('GPT-4o API error: ${response.statusCode}');
    }
  }
}
