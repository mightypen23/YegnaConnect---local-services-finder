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
    final icon = json['icon'] as String?;
    final iconMap = <String, IconData>{
      'plumbing': Icons.plumbing_rounded, 'flash_on': Icons.flash_on_rounded,
      'tv': Icons.tv_rounded, 'cleaning_services': Icons.cleaning_services_rounded,
      'format_paint': Icons.format_paint_rounded, 'build': Icons.build_rounded,
      'handyman': Icons.handyman_rounded, 'school': Icons.school_rounded,
      'content_cut': Icons.content_cut_rounded, 'local_shipping': Icons.local_shipping_rounded,
    };
    return ServiceCategory(id: json['id'].toString(), title: json['name'] as String? ?? 'Service', iconData: iconMap[icon]);
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
}
