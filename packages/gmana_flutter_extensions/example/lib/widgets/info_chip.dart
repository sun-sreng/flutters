// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;

  final String label;
  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label), visualDensity: VisualDensity.compact);
  }
}
