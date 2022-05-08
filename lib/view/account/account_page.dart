import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iwate_ch_community_web/model/account.dart';
import 'package:iwate_ch_community_web/model/post.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/firestore/posts.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';

import 'edit_account_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Account myAccount = Authentication.myAccount!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 56.0),
              child: Center(child: WidgetUtils.instance.createOpacity()),
            ),
            SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    if(UserFirestore.isKengenForWrite)
                    Container(
                      padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
                      height: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    foregroundImage: NetworkImage(myAccount.imagePath),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(myAccount.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                      Text('@${myAccount.userId}', style: const TextStyle(color: Colors.grey),),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 17),
                                    child: FunctionUtils.instance.getIconForOfficial(myAccount.isOfficial),
                                  ),
                                ],
                              ),
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async{
                                    var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditAccountPage()));
                                    if(result) {
                                      setState(() {
                                        myAccount = Authentication.myAccount!;
                                      });
                                    }
                                  },
                                  child: const Text('編集', style: TextStyle(color: Colors.green))
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(myAccount.selfIntroduction)
                        ],
                      ),
                    ),
                    Container(
                      alignment :Alignment.center,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(
                              color: Colors.green, width: 3
                          ))
                      ),
                      child: const Text('自分の投稿一覧', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                        stream: UserFirestore.users.doc(myAccount.id)
                            .collection('my_posts').orderBy('created_time', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            List<String> myPostIds = List.generate(snapshot.data!.docs.length, (index) {
                              return snapshot.data!.docs[index].id;
                            });
                            return FutureBuilder<List<Post>?>(
                                future: PostFirestore.instance.getPostsFromIds(myPostIds),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData) {
                                    return ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          Post post = snapshot.data![index];
                                          return SingleChildScrollView(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: index == 0 ? const Border(
                                                    top: BorderSide(color: Colors.grey, width: 0),
                                                    bottom: BorderSide(color: Colors.grey, width: 0),
                                                  ) : const Border(bottom: BorderSide(color: Colors.grey, width: 0))
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 22,
                                                    foregroundImage: NetworkImage(myAccount.imagePath),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 5.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(myAccount.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                  Text('@${myAccount.userId}', style: const TextStyle(color: Colors.grey),),
                                                                ],
                                                              ),
                                                              Text(DateFormat('yy/MM/dd HH:mm').format(post.createdTime!.toDate()))
                                                            ],
                                                          ),
                                                          Text(post.content),
                                                          if(post.imagePath.isNotEmpty) Image.network(
                                                            post.imagePath,
                                                            alignment: Alignment.centerLeft,
                                                            height: 200.0,
                                                            width: 500.0,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  } else {
                                    return WidgetUtils.instance.createProgressIndicator();
                                  }
                                }
                            );
                          } else {
                            return Container();
                          }
                        }
                    )
                    )
                  ],
                ),
              ),
            ),
          ]
        )
    );
  }
}
