import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late double _distanceKm;
  late double _minRating;
  late bool _verifiedOnly;

  @override
  void initState() {
    super.initState();
    _distanceKm = ref.read(maxDistanceProvider);
    _minRating = ref.read(minRatingProvider);
    _verifiedOnly = ref.read(verifiedOnlyProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Keyboard-aware padding: when the keyboard is open the sheet must
    // shrink with it, otherwise the content overflows (red error strip).
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      // Bottom clearance keeps every control fully above the floating
      // bottom navigation bar instead of being covered by it.
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: keyboardInset + 100,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Scrollable content guarantees no bottom-overflow errors on small
      // screens or while the keyboard is visible.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Apply Filters Button at the TOP - visible above navigation bar
          FilledButton(
            onPressed: () {
              ref.read(maxDistanceProvider.notifier).state = _distanceKm;
              ref.read(minRatingProvider.notifier).state = _minRating;
              ref.read(verifiedOnlyProvider.notifier).state = _verifiedOnly;
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
          const SizedBox(height: 24),

          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Providers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.ink,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          // Maximum Distance Slider
          Text(
            'Distance: ${_distanceKm.toInt()} km',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink),
          ),
          Slider(
            value: _distanceKm,
            min: 1,
            max: 50,
            activeColor: AppTheme.green,
            onChanged: (val) => setState(() => _distanceKm = val),
          ),

          const SizedBox(height: 14),
          // Minimum Rating
          const Text(
            'Minimum Rating',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink),
          ),
          const SizedBox(height: 8),
          // Wrap instead of Row: extra chips flow to the next line
          // instead of causing a "RIGHT OVERFLOWED" error.
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [0.0, 3.0, 4.0, 4.5].map((rating) {
              final isSelected = _minRating == rating;
              return ChoiceChip(
                label: Text(rating == 0 ? 'Any' : '$rating★ & up'),
                selected: isSelected,
                selectedColor: AppTheme.green,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.ink,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => setState(() => _minRating = rating),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          // Verified Only Switch
          SwitchListTile(
            title: const Text('Verified Providers Only', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Only show providers verified by admin'),
            value: _verifiedOnly,
            activeThumbColor: AppTheme.green,
            onChanged: (val) => setState(() => _verifiedOnly = val),
          ),
        ],
        ),
      ),
    );
  }
}