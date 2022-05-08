import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String keijibanId;
  String content;
  String imagePath;
  String postAccountId;
  int good;
  Timestamp? createdTime;
  Post({this.id = '', this.keijibanId = '', this.content = '', this.imagePath = '',
    this.postAccountId = '', this.good = 0, this.createdTime});
}