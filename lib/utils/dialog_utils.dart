import 'package:flutter/material.dart';

class DialogUtils {
  //内部でのみインスタンス化可能な構造
  ///Private Constructor
  DialogUtils._();

  ///I/F Property
  static DialogUtils get instance => _generationInstance();
  static DialogUtils? _instance;
  static DialogUtils _generationInstance(){
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= DialogUtils._();
    //インスタンス化された_instanceを返却
    return _instance!;
  }

  ///確認ダイアログ表示
  ///return: true:OK, false:Cancel
  bool showDialogQuestion(BuildContext owner, String title, String msg) {
    bool result = false;
    showDialog(
      context: owner,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            ElevatedButton(
              child: const Text("はい"),
              onPressed: () => result = true,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ElevatedButton(
              child: const Text("いいえ"),
              onPressed: () {
                result = false;
                Navigator.pop(owner);
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
    return result;
  }

  ///エラーダイアログ表示
  void showDialogError(BuildContext owner, String title, String msg) {
    showDialog(
      context: owner,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text(
            title.isEmpty ? 'エラー' : title,
            style: const TextStyle(color: Colors.red),
          ),
          content: Text(msg),
          actions: [
            SizedBox(
              height: 40,
              child: ElevatedButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(owner),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}