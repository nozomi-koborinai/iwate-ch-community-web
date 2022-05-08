import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iwate_ch_community_web/model/post.dart';

class KeijibanPostFirestore {
  //内部でのみインスタンス化可能な構造
  ///Private Constructor
  KeijibanPostFirestore._();

  ///I/F Property
  static final CollectionReference keijibanPosts = _firestoreInstance.collection('keijiban_posts');
  static final _firestoreInstance = FirebaseFirestore.instance;
  static KeijibanPostFirestore get instance => _generationInstance();
  static KeijibanPostFirestore? _instance;
  static KeijibanPostFirestore _generationInstance(){
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= KeijibanPostFirestore._();
    //インスタンス化された_instanceを返却
    return _instance!;
  }

  ///掲示板投稿を登録
  Future<bool> addPost(Post newKeijibanPost) async{
    try {
      //keijiban_postsテーブルに追加
      var result = await keijibanPosts.add({
        'content': newKeijibanPost.content,
        'good':newKeijibanPost.good,
        'image_path': newKeijibanPost.imagePath,
        'keijiban_id':newKeijibanPost.keijibanId,
        'post_account_id': newKeijibanPost.postAccountId,
        'created_time': Timestamp.now(),
      });
      // ignore: avoid_print
      print('投稿完了');
      return true;
    } on FirebaseException catch(e) {
      // ignore: avoid_print
      print('投稿エラー: $e');
      return false;
    }
  }

  ///掲示板idに紐づく掲示板投稿を取得
  Future<List<Post>?> getPostsFromKeijibanId(String keijibanId) async{
    List<Post> postList = [];
    try {
      QuerySnapshot<Map<String, dynamic>> docs = await _firestoreInstance.collection('keijiban_posts').where('keijiban_id', isEqualTo: keijibanId).get();
      for(QueryDocumentSnapshot<Map<String, dynamic>> doc in docs.docs){
        Post keijibanPost = Post(
          id: doc.id,
          content: doc.data()['content'],
          good: doc.data()['good'],
          imagePath: doc.data()['image_path'],
          keijibanId: doc.data()['keijiban_id'],
          postAccountId: doc.data()['post_account_id'],
          createdTime: doc.data()['created_time']
        );
        postList.add(keijibanPost);
      }
      // ignore: avoid_print
      print('掲示板投稿を取得完了');
      // ignore: avoid_print
      return postList;
    } on FirebaseException catch(e) {
      // ignore: avoid_print
      print('掲示板投稿取得エラー：$e');
      return null;
    }
  }

  ///掲示板投稿のいいね数をカウントアップ
  Future<dynamic> countUpKeijibanPost(Post keijibanPost) async{
    try{
      keijibanPost.good += 1;
      _firestoreInstance.collection('keijiban_posts').doc(keijibanPost.id).update({'good': keijibanPost.good});
      return true;
    } on FirebaseException catch(e) {
      // ignore: avoid_print
      print('いいねのカウントアップエラー: $e');
      return false;
    }
  }

  ///削除したidに紐づくpostを削除
  Future<dynamic> deletePosts(String accountId) async{
    var snapshot = await keijibanPosts.where('post_account_id', isEqualTo: accountId).get();
    for (var doc in snapshot.docs) {
      await keijibanPosts.doc(doc.id).delete();
    }
  }
}