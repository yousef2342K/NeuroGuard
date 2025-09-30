import 'dart:async';
import '../state/app_state.dart';
import 'notification_mock.dart';
import 'sms_call_mock.dart';

class EscalationMock {
  static final Map<String, Timer> _timers = {};

  static void schedule(Map<String, dynamic> event, {int timeoutSeconds = 60}) {
    final id = event['id'] as String? ?? '';
    _timers[id]?.cancel();
    _timers[id] = Timer(Duration(seconds: timeoutSeconds), () async {
      final stillActive = AppState.instance.events.value
          .any((e) => e['id'] == id && e['status'] == 'active');
      if (stillActive) {
        NotificationMock.show('Escalation',
            'No acknowledgement — sending SMS/Call (simulated) to caregiver');
        await SmsCallMock.sendSms('+201000000000',
            'NeuroGuard Alert: possible seizure for Sara at ${DateTime.now()}');
        await SmsCallMock.call('+201000000000');
      }
    });
  }

  static void cancel(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }
}
