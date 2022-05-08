// ignore_for_file: avoid_print

import 'dart:html';

import 'dart:async';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:image_whisperer/image_whisperer.dart';
import 'package:iwate_ch_community_web/utils/utils_base.dart';
import 'package:iwate_ch_community_web/utils/firestore/users.dart';

class FunctionUtils extends UtilsBase<FunctionUtils> {
  //内部でのみインスタンス化可能な構造
  ///Private Constructor
  FunctionUtils._();

  ///I/F Property
  static FunctionUtils get instance => _generationInstance();
  static FunctionUtils? _instance;
  static FunctionUtils _generationInstance(){
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= FunctionUtils._();
    //インスタンス化された_instanceを返却
    return _instance!;
  }

  ///ローカル端末から画像データを取得
  Future<File?> getImageFromGallery() async{
    var file = await ImagePickerWeb.getImage(outputType: ImageType.file);

    return file != null && file is File && _isImageFile(file) ? file : null;
  }

  ///画像ファイルの場合true, それ以外false
  bool _isImageFile(File file) {
    List<String> extensionList = ['bpm', 'jpg', 'gif', 'png', 'jpeg', 'webp'];
    String extension = file.name.split('.').last;
    return extensionList.contains(extension);
  }

  ///File(dart:html)の型を表示に有効な型に変換
  NetworkImage? convertImageFileForWeb(File file){
    BlobImage blobImage = convertBlobImage(file);
    final image = NetworkImage(blobImage.url);
    return image is NetworkImage ? image : null;
  }

  ///Blob画像に変換
  BlobImage convertBlobImage(File file){
    return BlobImage(file, name: file.name);
  }

  ///Firebase内のストレージに画像をアップロード
  Future<String> uploadImage(String uId, NetworkImage image) async{
    final FirebaseStorage _storageInstance = FirebaseStorage.instance;
    final Reference ref = _storageInstance.ref();
    await ref.child(uId).putBlob(image);
    String downloadUrl = await _storageInstance.ref(uId).getDownloadURL();
    print('image_path: $downloadUrl');
    return downloadUrl;
  }

  Future<String> uploadImageFile(String uId, File image, {String? imageName}) async {
    // final FirebaseStorage _storageInstance = FirebaseStorage.instance;
    // final Reference ref = _storageInstance.ref();



    fb.StorageReference storageRef = fb.storage().ref('images/' + _convertImageFileName(image.name));
    fb.UploadTaskSnapshot uploadTaskSnapshot = await storageRef.put(image).future;

    Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
    return imageUri.toString();
  }

  ///firebase_storageからファイルを削除
  ///※暇な時実装
  Future<void> deleteImageFile() async{

  }

  ///画像ファイル名称を一意にするメソッド
  String _convertImageFileName(String fileName) {
    List<String> fileNameList = fileName.split('.');
    if(fileNameList.length == 1){
      //拡張子がない場合
      return DateTime.now().toString();
    }
    //拡張子がある場合
    return DateTime.now().toString() + '.' + fileNameList.last.toString();
  }

  ImageProvider getImage(NetworkImage? image, String imagePath) {
    if(image == null) {
      return NetworkImage(imagePath);
    } else {
      return image!;
    }
  }

  Widget getIconForOfficial(bool isOfficial) {
    if(isOfficial) {
      return Row(
        children: const [
          Text(' '),
          Icon(
            Icons.check_circle_outline,
            color: Colors.lightBlueAccent,
            size: 18,
          ),
        ],
      );
    } else {
      return const Text('');
    }
  }

  ///ダークモードかどうか
  ///true:dark, false:light
  bool isDarkMode(BuildContext context) {
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark;
  }

  ///指定されたメッセージの中からURLを抽出して一つの配列として返却する
  List<String> getSplittedMessage(String message) {
    final RegExp urlRegExp = RegExp(
        r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?');
    final Iterable<RegExpMatch> urlMatches =
    urlRegExp.allMatches(message);
    final List<String> splittedMessage = <String>[];
    for (RegExpMatch urlMatch in urlMatches) {
      final String url = message.substring(urlMatch.start, urlMatch.end);
      splittedMessage.add(url);
    }
    return splittedMessage;
  }

  ///表示用の画像を表示する
  ///db上に格納されているファイルがblobのためimage型に変換する必要がある場合に使用するメソッド
  // Future<dynamic> getDispImageFromBlob(String blobPath) async{
  //   return await http.get(blobPath as Uri).then((response) {
  //     new File(blobPath as Uri)
  //   });
  //
  //   http.get(blobPath as Uri).then((response) {
  //     new File(path).writeAsBytes(response.bodyBytes);
  //   });
  // }
}