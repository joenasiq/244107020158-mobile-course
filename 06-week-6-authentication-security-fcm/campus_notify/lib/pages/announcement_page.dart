import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes.dart';

/// Halaman detail pengumuman (/pengumuman/:id).
///
/// Dapat dibuka melalui klik notifikasi FCM (foreground, background,
/// maupun terminated) atau navigasi biasa dari daftar pengumuman.
class AnnouncementPage extends StatelessWidget {
  final String id;

  const AnnouncementPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengumuman #$id'),
        // Tombol kembali: pop bila ada riwayat, atau ke home bila
        // dibuka langsung dari notifikasi (deep link / terminated).
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '#$id',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengumuman Akademik',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'ID: $id',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Detail Pengumuman #$id',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Halaman ini adalah rute deep link /pengumuman/$id yang '
                  'dapat dibuka melalui notifikasi FCM pada ketiga app '
                  'state: foreground, background, maupun terminated.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
