import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quiz_first/util/logger.dart';

class ImageStorage {
  static Future<List<String>> uploadImages(
      List<Uint8List> images, String itemKey) async {
    var metaData = SettableMetadata(contentType: 'images/jpeg');

    List<String> downloadUrls = [];

    for (int i = 0; i < images.length; i++) {
      Reference ref = FirebaseStorage.instance.ref('images/$itemKey/$i.jpg');
      if (images.isNotEmpty) {
        await ref.putData(images[i], metaData).catchError((onError) {
          logger.e(onError.toString());
        });

        downloadUrls.add(await ref.getDownloadURL());
      }
    }

    return downloadUrls;
  }

// 이미지 삭제 : firebase Storage에서 폴더 및 파일 삭제하기
  static deleteImages(itemKey) async {
    await FirebaseStorage.instance
        .ref('images/$itemKey/')
        .listAll()
        .then((value) {
      FirebaseStorage.instance.ref(value.items.first.fullPath).delete();
    });
  }

// 프로필 이미지 삭제 : firebase Storage에서 폴더 및 파일 삭제하기
  static deleteProfileImages(userKey) async {
    await FirebaseStorage.instance
        .ref('images/$userKey/')
        .listAll()
        .then((value) {
      FirebaseStorage.instance.ref(value.items.first.fullPath).delete();
    });
  }
}
