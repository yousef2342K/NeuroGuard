class SmsCallMock {
  static Future<void> sendSms(String phone, String text) async {
    await Future.delayed(const Duration(seconds: 1));
    print('[SMS] to $phone: $text');
  }

  static Future<void> call(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    print('[CALL] to $phone (simulated)');
  }
}
