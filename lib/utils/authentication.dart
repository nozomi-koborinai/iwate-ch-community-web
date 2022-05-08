// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iwate_ch_community_web/model/account.dart';
import 'package:iwate_ch_community_web/utils/dialog_utils.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';

class Authentication {
  //内部でのみインスタンス化可能な構造
  ///Private Constructor
  Authentication._();

  ///I/F Property
  static const String noAuthorityMail = 'no-authority@mail.com';
  static const String noAuthorityPass = 'no-authority-user';
  static User? currentFirebaseUser;
  static Account? myAccount;
  static Authentication get instance => _generationInstance();
  static Authentication? _instance;
  static Authentication _generationInstance(){
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= Authentication._();
    //インスタンス化された_instanceを返却
    return _instance!;
  }

  ///firebase_instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ///新規ユーザ登録処理
  ///指定されたメールアドレスとパスワードから新規ユーザを生成
  ///※メールアドレスのフォーマット違いとか安全性の低いパスワードが指定された場合はExceptionが発生
  Future<dynamic> signUp(String email, String pass, BuildContext owner) async{
    try{
      UserCredential newAccount = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: pass);
      print('auth登録完了');
      return newAccount;
    } on FirebaseException catch(e) {
      if(e.toString().contains('The email address is badly formatted')){
        DialogUtils.instance.showDialogError(owner, '', 'メールアドレスの入力に誤りがあります。\x0A正しいフォーマットで入力してください');
      } else if(e.toString().contains('weak-password')) {
        DialogUtils.instance.showDialogError(owner, '', 'パスワードは6文字以上の入力が必要です');
      } else if(e.toString().contains('email-already-in-use')){
        DialogUtils.instance.showDialogError(owner, '', '既に使用されているメールアドレスです。\x0A異なるメールアドレスを使用してください');
      }
      print('auth登録エラー: $e');
      return false;
    }
  }

  ///ログイン処理
  ///ログイン失敗時にException発生
  Future<dynamic> emailSignIn(String email, String pass) async{
    try {
      final UserCredential _result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: pass);
      //認証に成功すると戻り値としてuserが返ってくる
      currentFirebaseUser = _result.user;
      print('authサインイン完了');
      return _result;
    } on FirebaseException catch(e) {
      print('authサインインエラー: $e');
      return false;
    }
  }

  ///ログアウト（サインアウト）処理
  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  ///ユーザ情報削除
  Future<void> deleteAuth() async{
    if(currentFirebaseUser != null){
      await currentFirebaseUser!.delete();
    }
  }

  ///ログインを保持しているかどうかを判定
  ///true:ログイン保持中, false:ログイン破棄されている
  bool isSavedLogin() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    bool _result = _auth.currentUser != null;
    print(_result);
    if(_result){
      currentFirebaseUser = _firebaseAuth.currentUser;
      if(!currentFirebaseUser!.emailVerified){
        //メール認証がされていない場合はfalse
        _result = false;
      }
    }
    return _result;
  }

  Future<dynamic> signInWithGoogle() async{
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if(googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
        );
        final UserCredential _result = await _firebaseAuth.signInWithCredential(credential);
        currentFirebaseUser = _result.user;
        print('google認証成功');
        return _result;
      }
    } on FirebaseAuth catch(e) {
      print('google認証エラー: $e');
      return false;
    }
  }

  ///書き込み権限なし用のサインイン
  ///※ログインしていない場合はこのログイン方法を使用
  Future<bool> signInForNoAuthority() async{
    var result = await Authentication.instance.emailSignIn(noAuthorityMail, noAuthorityPass);
    if(result is UserCredential){
      print('aaa');
      bool _result = await UserFirestore.instance.getUser(result.user!.uid);
      if(_result){
        UserFirestore.isKengenForWrite = true;
        return true;
      } else {
        UserFirestore.isKengenForWrite = false;
        return false;
      }
    }
    return false;
  }
}
