import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/learning_service.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final LearningService _learning = LearningService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: FutureBuilder<List<CardModel>>(
        future: _learning.getZombieCards(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: const Text('No cards available'));
          }
          
          final cards = snapshot.data!;
          
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(card.question),
                  subtitle: Text(card.options[0]),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () => _submitAnswer(context, card, 0),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Future<void> _submitAnswer(BuildContext context, CardModel card, int index) async {
    final result = await _learning.submitQuiz(card.id, index);
    
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correct! EF: ${result.ef}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Try again')),
      );
    }
  }
}
