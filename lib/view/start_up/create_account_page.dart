import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iwate_ch_community_web/model/account.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/dialog_utils.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';
import 'package:iwate_ch_community_web/view/start_up/check_email_page.dart';

class CreateAccountPage extends StatefulWidget {
  final bool isSignInWithGoogle;
  const CreateAccountPage({Key? key, this.isSignInWithGoogle = false}) : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  //コントロールバインド用のコントローラ
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  NetworkImage? image;
  File? file;
  bool _isObscure = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.instance.createAppBar('ユーザ登録', context),
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              Center(child: WidgetUtils.instance.createOpacity()),
              SizedBox(
                width: double.infinity,
                //要素を縦に並べていく
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () async{
                        file = await FunctionUtils.instance.getImageFromGallery();
                        if(file != null){
                          setState(() {
                            image = FunctionUtils.instance.convertImageFileForWeb(file!);
                          });
                        }
                      },
                      child: CircleAvatar(
                        foregroundImage: image == null ? null : image!,
                        radius: 40,
                        child: const Icon(Icons.add),
                      ),
                    ),
                    SizedBox(
                        width: 300,
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(hintText: '名前'),
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                            controller: userIdController,
                            decoration: const InputDecoration(hintText: 'ユーザーID')
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                          controller: selfIntroductionController,
                          decoration: const InputDecoration(hintText: '自己紹介')
                      ),
                    ),
                    widget.isSignInWithGoogle ? Container() : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: SizedBox(
                            width: 300,
                            child: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(hintText: 'メールアドレス')
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
                        )
                      ],
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async{
                          if(nameController.text.isNotEmpty
                              && userIdController.text.isNotEmpty
                              && selfIntroductionController.text.isNotEmpty
                              && emailController.text.isNotEmpty
                              && passController.text.isNotEmpty
                              && image != null) {
                            //authのみの登録
                            var result = await Authentication.instance.signUp(emailController.text, passController.text, context);
                            //サインインに成功するとresultにはuserが入ってくる
                            if (result is UserCredential){
                              // String imagePath = await FunctionUtils.instance.uploadImage(result.user!.uid, image!); //uploadが最後まで終わったら次の処理
                              String imagePath = await FunctionUtils.instance.uploadImage(result.user!.uid, image!); //uploadが最後まで終わったら次の処理
                              Account newAccount = Account(
                                  id: result.user!.uid,
                                  name: nameController.text,
                                  userId: userIdController.text,
                                  selfIntroduction: selfIntroductionController.text,
                                  imagePath: imagePath,
                                  isOfficial: false
                              );
                              //autu登録完了後のユーザ情報登録
                              bool _result = await UserFirestore.instance.setUser(newAccount);
                              if (_result) {
                                //メール認証のため、メールを当該ユーザに送信
                                result.user!.sendEmailVerification();
                                //メール認証用画面へ遷移
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    CheckEmailPage(
                                        email: emailController.text,
                                        pass: passController.text
                                    )
                                ));
                              }
                            }
                          } else {
                            DialogUtils.instance.showDialogError(context, '', '未入力の項目があります。\x0A全ての項目を入力してください');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('アカウントを作成'),),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
