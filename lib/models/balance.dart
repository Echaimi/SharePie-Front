import 'package:spaceshare/models/user.dart';

class Balance {
  final int id;
  final double amount;
  final User user;
  final int eventId;

  Balance(
      {required this.id,
      required this.amount,
      required this.user,
      required this.eventId});

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      id: json['id'],
      amount: json['amount'].toDouble(),
      user: User.fromJson(json['user']),
      eventId: json['eventId'],
    );
  }
}
