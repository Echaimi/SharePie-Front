import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spaceshare/models/websocket_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spaceshare/models/balance.dart';
import 'package:spaceshare/models/transaction.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import '../models/event.dart';
import '../models/expense.dart';

class EventWebsocketProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  final AuthProvider _authProvider;
  Event? _event;
  List<UserWithExpenses> _users = [];
  List<Expense> _expenses = [];
  List<Balance> _balances = [];
  List<Transaction> _transactions = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  EventWebsocketProvider(int eventId, this._authProvider) {
    _initialize(eventId);
  }

  Event? get event => _event;
  List<UserWithExpenses> get users => _users;
  List<Expense> get expenses => _expenses;
  List<Balance> get balances => _balances;
  List<Transaction> get transactions => _transactions;
  double get totalExpenses =>
      _expenses.fold(0, (sum, expense) => sum + expense.amount);

  double get userTotalExpenses {
    final userId = _authProvider.user?.id;
    return _expenses
        .where(
            (expense) => expense.payers.any((payer) => payer.user.id == userId))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double? get userAmountOwed {
    final userId = _authProvider.user?.id;

    if (userId == null || _balances.isEmpty) return 0.00;

    return _balances.firstWhere((balance) => balance.user.id == userId).amount;
  }

  Expense? getExpenseById(int id) {
    try {
      return _expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      print('Expense with id $id not found: $e');
      return null;
    }
  }

  Balance? get userBalance {
    final userId = _authProvider.user?.id;
    if (userId == null || _balances.isEmpty) return null;

    return _balances.firstWhere((balance) => balance.user.id == userId);
  }

  Future<void> _initialize(int eventId) async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token not found');
      }
      final wsUrl =
          '${dotenv.env['API_WS_URL']}/ws/events/$eventId?authorization=Bearer $token';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel?.stream.listen(_handleMessage);
    } catch (e) {
      print('Error initializing WebSocket: $e');
    }
  }

  void _handleMessage(message) {
    final data = jsonDecode(message);
    final webSocketMessage = WebSocketMessage.fromJson(data);

    switch (webSocketMessage.type) {
      case 'event':
        final event = Event.fromJson(webSocketMessage.payload);
        _updateEvent(event);
        break;
      case 'expenses':
        final expenses = (webSocketMessage.payload as List)
            .map((e) => Expense.fromJson(e))
            .toList();
        _updateExpenses(expenses);
        break;
      case 'users':
        final users = (webSocketMessage.payload as List)
            .map((u) => UserWithExpenses.fromJson(u))
            .toList();
        _updateUsers(users);
        break;
      case 'balances':
        final balances = (webSocketMessage.payload as List)
            .map((b) => Balance.fromJson(b))
            .toList();
        _balances = balances;
        notifyListeners();
        break;
      case 'transactions':
        final transactions = (webSocketMessage.payload as List)
            .map((t) => Transaction.fromJson(t))
            .toList();
        _transactions = transactions;
        notifyListeners();
        break;
    }
  }

  void _updateEvent(Event event) {
    _event = event;
    print('Event updated: ${event.name}');
    notifyListeners();
  }

  void _updateExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }

  void _updateUsers(List<UserWithExpenses> users) {
    _users = users;
    notifyListeners();
  }

  void createExpense(Map<String, dynamic> data) {
    _sendMessage(WebSocketMessage(type: 'createExpense', payload: data));
    notifyListeners();
  }

  void updateExpense(int expenseId, Map<String, dynamic> data) {
    data["id"] = expenseId;
    _sendMessage(WebSocketMessage(type: 'updateExpense', payload: data));
    notifyListeners();
  }

  void deleteExpense(int expenseId) {
    final data = {'id': expenseId};
    _sendMessage(WebSocketMessage(type: 'deleteExpense', payload: data));
    notifyListeners();
  }

  void updateEvent(Map<String, dynamic> data) {
    _sendMessage(WebSocketMessage(type: 'updateEvent', payload: data));
  }

  void _sendMessage(WebSocketMessage message) {
    try {
      _channel?.sink.add(message.toString());
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
