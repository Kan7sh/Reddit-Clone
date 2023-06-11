import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';

import '../../../models/post_model.dart';
import '../widgets/comment_card.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post){
    ref.read(postControllerProvider.notifier).addComment(context: context, text: commentController.text.trim(), post: post);
    setState(() {
      commentController.text='';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
        data: (data) {
          return SingleChildScrollView(
            child: Column(
              children: [
                PostCard(post: data),
                if (!isGuest)
                  TextField(
                    onSubmitted: (val) => addComment(data),
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'What are your thoughts?',
                      filled: true,
                      border: InputBorder.none,
                    ),
                  ),
                ref.watch(getPostCommentsProvider(widget.postId)).when(
                  data: (data) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        final comment = data[index];
                        return CommentCard(comment: comment);
                      },
                      itemCount: data.length,
                    );
                  },
                  error: (error, stackTrace) {
                    return ErrorText(error: error.toString());
                  },
                  loading: () => const Loader(),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader(),
      ),
    );
  }
}
