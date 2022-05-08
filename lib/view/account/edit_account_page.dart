import 'dart:html';

import 'package:flutter/material.dart';
import 'package:iwate_ch_community_web/model/account.dart';
import 'package:iwate_ch_community_web/utils/authentication.dart';
import 'package:iwate_ch_community_web/utils/dialog_utils.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';
import 'package:iwate_ch_community_web/view/screen.dart';
import 'package:iwate_ch_community_web/view/start_up/login_page.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({Key? key}) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  Account myAccount = Authentication.myAccount!;
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  NetworkImage? image;
  File? file;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: myAccount.name);
    userIdController = TextEditingController(text: myAccount.userId);
    selfIntroductionController = TextEditingController(text: myAccount.selfIntroduction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.instance.createAppBar('プロフィール編集', context),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Center(child: WidgetUtils.instance.createOpacity()),
            SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
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
                        foregroundImage: FunctionUtils.instance.getImage(image, myAccount.imagePath),
                        radius: 40,
                        child: const Icon(Icons.add),
                      ),
                    ),
                    SizedBox(
                        width: 300,
                        child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              helperText: '名前',
                              helperStyle: TextStyle(
                                color: Colors.green,
                                fontSize: 15,
                              )
                            )
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: SizedBox(
                        width: 300,
                          child: TextField(
                              controller: userIdController,
                              decoration: const InputDecoration(
                                  helperText: 'ユーザーID',
                                  helperStyle: TextStyle(
                                    color: Colors.green,
                                    fontSize: 15,
                                  )
                              )
                          )
                      ),
                    ),
                    SizedBox(
                      width: 300,
                        child: TextField(
                            controller: selfIntroductionController,
                            decoration: const InputDecoration(
                                helperText: '自己紹介',
                                helperStyle: TextStyle(
                                  color: Colors.green,
                                  fontSize: 15,
                                )
                            )
                        )
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 35,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () async{
                          if(nameController.text.isNotEmpty
                              && userIdController.text.isNotEmpty
                              && selfIntroductionController.text.isNotEmpty) {
                            String imagePath = '';

                            if(file == null){
                              //変更画像を選択していない場合
                              imagePath = myAccount.imagePath;
                            } else {
                              //変更画像を選択した場合
                              var result = await FunctionUtils.instance.uploadImageFile(myAccount.id, file!);
                              imagePath = result;
                            }
                            Account updateAccount = Account(
                                id: myAccount.id,
                                name: nameController.text,
                                userId: userIdController.text,
                                isOfficial: myAccount.isOfficial,
                                selfIntroduction: selfIntroductionController.text,
                                imagePath: imagePath
                            );
                            var result = await UserFirestore.instance.updateUser(updateAccount);
                            if(result){
                              Authentication.myAccount = updateAccount;
                              Navigator.pop(context, true);
                            }
                          } else {
                            return;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('更新'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 35,
                      width: 140,
                      child: ElevatedButton(
                          onPressed: () async{
                            Authentication.instance.signOut();
                            await Authentication.instance.signInForNoAuthority();
                            UserFirestore.isKengenForWrite = false;
                            while(Navigator.canPop(context)){
                              Navigator.pop(context);
                            }
                            Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context) => const Screen()
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('ログアウト')
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 35,
                      width: 140,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text(
                                    "確認",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  content: const Text("このアカウントを削除します。\x0Aよろしいですか？"),
                                  actions: [
                                    ElevatedButton(
                                      child: const Text("はい"),
                                      onPressed: () async{
                                        await UserFirestore.instance.deleteUser(myAccount.id);
                                        await Authentication.instance.deleteAuth();
                                        await Authentication.instance.signInForNoAuthority();
                                        UserFirestore.isKengenForWrite = false;
                                        while(Navigator.canPop(context)){
                                          Navigator.pop(context);
                                        }
                                        Navigator.pushReplacement(context, MaterialPageRoute(
                                            builder: (context) => const Screen()
                                        ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                        onPrimary: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      child: const Text("いいえ"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                        onPrimary: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('アカウント削除')
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}
