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

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(FunctionUtils.instance.isDarkMode(context) ? 'images/iwate-ch-top.png' : 'images/iwate-ch-top.png', height: 55),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 2,
      ),
      body: Stack(
          children: [
          Center(child: WidgetUtils.instance.createOpacity()),
          StreamBuilder<QuerySnapshot>(
              stream: PostFirestore.posts.orderBy('created_time', descending: true).snapshots(),
              builder: (context, postSnapshot) {
                if(postSnapshot.hasData) {
                  List<String> postAccountIds = [];
                  for (var doc in postSnapshot.data!.docs) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    if(!postAccountIds.contains(data['post_account_id'])) {
                      postAccountIds.add(data['post_account_id']);
                    }
                  }
                  return FutureBuilder<Map<String, Account>?>(
                      future: UserFirestore.instance.getPostUserMap(postAccountIds),
                      builder: (context, userSnapshot) {
                        if(userSnapshot.hasData && userSnapshot.connectionState == ConnectionState.done){
                          return ListView.builder(
                            itemCount: postSnapshot.data!.docs.length,
                            itemBuilder: (content, index) {
                              Map<String, dynamic> data = postSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                              Post post = Post(
                                  id: postSnapshot.data!.docs[index].id,
                                  content: data['content'],
                                  imagePath: data['image_path'],
                                  postAccountId: data['post_account_id'],
                                  createdTime: data['created_time']
                              );
                              Account postAccount = userSnapshot.data![post.postAccountId]!;
                              return Container(
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
                                      foregroundImage: NetworkImage(postAccount.imagePath),
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
                                                    Text(postAccount.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    Text('@${postAccount.userId}', style: const TextStyle(color: Colors.grey),),
                                                    FunctionUtils.instance.getIconForOfficial(postAccount.isOfficial),
                                                  ],
                                                ),
                                                Text(DateFormat('yy/MM/dd HH:mm').format(post.createdTime!.toDate()))
                                              ],
                                            ),
                                            WidgetUtils.instance.createTextAndLinkText(post.content),
                                            if(post.imagePath.isNotEmpty) Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Image.network(
                                                post.imagePath,
                                                alignment: Alignment.centerLeft,
                                                height: 200.0,
                                                width: 500.0,
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return WidgetUtils.instance.createProgressIndicator();
                        }
                      }
                  );
                } else {
                  return Container();
                }
              }
          ),
        ]
      ),
    );
  }
}
