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
                  title: Text(card['expression'] ?? ''),
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
    // TODO: Implement answer submission with SM-2 algorithm
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reviewing...')),
    );
  }
}
