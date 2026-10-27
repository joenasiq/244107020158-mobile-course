/// Parsing data payload dari RemoteMessage → rute deep link
/// (Refactoring Challenge #2).
///
/// Fungsi murni (pure function) tanpa ketergantungan pada Firebase,
/// sehingga bisa di-unit-test tanpa emulator / plugin asli.
String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] as String?) ?? '/';
  return route.startsWith('/') ? route : '/$route';
}
