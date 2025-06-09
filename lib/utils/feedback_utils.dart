import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension FeedbackUtils on Widget {
  Widget withTapFeedback({required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: this,
    );
  }
}