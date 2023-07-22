import 'package:flutter/material.dart';

class CustomWidgetBindingObserver extends WidgetsBindingObserver {
  final Function()? onResume, onPaused, onDetached, onInactive;

  CustomWidgetBindingObserver({
    this.onResume,
    this.onPaused,
    this.onDetached,
    this.onInactive,
  });
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (onResume != null) {
        onResume!();
      }
    }
    if (state == AppLifecycleState.paused) {
      if (onPaused != null) {
        onPaused!();
      }
    }
    if (state == AppLifecycleState.detached) {
      if (onDetached != null) {
        onDetached!();
      }
    }
    if (state == AppLifecycleState.inactive) {
      if (onInactive != null) {
        onInactive!();
      }
    }
  }
}
