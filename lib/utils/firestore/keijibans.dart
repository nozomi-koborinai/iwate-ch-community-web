import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iwate_ch_community_web/model/keijiban.dart';

class KeijibanFirestore {
  //内部でのみインスタンス化可能な構造
  ///Private Constructor
  KeijibanFirestore._();

  ///I/F Property
  static final CollectionReference keijibanList = _firestoreInstance.collection('keijiban');
  static final _firestoreInstance = FirebaseFirestore.instance;
  static KeijibanFirestore get instance => _generationInstance();
  static KeijibanFirestore? _instance;
  static KeijibanFirestore _generationInstance(){
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= KeijibanFirestore._();
    //インスタンス化された_instanceを返却
    return _instance!;
  }

  //TODO:掲示板自体の追加処理 => 今はコンソールから追加してるので不要
  // Future<dynamic> addKeijiban(Keijiban newPost) async{
  //   try {
  //     final CollectionReference _userPosts = _firestoreInstance.collection('users')
  //         .doc(newPost.postAccountId).collection('my_posts'); //自分の投稿
  //
  //     //postsテーブルに追加
  //     var result = await posts.add({
  //       'content': newPost.content,
  //       'post_account_id': newPost.postAccountId,
  //       'image_path': newPost.imagePath,
  //       'created_time': Timestamp.now(),
  //     });
  //
  //     //上記追加内容を自分の投稿として紐づける
  //     //RDBの外部キー的な考え
  //     _userPosts.doc(result.id).set({
  //       'post_id': result.id,
  //       'created_time': Timestamp.now()
  //     });
  //     // ignore: avoid_print
  //     print('投稿完了');
  //     return true;
  //   } on FirebaseException catch(e) {
  //     // ignore: avoid_print
  //     print('投稿エラー: $e');
  //     return false;
  //   }
  // }
}