import 'package:analyzer_plugin/protocol/protocol.dart';

class PrintParams {
  PrintParams(this.message);

  factory PrintParams.fromNotification(Notification notification) {
    assert(
      notification.event == key,
      'Notification is not a print notification',
    );

    return PrintParams(notification.params!['message']! as String);
  }

  static const key = 'custom_lint.print';

  final String message;

  Notification toNotification() {
    return Notification(key, {'message': message});
  }
}
