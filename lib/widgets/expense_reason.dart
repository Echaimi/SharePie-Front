// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/tag.dart';
import '../services/tags_service.dart';
import 'package:spaceshare/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class ReasonExpense extends StatefulWidget {
  final Function(String, String, Tag?, bool) onReasonSelected;
  final String initialReason;
  final String initialDescription;
  final Tag? initialTag;

  const ReasonExpense({
    super.key,
    required this.onReasonSelected,
    required this.initialReason,
    required this.initialDescription,
    required this.initialTag,
  });

  @override
  _ReasonExpenseState createState() => _ReasonExpenseState();
}

class _ReasonExpenseState extends State<ReasonExpense> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TagService _tagService;
  List<Tag> _tags = [];
  Tag? _selectedTag;
  bool _isLoading = true;
  bool _showTagList = false;

  String? _nameError;
  String? _tagError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialReason);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    _selectedTag = widget.initialTag;
    _tagService = TagService(ApiService());
    _showTagList = widget.initialTag != null;
    _fetchTags();
  }

  void _toggleTagSelection(Tag tag) {
    setState(() {
      _selectedTag = _selectedTag == tag ? null : tag;
    });
  }

  void _toggleTagListVisibility() {
    setState(() {
      _showTagList = !_showTagList;
    });
  }

  void _fetchTags() async {
    try {
      final tags = await _tagService.getAllTags();
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _validateReason() {
    setState(() {
      _nameError =
          nameController.text.isEmpty ? t(context)!.expenseNameRequired : null;
      _tagError = _selectedTag == null ? t(context)!.tagRequired : null;
    });

    if (_nameError == null && _tagError == null) {
      widget.onReasonSelected(nameController.text, descriptionController.text,
          _selectedTag, _showTagList);
      context.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                t(context)!.reason,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              t(context)!.reasonPrompt,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24.0),
            _buildTextField(t(context)!.expenseName, nameController, context,
                errorText: _nameError),
            const SizedBox(height: 16.0),
            _buildDescriptionField(
                t(context)!.description, descriptionController, context),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _toggleTagListVisibility,
              child: Text(
                t(context)!.addTag,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _showTagList
                ? _isLoading
                    ? const CircularProgressIndicator()
                    : _buildTagList()
                : Container(),
            if (_tagError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _tagError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateReason,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  t(context)!.validateReason,
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, BuildContext context,
      {String? errorText}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: theme.textTheme.bodyMedium,
          filled: true,
          fillColor: theme.colorScheme.secondaryContainer,
          errorText: errorText,
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildDescriptionField(
      String label, TextEditingController controller, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        textInputAction: TextInputAction.done,
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 22.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: theme.textTheme.bodyMedium,
          filled: true,
          fillColor: theme.colorScheme.secondaryContainer,
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildTagList() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8.0,
      runSpacing: 12.0,
      children: _tags.map((tag) {
        final isSelected = _selectedTag != null && _selectedTag!.id == tag.id;
        return GestureDetector(
          onTap: () => _toggleTagSelection(tag),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color:
                  isSelected ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(color: theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              tag.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
