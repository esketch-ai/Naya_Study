import 'package:flutter/material.dart';
import '../services/learning_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final LearningService _learning = LearningService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _learning.getZombieCards(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text('No cards available'),
                  const SizedBox(height: 8),
                  Text('Connect your wearable device to start learning',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          
          final cards = snapshot.data!;
          
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(Icons.school, color: Colors.emerald),
                  title: Text(card['expression'] ?? 'Loading...'),
                  subtitle: Text(card['meaning'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () => _submitAnswer(context, card),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Future<void> _submitAnswer(BuildContext context, Map<String, dynamic> card) async {
    // Show confirmation dialog before submitting
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(card['expression'] ?? ''),
            const SizedBox(height: 8),
            Text('Meaning: ${card['meaning']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Submit answer (answerIndex = 0 for correct in this demo)
              _learning.submitQuiz(card['id'] ?? '', 0);
              Navigator.pop(context, {'correct': true});
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    
    if (result != null && result['correct'] == true) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Correct! Reviewing...'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh cards after submission
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {});
      });
    }
  }
}

// Card model for type safety (optional)
class CardModel {
  final String id;
  final String expression;
  final String meaning;
  
  CardModel({required this.id, required this.expression, required this.meaning});
  
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? '',
      expression: json['expression'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }
}
