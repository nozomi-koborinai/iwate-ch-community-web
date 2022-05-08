// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/view/screen.dart';

import 'create_account_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool _isObscure = true;
  String errorMsg = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset(FunctionUtils.instance.isDarkMode(context) ? 'images/iwate-ch-top.png' : 'images/iwate-ch-top.png', height: 80),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: emailController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'メールアドレス'
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      obscureText: _isObscure,
                      controller: passController,
                      decoration: InputDecoration(
                        hintText: 'パスワード',
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        )
                      )
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(
                          text: 'アカウントを作成していない方は'
                        ),
                        TextSpan(
                          text: 'こちら',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountPage()));
                          }
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10.0, right: 60, left: 60),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.red),
                        children: [
                          TextSpan(
                            text: errorMsg
                          )
                        ]
                      ),
                    ),
                  ),
                  const SizedBox(height: 50,),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async{
                        var result = await Authentication.instance.emailSignIn(emailController.text, passController.text);
                        if(result is UserCredential){
                          if(result.user!.emailVerified){
                            bool _result = await UserFirestore.instance.getUser(result.user!.uid);
                            if(_result){
                              UserFirestore.isKengenForWrite = true;
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Screen()));
                            } else {
                              UserFirestore.isKengenForWrite = false;
                              errorMsg = 'ユーザ情報が取得できませんでした。再度ログインをしてください';
                            }
                          } else {
                            print('メール認証失敗');
                            setState(() {
                              UserFirestore.isKengenForWrite = false;
                              errorMsg = 'メール認証が完了していません。認証を完了してください';
                            });
                          }
                        } else {
                          setState(() {
                            UserFirestore.isKengenForWrite = false;
                            errorMsg = '入力したメールアドレスまたはパスワードに誤りがあります。正しい内容を入力してください';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('emailでログイン'),
                    ),
                  ),
                  // SignInButton(
                  //   Buttons.Google,
                  //   onPressed: () async{
                  //     var result = await Authentication.instance.signInWithGoogle();
                  //     if(result is UserCredential){
                  //       var result = await UserFirestore.instance.getUser(Authentication.currentFirebaseUser!.uid);
                  //       if(result == true){
                  //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Screen()));
                  //       } else {
                  //         Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountPage()));
                  //       }
                  //     }
                  //   },
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
