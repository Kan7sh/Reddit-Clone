import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart ';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/home/drawers/profile_drawer.dart';
import 'package:reddit_clone/theme/pallete.dart';

import '../../../core/constants/constants.dart';
import '../delegates/search_community_delegate.dart';
import '../drawers/community_list_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);


  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen>{
  int _page = 0;

  void displayDrawer(BuildContext context){
    Scaffold.of(context).openDrawer();
  }
  void displayEndDrawer(BuildContext context){
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChange(int page){
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context ) {
    final user = ref.watch(userProvider);
    final currentTheme=ref.watch(themeNotifierProvider);
    final isGuest = user?.isAuthenticated;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          centerTitle: false,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: ()=>displayDrawer(context),
              );
            }
          ),
          actions: [
            IconButton(
                onPressed: (){
                  showSearch(context: context, delegate:SearchCommunityDelegate(ref));
                },
                icon: const  Icon(Icons.search)
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: CircleAvatar(
                    backgroundImage: NetworkImage(user!.profilePic),
                  ),
                  onPressed: ()=>displayEndDrawer(context),
                );
              }
            ),
          ],
        ),

      body:Constants.tabWidgets[_page],

      drawer: const CommunityListDrawer(),
      endDrawer: isGuest!?const ProfileDrawer():null,
      bottomNavigationBar: isGuest?CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        backgroundColor: currentTheme.backgroundColor,
        items: const  [
           BottomNavigationBarItem(
             icon: Icon(Icons.home),
             label: '',
           ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '',
          )
        ],
        onTap: onPageChange ,
        currentIndex: _page,
      ):null,
    );
  }
}
