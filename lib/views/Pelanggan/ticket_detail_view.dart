import 'package:flutter/material.dart';
import 'package:ukk_percobaan2/models/ticket.dart';
import 'package:ukk_percobaan2/widgets/ticket_card.dart';

class TicketDetailView extends StatelessWidget {
  final Ticket ticket;
  const TicketDetailView({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ticket Details")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TicketCard(ticket: ticket),
            const SizedBox(height: 24),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PDF Downloaded")),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text("Print Invoice"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
