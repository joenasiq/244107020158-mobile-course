/// Konstanta rute aplikasi (Refactoring Challenge #1).
///
/// Satu sumber kebenaran untuk path yang dipakai GoRouter maupun
/// deep link dari notifikasi FCM — tidak ada string rute tersebar.
class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const home = '/';
  static const announcement = '/pengumuman/:id';

  /// Bangun path detail pengumuman dari [id].
  static String announcementById(String id) => '/pengumuman/$id';
}
