import 'dart:async';

/// Wait for [delay] before executing [action]
/// If [call] is call again within the delay, the first call is cancel, and the new call is schedule after [delay]
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}
