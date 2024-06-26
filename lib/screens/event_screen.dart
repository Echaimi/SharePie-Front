import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nsm/providers/auth_provider.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:nsm/widgets/AddButton.dart';
import 'package:nsm/widgets/dialog.dart';
import 'package:nsm/widgets/bottom_modal.dart';
import 'package:nsm/widgets/event_balances_tab.dart';
import 'package:nsm/widgets/event_expenses_tab.dart';
import 'package:nsm/widgets/event_invitation_modal.dart';
import 'package:nsm/widgets/event_users_tab.dart';
import 'package:nsm/widgets/expense_modal_content.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nsm/widgets/refound_modal_content.dart';
import 'package:go_router/go_router.dart';

class EventScreen extends StatefulWidget {
  final int eventId;

  const EventScreen({required this.eventId, super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  EventWebsocketProvider? _eventProvider;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    final webSocketService = WebSocketService(
        '${dotenv.env['API_WS_URL']}/ws/events/${widget.eventId}');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Future.delayed(const Duration(seconds: 1));

    _eventProvider = EventWebsocketProvider(
      webSocketService,
      authProvider,
    );
    setState(() {}); // Call to rebuild the widget after initialization
  }

  void _deleteEvent() {
    // TODO: Handle event deletion
  }

  void _archiveEvent() {
    // TODO: Handle event archiving
  }

  void _showAddOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return BottomModal(
                    scrollController: ScrollController(),
                    child: ExpenseModalContent(),
                  );
                },
              );
            },
            child: const Text('Ajouter une dépense'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return BottomModal(
                    scrollController: ScrollController(),
                    child: RefundModalContent(),
                  );
                },
              );
            },
            child: const Text('Ajouter un remboursement'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuler'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_eventProvider == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider<EventWebsocketProvider>(
      create: (context) => _eventProvider!,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  GoRouter.of(context).pop();
                } else {
                  GoRouter.of(context).go('/');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {
                  final eventCode = _eventProvider?.event?.code;

                  if (eventCode != null && eventCode.isNotEmpty) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return EventCodeModal(
                          code: eventCode,
                        );
                      },
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          onPressed: () {
                            _deleteEvent();
                            Navigator.pop(context);
                          },
                          child: const Text('Supprimer l\'évènement'),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            _archiveEvent();
                            Navigator.pop(context);
                          },
                          child: const Text('Archiver l\'évènement'),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Annuler'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Consumer<EventWebsocketProvider>(
            builder: (context, eventProvider, child) {
              final theme = Theme.of(context);

              final event = eventProvider.event;
              final users = eventProvider.users;
              final totalExpenses = eventProvider.totalExpenses;
              final usersCount = users.length;
              final expensesCount = eventProvider.expenses.length;

              if (event == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF373455)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF373455),
                            offset: Offset(
                              6.0,
                              6.0,
                            ),
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              '$totalExpenses €',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'au total pour $usersCount personnes',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TabBar(
                      dividerColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                      labelColor: Theme.of(context)
                          .colorScheme
                          .secondary, // Active tab color
                      unselectedLabelColor: Colors.white, // Inactive tab color
                      labelStyle:
                          const TextStyle(fontSize: 12.0), // Smaller text size
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.person),
                          text: 'Pers. ($usersCount)',
                        ),
                        Tab(
                          icon: const Icon(Icons.attach_money),
                          text: 'Dépenses ($expensesCount)',
                        ),
                        const Tab(
                          icon: Icon(Icons.balance),
                          text: 'Équilibre',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Expanded(
                      child: TabBarView(
                        children: [
                          const EventUsersTab(),
                          const EventExpensesTab(),
                          EventBalanceTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.white, width: 1.0)),
            ),
            child: BottomAppBar(
              color: Theme.of(context).colorScheme.background,
              child: SizedBox(
                height: 60.0,
                child: Consumer<EventWebsocketProvider>(
                  builder: (context, eventProvider, child) {
                    final userTotalExpenses = eventProvider.userTotalExpenses;
                    final userAmountOwed = eventProvider.userAmountOwed;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("J'ai dépensé"),
                            Text('$userTotalExpenses €'),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('On me doit'),
                            Text('$userAmountOwed €'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton:
              AddButton(onPressed: () => _showAddOptions(context)),
        ),
      ),
    );
  }
}
