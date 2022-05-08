import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/enums.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/view/post/keijiban_list_page.dart';
import 'package:iwate_ch_community_web/view/post/post_page.dart';
import 'package:iwate_ch_community_web/view/post/time_line_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'account/account_page.dart';
import 'account/no_account_page.dart';

class Screen extends StatefulWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  int selectedIndex = 1;
  List<Widget> pageList = [const TimeLinePage(), const KeijibanListPage(), if(UserFirestore.isKengenForWrite) const AccountPage() else const NoAccountPage()];
  // List<Widget> pageList = [const TimeLinePage(), const AccountPage];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: pageList[selectedIndex],
        bottom: true,
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: SalomonBottomBar(
          items: [
            SalomonBottomBarItem(
                icon: const Icon(Icons.home_outlined),
                title: const Text('タイムライン'),
                selectedColor: Colors.green
            ),
            SalomonBottomBarItem(
                icon: const Icon(Icons.wysiwyg_outlined),
                title: const Text('掲示板'),
                selectedColor: Colors.green
            ),
            SalomonBottomBarItem(
                icon: const Icon(Icons.perm_identity_outlined),
                title: const Text('アカウント'),
                selectedColor: Colors.green
            ),
          ],
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ),
      floatingActionButton: Visibility(
        visible: selectedIndex != 1 && UserFirestore.isKengenForWrite,
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (content) => const PostPage(postMode: PostMode.timeLine)));
            },
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
