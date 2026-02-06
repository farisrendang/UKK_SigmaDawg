import 'package:flutter/material.dart';
import 'package:ukk_percobaan2/models/ticket.dart';
import 'package:ukk_percobaan2/widgets/ticket_card.dart';
import 'ticket_detail_view.dart';

class TicketHistoryView extends StatelessWidget {
  const TicketHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Ticket> tickets = [
       Ticket(date: "10 Oct, 2025", departTime: "08:00 am", arriveTime: "09:00 pm", fromCity: "New York", fromCode: "NYC", toCity: "Dubai", toCode: "DXB", operatorName: "MetroLine", passengers: 2),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Ticket History"),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}), // Dummy Filter
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => TicketDetailView(ticket: tickets[index]))),
            child: TicketCard(ticket: tickets[index]),
          );
        },
      ),
    );
  }
}