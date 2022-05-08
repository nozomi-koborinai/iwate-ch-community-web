// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/dialog_utils.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';
import 'package:iwate_ch_community_web/view/screen.dart';

class CheckEmailPage extends StatefulWidget {
  final String email;
  final String pass;
  const CheckEmailPage({Key? key, required this.email, required this.pass}) : super(key: key);
  @override
  _CheckEmailPageState createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.instance.createAppBar('メールアドレス認証', context),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('登録いただいたメールアドレス宛に確認のメールを送信しております。\x0Aそちらに記載されているURLをクリックして認証を完了してください。'),
                ElevatedButton(onPressed: () async{
                  var result = await Authentication.instance.emailSignIn(widget.email, widget.pass);
                  if(result is UserCredential){
                    if(result.user!.emailVerified){
                      //email認証が完了していれば次の画面へ遷移
                      while(Navigator.canPop(context)){
                        Navigator.pop(context);
                      }
                      UserFirestore.isKengenForWrite = true;
                      await UserFirestore.instance.getUser(result.user!.uid);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Screen()));
                    } else {
                      //email認証が未完了の場合は何もしない
                      DialogUtils.instance.showDialogError(context, '', 'メール認証が完了していません。\x0Aメール認証を完了してください');
                      print('メール認証が完了していません。');
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
                    child: const Text('認証完了')
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
