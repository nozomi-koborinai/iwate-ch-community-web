// ignore_for_file: avoid_print

import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iwate_ch_community_web/model/account.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/firestore/posts.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';

import 'keijiban_posts.dart';

class UserFirestore {
  //内部でのみインスタンス化可能な構造
  ///Private Constructor
  UserFirestore._();

  ///I/F Property
  static final CollectionReference users = _firestoreInstance.collection('users');
  static bool isKengenForWrite = false;
  static UserFirestore get instance => _generationInstance();
  static UserFirestore? _instance;
  static UserFirestore _generationInstance(){
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= UserFirestore._();
    //インスタンス化された_instanceを返却
    return _instance!;
  }

  ///firebase_instance
  static final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  ///新規ユーザをusersテーブルに追加
  Future<bool> setUser(Account newAccount) async{
    try {
      await users.doc(newAccount.id).set({
        'name' : newAccount.name,
        'user_id': newAccount.userId,
        'self_introduction': newAccount.selfIntroduction,
        'image_path': newAccount.imagePath,
        'is_official': newAccount.isOfficial,
        'created_time': Timestamp.now(),
        'updated_time': Timestamp.now(),
      });
      print('新規ユーザ作成完了');
      return true;
    } on FirebaseException catch(e) {
      print('新規ユーザ作成エラー: $e');
      return false;
    }
  }

  ///usersテーブルから該当指定ユーザを取得
  Future<bool> getUser(String uId) async{
    try{
      //指定Idでusersテーブルから1件のレコードを取得
      DocumentSnapshot documentSnapshot = await users.doc(uId).get();
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      Account myAccount = Account(
          id: uId,
          name: data['name'],
          userId: data['user_id'],
          selfIntroduction: data['self_introduction'],
          imagePath: data['image_path'],
          isOfficial: data['is_official'],
          createdTime: data['created_time'],
          updateTime: data['updated_time']
      );
      Authentication.myAccount = myAccount;
      print('ユーザ取得完了');
      return true;
    } on FirebaseException catch(e) {
      print('ユーザ取得失敗: $e');
      return false;
    }
  }

  ///usersテーブル更新
  Future<bool> updateUser(Account updateAccount) async{
    try {
      await users.doc(updateAccount.id).update({
        'name': updateAccount.name,
        'image_path': updateAccount.imagePath,
        'user_id': updateAccount.userId,
        'is_official': updateAccount.isOfficial,
        'self_introduction': updateAccount.selfIntroduction,
        'updated_time': Timestamp.now()
      });
      print('ユーザ情報の更新完了');
      return true;
    } on FirebaseException catch(e) {
      print('ユーザ情報の更新エラー: $e');
      return false;
    }
  }

  ///アカウントIdに紐づく投稿者データを取得
  Future<Map<String, Account>?> getPostUserMap(List<String> accountIds) async{
    Map<String, Account> map = {};
    try {
      await Future.forEach(accountIds, (String accountId) async{
        var doc = await users.doc(accountId).get();
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Account postAccount = Account(
            id: accountId,
            name: data['name'],
            userId: data['user_id'],
            imagePath: data['image_path'],
            selfIntroduction: data['self_introduction'],
            isOfficial: data['is_official'],
            createdTime: data['created_time'],
            updateTime: data['updated_time']
        );
        map[accountId] = postAccount;
      });
      // ignore: avoid_print
      print('投稿ユーザーの情報取得完了');
      return map;
    } on FirebaseException catch(e){
      // ignore: avoid_print
      print('投稿ユーザーの情報取得エラー:$e');
      return null;
    }
  }

  ///アカウント削除
  Future<dynamic> deleteUser(String accountId) async{
    users.doc(accountId).delete();
    PostFirestore.instance.deletePosts(accountId);
    KeijibanPostFirestore.instance.deletePosts(accountId);
  }
}