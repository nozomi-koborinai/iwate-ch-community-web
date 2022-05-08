import 'package:cloud_firestore/cloud_firestore.dart';

class Keijiban {
  String id;
  String name;
  String imagePath;
  bool isVisible;
  Timestamp? createdTime;
  Keijiban({this.id = '', this.imagePath = '', this.name = '', this.isVisible = true, this.createdTime});
}