import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String title;
  final String iconAsset;
  final IconData? iconData;
  final Color backgroundColor;

  const ServiceCategory({
    required this.id,
    required this.title,
    this.iconAsset = '',
    this.iconData,
    this.backgroundColor = Colors.white,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'].toString(),
      title: json['name'] as String? ?? 'Service',
      iconData: _iconForKey(json['icon'] as String?),
    );
  }

  static const List<ServiceCategory> defaultCategories = [
    ServiceCategory(
      id: 'plumber',
      title: 'Plumber',
      iconData: Icons.plumbing_rounded,
    ),
    ServiceCategory(
      id: 'electrician',
      title: 'Electrician',
      iconData: Icons.flash_on_rounded,
    ),
    ServiceCategory(
      id: 'tvdish',
      title: 'Tv/Dish',
      iconData: Icons.tv_rounded,
    ),
    ServiceCategory(
      id: 'cleaning',
      title: 'Cleaning',
      iconData: Icons.cleaning_services_rounded,
    ),
    ServiceCategory(
      id: 'painting',
      title: 'Painting',
      iconData: Icons.format_paint_rounded,
    ),
    ServiceCategory(
      id: 'mechanic',
      title: 'Mechanic',
      iconData: Icons.build_rounded,
    ),
    ServiceCategory(
      id: 'carpenter',
      title: 'Carpenter',
      iconData: Icons.handyman_rounded,
    ),
    ServiceCategory(
      id: 'tutor',
      title: 'Tutor',
      iconData: Icons.school_rounded,
    ),
    ServiceCategory(
      id: 'beauty',
      title: 'Beauty Services',
      iconData: Icons.content_cut_rounded,
    ),
    ServiceCategory(
      id: 'transport',
      title: 'Moving / Transport',
      iconData: Icons.local_shipping_rounded,
    ),
  ];

  static IconData _iconForKey(String? key) {
    switch (key) {
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrician':
        return Icons.flash_on_rounded;
      case 'tv':
        return Icons.tv_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'painting':
        return Icons.format_paint_rounded;
      case 'mechanic':
        return Icons.build_rounded;
      case 'carpenter':
        return Icons.handyman_rounded;
      case 'tutor':
        return Icons.school_rounded;
      case 'beauty':
        return Icons.content_cut_rounded;
      case 'transport':
        return Icons.local_shipping_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }
}
