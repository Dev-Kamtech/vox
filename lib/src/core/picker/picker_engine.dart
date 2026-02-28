/// vox core: picker engine — date, time, and option pickers.
library;

import 'package:flutter/material.dart';

import '../nav/router.dart';

// ---------------------------------------------------------------------------
// _context helper
// ---------------------------------------------------------------------------

BuildContext get _ctx {
  assert(
    VoxRouter.key.currentContext != null,
    'vox: picker called before the app is ready. '
    'Make sure voxApp() is running before calling pickDate/pickTime/pickOne.',
  );
  return VoxRouter.key.currentContext!;
}

// ---------------------------------------------------------------------------
// pickDate
// ---------------------------------------------------------------------------

/// Show a material date picker and return the selected [DateTime].
///
/// Returns `null` if the user cancels.
///
/// ```dart
/// final date = await pickDate();
/// final date = await pickDate(initial: DateTime(2024, 6, 1));
/// ```
Future<DateTime?> pickDate({
  DateTime? initial,
  DateTime? first,
  DateTime? last,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: _ctx,
    initialDate: initial ?? now,
    firstDate: first ?? DateTime(1900),
    lastDate: last ?? DateTime(2100),
  );
}

// ---------------------------------------------------------------------------
// pickTime
// ---------------------------------------------------------------------------

/// Show a material time picker and return the selected [TimeOfDay].
///
/// Returns `null` if the user cancels.
///
/// ```dart
/// final time = await pickTime();
/// ```
Future<TimeOfDay?> pickTime({TimeOfDay? initial}) {
  return showTimePicker(
    context: _ctx,
    initialTime: initial ?? TimeOfDay.now(),
  );
}

// ---------------------------------------------------------------------------
// pickOne — single-select bottom sheet
// ---------------------------------------------------------------------------

/// Show a bottom sheet for selecting a single value from [options].
///
/// [label] converts each option to a display string (defaults to `toString`).
///
/// Returns the selected value, or `null` if dismissed.
///
/// ```dart
/// final country = await pickOne(['US', 'UK', 'CA'], label: (c) => c);
/// ```
Future<T?> pickOne<T>(
  List<T> options, {
  String Function(T)? label,
  String title = 'Select',
}) {
  final ctx = _ctx;
  return showModalBottomSheet<T>(
    context: ctx,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (_, i) {
              final option = options[i];
              return ListTile(
                title: Text(label != null ? label(option) : '$option'),
                onTap: () => Navigator.of(ctx).pop(option),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// pickMany — multi-select bottom sheet
// ---------------------------------------------------------------------------

/// Show a bottom sheet for selecting multiple values from [options].
///
/// [label] converts each option to a display string (defaults to `toString`).
/// [initial] pre-selects items.
///
/// Returns the selected list, or `null` if dismissed.
///
/// ```dart
/// final tags = await pickMany(['Dart', 'Flutter', 'Rust'], initial: ['Dart']);
/// ```
Future<List<T>?> pickMany<T>(
  List<T> options, {
  String Function(T)? label,
  List<T>? initial,
  String title = 'Select',
}) {
  final ctx = _ctx;
  return showModalBottomSheet<List<T>>(
    context: ctx,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _PickManySheet<T>(
      options: options,
      label: label,
      initial: initial ?? [],
      title: title,
    ),
  );
}

// ---------------------------------------------------------------------------
// _PickManySheet — internal stateful multi-select widget
// ---------------------------------------------------------------------------

class _PickManySheet<T> extends StatefulWidget {
  final List<T> options;
  final String Function(T)? label;
  final List<T> initial;
  final String title;

  const _PickManySheet({
    required this.options,
    required this.label,
    required this.initial,
    required this.title,
  });

  @override
  State<_PickManySheet<T>> createState() => _PickManySheetState<T>();
}

class _PickManySheetState<T> extends State<_PickManySheet<T>> {
  late final Set<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.of(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_selected.toList()),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.options.length,
            itemBuilder: (_, i) {
              final option = widget.options[i];
              final checked = _selected.contains(option);
              return CheckboxListTile(
                value: checked,
                title: Text(
                    widget.label != null ? widget.label!(option) : '$option'),
                onChanged: (_) => setState(() {
                  if (checked) {
                    _selected.remove(option);
                  } else {
                    _selected.add(option);
                  }
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
