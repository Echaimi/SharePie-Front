// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/models/user.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import '../models/refund.dart';
import '../models/payer.dart';
import 'Refund_payer.dart';
import 'bottom_modal.dart';
import 'refund_participants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class RefundForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final Refund? initialRefund;
  final bool isUpdate;

  const RefundForm({
    super.key,
    required this.onSubmit,
    this.initialRefund,
    this.isUpdate = false,
  });

  @override
  _RefundFormState createState() => _RefundFormState();
}

class _RefundFormState extends State<RefundForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  User? _fromUser;
  User? _toUser;

  String? _amountError;
  String? _fromUserError;
  String? _toUserError;
  String? _dateError;

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (widget.initialRefund != null) {
      _amountController.text = widget.initialRefund!.amount.toString();
      _dateController.text =
          DateFormat('dd/MM/yyyy').format(widget.initialRefund!.date);
      _fromUser = widget.initialRefund!.from;
      _toUser = widget.initialRefund!.to;
      _fromController.text = _fromUser?.username ?? '';
      _toController.text = _toUser?.username ?? '';
    } else {
      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      if (currentUser != null) {
        _fromUser = currentUser;
        _fromController.text = currentUser.username;
      }
    }
  }

  void _handleSubmit() {
    setState(() {
      _amountError =
          _amountController.text.isEmpty ? t(context)!.amountRequired : null;
      _fromUserError = _fromUser == null ? t(context)!.fromUserRequired : null;
      _toUserError = _toUser == null ? t(context)!.toUserRequired : null;
      _dateError =
          _dateController.text.isEmpty ? t(context)!.dateRequired : null;
    });

    if (_amountError == null &&
        _fromUserError == null &&
        _toUserError == null &&
        _dateError == null) {
      final data = {
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'fromUserId': _fromUser?.id,
        'toUserId': _toUser?.id,
        'date':
            '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateFormat('dd/MM/yyyy').parse(_dateController.text))}Z',
      };

      if (widget.isUpdate && widget.initialRefund != null) {
        data['id'] = widget.initialRefund!.id;
      }

      widget.onSubmit(data);
      context.pop(context);
    }
  }

  void _openUserSelectionModal(bool isFromUser) async {
    final eventWebsocketProvider =
        Provider.of<EventWebsocketProvider>(context, listen: false);

    if (isFromUser) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return BottomModal(
            scrollController: ScrollController(),
            child: RefundPayers(
              users: eventWebsocketProvider.users
                  .map((user) => UserWithExpenses(
                        id: user.id,
                        email: user.email,
                        username: user.username,
                        role: user.role,
                        avatar: user.avatar,
                        expenseCount: 0,
                        totalExpenses: 0.0,
                        refundAmount: 0.0,
                      ))
                  .toList(),
              currentUser:
                  Provider.of<AuthProvider>(context, listen: false).user,
              totalAmount: double.tryParse(_amountController.text) ?? 0.0,
              onPayersSelected: (selectedUsers) {
                if (selectedUsers.isNotEmpty) {
                  final selectedUser = selectedUsers.first;
                  setState(() {
                    _fromUser = selectedUser.user;
                    _fromController.text = selectedUser.user.username;
                  });
                }
              },
              initialPayers: _fromUser != null
                  ? [
                      Payer(
                        id: _fromUser!.id,
                        user: UserWithExpenses(
                          id: _fromUser!.id,
                          email: _fromUser!.email,
                          username: _fromUser!.username,
                          role: _fromUser!.role,
                          avatar: _fromUser!.avatar,
                          expenseCount: 0,
                          totalExpenses: 0.0,
                          refundAmount: 0.0,
                        ),
                        amount: double.tryParse(_amountController.text) ?? 0.0,
                      )
                    ]
                  : [],
            ),
          );
        },
      );
    } else {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return BottomModal(
            scrollController: ScrollController(),
            child: RefundParticipants(
              users: eventWebsocketProvider.users,
              totalAmount: double.tryParse(_amountController.text) ?? 0.0,
              onUserSelected: (selectedUser) {
                setState(() {
                  _toUser = selectedUser;
                  _toController.text = selectedUser.username;
                });
              },
              selectedUser: _toUser != null
                  ? UserWithExpenses(
                      id: _toUser!.id,
                      email: _toUser!.email,
                      username: _toUser!.username,
                      role: _toUser!.role,
                      avatar: _toUser!.avatar,
                      expenseCount: 0,
                      totalExpenses: 0.0,
                      refundAmount: 0.0,
                    )
                  : null,
            ),
          );
        },
      );
    }
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildLabeledField(t(context)!.amountPlaceholder,
                        _amountController, context,
                        keyboardType: TextInputType.number,
                        errorText: _amountError),
                    const SizedBox(height: 24.0),
                    _buildLabeledField(
                        t(context)!.fromUser, _fromController, context,
                        errorText: _fromUserError,
                        onTap: () => _openUserSelectionModal(true)),
                    const SizedBox(height: 24.0),
                    _buildLabeledField(
                        t(context)!.toUser, _toController, context,
                        errorText: _toUserError,
                        onTap: () => _openUserSelectionModal(false)),
                    const SizedBox(height: 24.0),
                    _buildLabeledField(
                        t(context)!.datePlaceholder, _dateController, context,
                        onTap: () => _selectDate(context),
                        errorText: _dateError),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 302,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    widget.isUpdate
                        ? t(context)!.editRefund
                        : t(context)!.addRefund,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
      String label, TextEditingController controller, BuildContext context,
      {VoidCallback? onTap, TextInputType? keyboardType, String? errorText}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: AbsorbPointer(
              absorbing: onTap != null,
              child: TextField(
                textAlign: TextAlign.center,
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  errorText: errorText,
                ),
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
