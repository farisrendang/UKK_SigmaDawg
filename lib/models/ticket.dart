class Ticket {
  final String date;
  final String departTime;
  final String arriveTime;
  final String fromCity;
  final String fromCode;
  final String toCity;
  final String toCode;
  final String operatorName;
  final int passengers;
  final bool isPast;

  Ticket({
    required this.date,
    required this.departTime,
    required this.arriveTime,
    required this.fromCity,
    required this.fromCode,
    required this.toCity,
    required this.toCode,
    required this.operatorName,
    required this.passengers,
    this.isPast = false,
  });
}