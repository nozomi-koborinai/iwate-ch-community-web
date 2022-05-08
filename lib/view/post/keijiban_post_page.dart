import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:iwate_ch_community_web/model/account.dart';
import 'package:iwate_ch_community_web/model/keijiban.dart';
import 'package:iwate_ch_community_web/model/post.dart';
import 'package:iwate_ch_community_web/utils/enums.dart';
import 'package:iwate_ch_community_web/utils/firestore/keijiban_posts.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';
import 'package:iwate_ch_community_web/view/post/post_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

class KeijibanPostPage extends StatefulWidget {
  final Keijiban? keijiban;
  const KeijibanPostPage({Key? key, required this.keijiban}) : super(key: key);

  @override
  _KeijibanPostPageState createState() => _KeijibanPostPageState();
}

class _KeijibanPostPageState extends State<KeijibanPostPage> {
  GlobalKey shareKey = GlobalKey();

  Future<ByteData?> exportToImage(GlobalKey globalKey) async {
    final boundary =
    globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    print('image化成功');
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData;
  }

  Future<File> getApplicationDocumentsFile(
      String text, List<int> imageData) async {
    final directory = await getApplicationDocumentsDirectory();

    final exportFile = File('${directory.path}/$text.png');
    if (!await exportFile.exists()) {
      await exportFile.create(recursive: true);
    }
    final file = await exportFile.writeAsBytes(imageData);
    return file;
  }

  void shareImageAndText(String text, GlobalKey globalKey) async {
    //shareする際のテキスト
    try {
      //byte dataに
      final bytes = await exportToImage(globalKey);
      final widgetImageData =
      bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      //App directoryファイルに保存
      final applicationDocumentsFile =
      await getApplicationDocumentsFile(text, widgetImageData);

      final path = applicationDocumentsFile.path;
      await ShareExtend.share(path, "image");
      applicationDocumentsFile.delete();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.instance.createAppBar(widget.keijiban!.name, context),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Center(child: WidgetUtils.instance.createOpacity()),
            StreamBuilder<QuerySnapshot>(
                stream: KeijibanPostFirestore.keijibanPosts.where('keijiban_id', isEqualTo: widget.keijiban!.id).orderBy('created_time', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index){
                          Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                          Post keijibanPost = Post(
                              id: snapshot.data!.docs[index].id,
                              content: data['content'],
                              good: data['good'],
                              imagePath: data['image_path'],
                              keijibanId: data['keijiban_id'],
                              postAccountId: data['post_account_id'],
                              createdTime: data['created_time']
                          );
                          return FutureBuilder<Map<String, Account>?>(
                            future: UserFirestore.instance.getPostUserMap([keijibanPost.postAccountId]),
                            builder: (context, userSnapshot) {
                              if(userSnapshot.hasData && userSnapshot.connectionState == ConnectionState.done){
                                Account postAccount = userSnapshot.data![keijibanPost.postAccountId]!;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        foregroundImage: NetworkImage(postAccount.imagePath),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(left:10.0),
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.0),
                                              color: Colors.grey.withOpacity(0.15)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                WidgetUtils.instance.createTextAndLinkText(keijibanPost.content),
                                                if(keijibanPost.imagePath.isNotEmpty) Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Image.network(
                                                    keijibanPost.imagePath,
                                                    alignment: Alignment.centerLeft,
                                                    height: 200.0,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Row(
                                                    children: [
                                                      Text(postAccount.name, style: const TextStyle(color: Colors.grey)),
                                                      Text('@${postAccount.userId}', style: const TextStyle(color: Colors.grey),),
                                                      FunctionUtils.instance.getIconForOfficial(postAccount.isOfficial),
                                                      Text(' at ' + DateFormat('yy/MM/dd HH:mm').format(keijibanPost.createdTime!.toDate()),
                                                          style: const TextStyle(color: Colors.grey)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                return WidgetUtils.instance.createProgressIndicator();
                              }
                            }
                          );
                        }
                    );
                  } else {
                    return WidgetUtils.instance.createProgressIndicator();
                  }
                }
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: UserFirestore.isKengenForWrite,
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 50.0,
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (content) => PostPage(postMode: PostMode.keijiban, keijiban: widget.keijiban)));
            },
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
