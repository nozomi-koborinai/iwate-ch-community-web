// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';
import 'package:iwate_ch_community_web/view/screen.dart';
import 'package:iwate_ch_community_web/view/start_up/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const locale = Locale("ja", "JP");
    return MaterialApp(
      //↓中国語フォント対応
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        locale,
      ],
      //↑中国語フォント対応

      theme: ThemeData.light(), // ライト用テーマ
      darkTheme: ThemeData.dark(), // ダーク用テーマ
      themeMode: ThemeMode.system, // モードをシステム設定にする
      title: 'いわてちゃんねる_コミュニティ',
      home: FutureBuilder(
        future: _checkLoginAsync(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            print('非同期処理終了:');
            return snapshot.data!;
          } else {
            print('非同期処理中...');
            return WidgetUtils.instance.createProgressIndicator();
          }
          // print(snapshot.error.toString());
          // return snapshot.data!;
          // if(snapshot.connectionState == ConnectionState.done) { //futureで設定した処理が終わっていれば
          //   return snapshot.data!;
          // } else {
          //   return const CircularProgressIndicator();
          // }

          // return snapshot.data!;
          // print(snapshot.data!.runtimeType);
          // 通信中はスピナーを表示
          // if (snapshot.connectionState != ConnectionState.done) {
          //   return const CircularProgressIndicator();
          // }

          // エラー発生時はエラーメッセージを表示
          // if (snapshot.hasError) {
          //   return Text(snapshot.error.toString());
          // }
        },
      ),
    );
  }
}

/// ログイン状態に応じた画面を取得
Future<Widget> _checkLoginAsync() async {
  Widget _page = const Screen();

  await for (User? user in FirebaseAuth.instance.authStateChanges()) {
    if (user != null) {
      print('ログイン済み');
      if (user!.email! == Authentication.noAuthorityMail) {
        UserFirestore.isKengenForWrite = false;
      } else {
        UserFirestore.isKengenForWrite = true;
      }
      if (await UserFirestore.instance.getUser(user!.uid)) {
        print('getUser成功');
        Authentication.currentFirebaseUser = user;
        print('setCurrentFirebaseUser成功');
        _page = const Screen();
        print('pageが設定された');
      } else {
        if (!await Authentication.instance.signInForNoAuthority()) {
          _page = const LoginPage();
        }
        UserFirestore.isKengenForWrite = false;
      }
    } else {
      if (!await Authentication.instance.signInForNoAuthority()) {
        _page = const LoginPage();
      }
      UserFirestore.isKengenForWrite = false;
    }
    break;
  }
  return _page;
}
