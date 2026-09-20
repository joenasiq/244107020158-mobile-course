import 'package:flutter/material.dart';
import '../data/models/post.dart';

/// Widget PostTile terpisah untuk merender baris item Post
/// Mempersingkat kode pada ListView.builder dan mempermudah unit/widget testing
class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostTile({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(post.id.toString()),
      ),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: post.body.isNotEmpty
          ? Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
    );
  }
}
