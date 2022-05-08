import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'function_utils.dart';

class WidgetUtils {
  //内部でのみインスタンス化可能な構造
  ///Private Constructor
  WidgetUtils._();

  ///I/F Property
  static WidgetUtils get instance => _generationInstance();
  static WidgetUtils? _instance;
  static WidgetUtils _generationInstance(){
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= WidgetUtils._();
    //インスタンス化された_instanceを返却
    return _instance!;
  }

  ///共通のAppBarを生成
  AppBar createAppBar(String title, BuildContext context){
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: FunctionUtils.instance.isDarkMode(context) ? Colors.white : Colors.black),
      title: Text(title, style: TextStyle(color: FunctionUtils.instance.isDarkMode(context) ? Colors.white : Colors.black)),
      centerTitle: true,
    );
  }

  ///共通のOpacityを生成
  Opacity createOpacity(){
    return const Opacity(
      opacity: 0.15,
      child: Image(
        image: NetworkImage('http://iwate-ch.com/wp-content/uploads/2021/07/cropped-favicon_logo.png'),
      ),
    );
  }

  ///共通のProgressIndicatorを生成
  Widget createProgressIndicator() {
    return Container(
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: Colors.green,
      )
    );
  }

  ///リンクテキストを含むWidgetを生成
  Widget createTextAndLinkText(String message) {
    //リンク文字列の配列を取得
    List<String> urlList = FunctionUtils.instance.getSplittedMessage(message);
    //リンク文字列が取得できた場合は、元の文字列からリンクを削除
    bool isReplace = false;
    if(urlList.isNotEmpty) {
      for(String url in urlList) {
        message = message.replaceAll(url, '');
        isReplace = true;
      }
    }
    return Column(
      children: [
        if(isReplace) Container(transform: Matrix4.translationValues(-60.0, 0.0, 0.0), child: Text(message),) else Text(message),
        for(String url in urlList) RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: url,
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if (await canLaunch(url)) {
                    await launch(url);
                    }
                  }
              )
            ]
          )
        )
      ],
    );
  }
}