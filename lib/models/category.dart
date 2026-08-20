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
