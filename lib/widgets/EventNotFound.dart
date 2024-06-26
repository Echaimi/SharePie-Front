import 'package:flutter/material.dart';

class EventNotFound extends StatelessWidget {
  const EventNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final containerColor = colorScheme.primaryContainer;
    final shadowColor = colorScheme.secondaryContainer;

    return Container(
      width: 342,
      height: 152,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(9.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(8, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/noEventFound.png',
                width: 64,
                height: 64,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Créer ou rejoint un évènement',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Profite de nos différents outils pour gérer les dépenses de ton groupe de pote !',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
