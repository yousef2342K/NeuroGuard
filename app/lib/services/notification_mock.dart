class NotificationMock {
  static void show(String title, String body) {
    print('[NOTIF] $title — $body');
  }
}
