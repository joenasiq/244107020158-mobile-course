import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';

/// Halaman utama setelah login.
///
/// Menampilkan status autentikasi, token FCM (terpotong, prinsip keamanan),
/// dan daftar pengumuman kampus sebagai contoh deep link dari notifikasi.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status autentikasi.
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status: Berhasil Masuk',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sesi tersimpan aman di flutter_secure_storage. '
                    'Token tidak pernah di SharedPreferences.',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info keamanan.
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notifikasi push aktif • Topik: pengumuman-kampus',
                      style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Daftar pengumuman.
          Text(
            'Daftar Pengumuman Kampus',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _AnnouncementTile(
            id: '3',
            title: 'Jadwal kuliah berubah',
            subtitle: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
          ),
          _AnnouncementTile(
            id: '4',
            title: 'Pendaftaran Ujian Susulan',
            subtitle: 'Batas akhir pendaftaran Jumat, 17.00 WIB',
          ),
          _AnnouncementTile(
            id: '5',
            title: 'Workshop AI & Mobile Dev',
            subtitle: 'Sabtu 25 Okt 2026, Lab Komputer Lt. 3',
          ),
        ],
      ),
    );
  }
}

/// Baris pengumuman — klik navigasi ke detail via deep link.
class _AnnouncementTile extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;

  const _AnnouncementTile({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('#$id')),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.announcementById(id)),
      ),
    );
  }
}
