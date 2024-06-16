import 'dart:async';

class EventEmitter {
  final StreamController<String> _controller = StreamController<String>.broadcast();

  Stream<String> get onEvent => _controller.stream;

  void emitEvent(String eventData) {
    _controller.add(eventData);
  }

  void close() {
    _controller.close();
  }
}