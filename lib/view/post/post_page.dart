import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iwate_ch_community_web/model/keijiban.dart';
import 'package:iwate_ch_community_web/model/post.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/enums.dart';
import 'package:iwate_ch_community_web/utils/firestore/keijiban_posts.dart';
import 'package:iwate_ch_community_web/utils/firestore/posts.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/utils/hex_color.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';

class PostPage extends StatefulWidget {
  final PostMode postMode;
  final Keijiban? keijiban;
  const PostPage({Key? key, required this.postMode, this.keijiban}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  TextEditingController postTextController = TextEditingController();
  NetworkImage? postImage;
  File? file;

  Future<String> _getImagePath() async{
    try{
      if(postImage != null && file != null) {
        String result = await FunctionUtils.instance.uploadImageFile(Authentication.myAccount!.id, file!);
        if(result.isNotEmpty){
          return result;
        }
      }
      return '';
    } on FirebaseException catch(e) {
      // ignore: avoid_print
      print(e);
      return '';
    }
  }

  Future<dynamic> _insertPost() async{
    dynamic result;
    if(widget.postMode == PostMode.timeLine){
      //タイムライン投稿用writer
      Post newPost = Post(
          content: postTextController.text,
          postAccountId: Authentication.myAccount!.id,
          imagePath: await _getImagePath()
      );
      result = await PostFirestore.instance.addPost(newPost);
    } else {
      //掲示板投稿用writer
      Post newKeijibanPost = Post(
          content: postTextController.text,
          postAccountId: Authentication.myAccount!.id,
          imagePath: await _getImagePath(),
          good: 0,
          keijibanId: widget.keijiban!.id
      );
      result = await KeijibanPostFirestore.instance.addPost(newKeijibanPost);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.instance.createAppBar(
          widget.postMode == PostMode.timeLine ?
          '投稿（タイムライン）' :
          '投稿（' + widget.keijiban!.name + '）',
          context
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 40.0),
            child: Center(child: WidgetUtils.instance.createOpacity()),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent)
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10.0),
                            child: TextField(controller: postTextController,
                                keyboardType: TextInputType.multiline,
                                autofocus: true,
                                maxLines: null,
                                decoration: const InputDecoration(
                                    border: InputBorder.none, hintText: '岩手県についての投稿をしよう！')),
                          ),
                          Container(
                            child: postImage == null ? Container() :
                            Stack(
                                children: [
                                  Center(
                                    child: Image(
                                        image: postImage!,
                                        height: 150
                                    ),
                                  ),
                                  Center(
                                    child: Opacity(
                                      opacity: 0.8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {postImage = null;});
                                        },
                                        child: const Icon(Icons.highlight_remove_rounded),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          ),
                          Visibility(
                            visible: postImage == null,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: DottedBorder(
                                color: Colors.green,
                                dashPattern: const [15.0, 6.0],
                                strokeWidth: 1.5,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async{
                                        file = await FunctionUtils.instance.getImageFromGallery();
                                        if(file != null){
                                          setState(() {
                                            postImage = FunctionUtils.instance.convertImageFileForWeb(file!);
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 100,
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text('画像も投稿することができます'),
                                            Icon(
                                              Icons.add_photo_alternate_outlined,
                                              color: Colors.green,
                                              size: 45,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: ElevatedButton(
                  onPressed: () async{
                    if(postTextController.text.isNotEmpty || (postImage != null && file != null)) {
                      var result = await _insertPost();
                      if(result) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Container(
                      height: 40,
                      width: 50,
                      alignment: Alignment.center,
                      child: const Text('投稿')
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
