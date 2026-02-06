import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Mengikuti Tema
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateTime(ticket.date, ticket.departTime, "${ticket.fromCity} (${ticket.fromCode})"),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ticket.isPast ? Colors.grey.withOpacity(0.2) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.train, color: ticket.isPast ? Colors.grey : Colors.red, size: 20),
              ),
              _buildDateTime(ticket.date, ticket.arriveTime, "${ticket.toCity} (${ticket.toCode})", isEnd: true),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: ticket.isPast ? Colors.grey : const Color(0xFFC2185B),
                    child: const Icon(Icons.adjust, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket.operatorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text("Railroads", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Passengers", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("${ticket.passengers} persons", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTime(String date, String time, String location, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}