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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [0.0, 3.0, 4.0, 4.5].map((rating) {
              final isSelected = _minRating == rating;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(rating == 0 ? 'Any' : '$rating★ & up'),
                  selected: isSelected,
                  selectedColor: AppTheme.green,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.ink,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _minRating = rating),
                ),
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

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                ref.read(maxDistanceProvider.notifier).state = _distanceKm;
                ref.read(minRatingProvider.notifier).state = _minRating;
                ref.read(verifiedOnlyProvider.notifier).state = _verifiedOnly;
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
