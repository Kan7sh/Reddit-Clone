import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';

import '../../core/common/post_card.dart';
import '../auth/controller/auth_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    if(!isGuest){
    return ref.watch(userCommunitiesProvider).when(
        data: (data)=>ref.watch(userPostsProvider(data)).when(
            data: (data){
              return ListView.builder(
                  itemBuilder: (BuildContext context,int index){
                    final post = data[index];
                    return PostCard(post: post,);
                  },
                  itemCount: data.length,
              );
            },
            error: (error,stackTrace)=>ErrorText(error: error.toString()),
            loading:()=>const Loader()
        ),
        error: (error,stackTrace)=>ErrorText(error: error.toString()),
        loading:()=>const Loader()
    );
     }

    return ref.watch(userCommunitiesProvider).when(
        data: (data)=>ref.watch(guestPostsProvider).when(
            data: (data){
              return ListView.builder(
                itemBuilder: (BuildContext context,int index){
                  final post = data[index];
                  return PostCard(post: post,);
                },
                itemCount: data.length,
              );
            },
            error: (error,stackTrace)=>ErrorText(error: error.toString()),
            loading:()=>const Loader()
        ),
        error: (error,stackTrace)=>ErrorText(error: error.toString()),
        loading:()=>const Loader()
    );
  }
}
