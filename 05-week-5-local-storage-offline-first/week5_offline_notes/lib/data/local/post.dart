/// Model ringkas Post dari endpoint JSONPlaceholder `GET /posts`.
///
/// Dipakai strategi cache-first: payload disimpan di tabel `cached_posts`
/// agar data tetap bisa dibaca saat aplikasi offline.
class Post {
  const Post({
    required this.id,
    required this.title,
    this.body = '',
  });

  final int id;
  final String title;
  final String body;

  /// Null-safe: field yang hilang bernilai fallback aman (0 / '').
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
      };
}
