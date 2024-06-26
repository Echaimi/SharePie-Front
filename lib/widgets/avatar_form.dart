import 'package:flutter/material.dart';
import 'package:nsm/widgets/profile_avatar.dart';
import '../models/avatar.dart';

class AvatarForm extends StatefulWidget {
  final List<Avatar> avatars;
  final ValueChanged<int?> onAvatarSelected;
  final String currentAvatarUrl;

  const AvatarForm({
    super.key,
    required this.avatars,
    required this.onAvatarSelected,
    required this.currentAvatarUrl,
  });

  @override
  _AvatarFormState createState() => _AvatarFormState();
}

class _AvatarFormState extends State<AvatarForm> {
  int? selectedAvatarId;
  String? selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    selectedAvatarUrl = widget.currentAvatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextTheme textTheme = themeData.textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Mon avatar",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 70,
                backgroundImage:
                    NetworkImage(selectedAvatarUrl ?? widget.currentAvatarUrl),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Choisis ton avatar...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.avatars
                      .sublist(0, (widget.avatars.length + 1) ~/ 2)
                      .map((avatar) {
                    bool isSelected = avatar.id == selectedAvatarId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatarId = avatar.id;
                          selectedAvatarUrl = avatar.url;
                        });
                      },
                      child: ProfileAvatar(
                        imageUrl: avatar.url,
                        isSelected: isSelected,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.avatars
                      .sublist((widget.avatars.length + 1) ~/ 2)
                      .map((avatar) {
                    bool isSelected = avatar.id == selectedAvatarId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatarId = avatar.id;
                          selectedAvatarUrl = avatar.url;
                        });
                      },
                      child: ProfileAvatar(
                        imageUrl: avatar.url,
                        isSelected: isSelected,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              widget.onAvatarSelected(selectedAvatarId);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: colorScheme.secondary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: textTheme.bodyLarge,
            ),
            child: const Text('Choisir cet avatar'),
          ),
        ),
      ],
    );
  }
}
