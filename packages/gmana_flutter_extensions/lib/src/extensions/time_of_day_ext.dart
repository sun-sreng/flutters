// TimeOfDay extension getters.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

extension TimeOfDayExtensions on TimeOfDay {
  String toCustomString() {
    final periodText = period == DayPeriod.am ? 'AM' : 'PM';
    final hourText = hourOfPeriod.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');

    return '$hourText:$minuteText $periodText';
  }
}