import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iwate_ch_community_web/model/post.dart';

class PostFirestore{
  //内部でのみインスタンス化可能な構造
  ///Private Constructor
  PostFirestore._();

  ///I/F Property
  static final CollectionReference posts = _firestoreInstance.collection('posts');
  static final _firestoreInstance = FirebaseFirestore.instance;
  static PostFirestore get instance => _generationInstance();
  static PostFirestore? _instance;
  static PostFirestore _generationInstance(){
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= PostFirestore._();
    //インスタンス化された_instanceを返却
    return _instance!;
  }

  Future<dynamic> addPost(Post newPost) async{
    try {
      final CollectionReference _userPosts = _firestoreInstance.collection('users')
          .doc(newPost.postAccountId).collection('my_posts'); //自分の投稿

      //postsテーブルに追加
      var result = await posts.add({
        'content': newPost.content,
        'post_account_id': newPost.postAccountId,
        'image_path': newPost.imagePath,
        'created_time': Timestamp.now(),
      });

      //上記追加内容を自分の投稿として紐づける
      //RDBの外部キー的な考え
      _userPosts.doc(result.id).set({
        'post_id': result.id,
        'created_time': Timestamp.now()
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

  Future<List<Post>?> getPostsFromIds(List<String> ids) async{
    List<Post> postList = [];
    try {
      await Future.forEach(ids, (String id) async{
        var doc = await posts.doc(id).get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Post post = Post(
            id: doc.id,
            content: data['content'],
            imagePath: data['image_path'],
            postAccountId: data['post_account_id'],
            createdTime: data['created_time']
        );
        postList.add(post);
      });
      // ignore: avoid_print
      print('自分の投稿を取得完了');
      return postList;
    } on FirebaseException catch(e) {
      // ignore: avoid_print
      print('自分の投稿取得エラー：$e');
      return null;
    }
  }

  ///削除したidに紐づくpostを削除
  Future<dynamic> deletePosts(String accountId) async{
    final CollectionReference _userPosts = _firestoreInstance.collection('users').doc(accountId).collection('my_posts');
    var snapshot = await _userPosts.get();
    for (var doc in snapshot.docs) {
      await posts.doc(doc.id).delete();
      _userPosts.doc(doc.id).delete();
    }
  }
}