import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_first/constants/constants.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/image_storage.dart';
import 'package:http/http.dart' as http;

class ItemService {
  static final ItemService _itemService = ItemService._internal();
  factory ItemService() => _itemService;
  ItemService._internal();

  // 문제 만들기
  Future createNewItem(Map<String, dynamic> json, String itemKey, String userKey) async {
    DocumentReference<Map<String, dynamic>> itemRef = FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemKey);
    DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);

    final DocumentSnapshot itemSnapshot = await itemRef.get();

    if (!itemSnapshot.exists) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(itemRef, json);
        transaction.update(userRef, {
          KEY_MYITEMS: FieldValue.arrayUnion([itemKey])
        });
      });
    }
  }

  // 문제 만들기 - json 파일 이용
  Future createNewItemsByJsonFile() async {
    var response = await http.get(Uri.parse('https://paengdal.github.io/json/quizData(20220914).json'));
    var responseByDecoding = jsonDecode(response.body);

    List<Map<String, dynamic>> jsonData = [];
    for (int i = 0; i < responseByDecoding.length; i++) {
      var temp = responseByDecoding[i];
      temp[KEY_ANSWER] = temp[KEY_ANSWER].toString();
      temp[KEY_IMAGEDOWNLOADURLS] = [];
      temp[KEY_SOLVEDUSERS] = [];
      temp[KEY_NUMOFCOMMENTS] = 0;
      temp[KEY_NUMOFLIKES] = [];
      temp[KEY_USERKEY] = ADMINUSERKEY;
      temp[KEY_USERNAME] = ADMINUSERNAME;
      if (temp[KEY_OPTIONS].isNotEmpty) {
        for (int i = 0; i < temp[KEY_OPTIONS].length; i++) {
          temp[KEY_OPTIONS][i] = temp[KEY_OPTIONS][i].toString();
        }
      }
      temp[KEY_CREATEDATE] = DateTime.now().toUtc();
      jsonData.add(temp);
    }
    for (int i = 0; i < jsonData.length; i++) {
      final userKey = FirebaseAuth.instance.currentUser!.uid;
      final itemKey = ItemModel.generateItemKey(userKey);
      DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(ADMINUSERKEY);
      DocumentReference<Map<String, dynamic>> itemRef = FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemKey);
      final DocumentSnapshot itemSnapshot = await itemRef.get();

      if (!itemSnapshot.exists) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(itemRef, jsonData[i]);
          transaction.update(userRef, {
            KEY_MYITEMS: FieldValue.arrayUnion([itemKey])
          });
        });
      }
    }
  }

  // 특정 문제만 가져오기
  Future<ItemModel> getItem(String itemKey) async {
    DocumentReference<Map<String, dynamic>> itemRef = FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemKey);
    final DocumentSnapshot<Map<String, dynamic>> itemSnapshot = await itemRef.get();
    ItemModel itemModel = ItemModel.fromSnapshot(itemSnapshot);
    return itemModel;
  }

  // 모든 문제 가져오기
  Future<List<ItemModel>> getAllItems() async {
    CollectionReference<Map<String, dynamic>> itemsRef = FirebaseFirestore.instance.collection(COL_ITEMS);
    QuerySnapshot<Map<String, dynamic>> itemsSnapshot = await itemsRef.get();

    List<ItemModel> items = [];

    for (int i = 0; i < itemsSnapshot.size; i++) {
      ItemModel itemModel = ItemModel.fromQuerySnapshot(itemsSnapshot.docs[i]);
      items.add(itemModel);
    }

    return items;
  }

  // 특정 몇개의 문제들 가져오기
  Future<List<ItemModel>> getSomeItemsByItemKeys(List<String> itemKeys) async {
    CollectionReference<Map<String, dynamic>> itemsRef = FirebaseFirestore.instance.collection(COL_ITEMS);
    QuerySnapshot<Map<String, dynamic>> itemsSnapshot = await itemsRef.get();

    List<ItemModel> items = [];

    for (int i = 0; i < itemsSnapshot.size; i++) {
      ItemModel itemModel = ItemModel.fromQuerySnapshot(itemsSnapshot.docs[i]);
      if (itemKeys.contains(itemModel.itemKey)) {
        items.add(itemModel);
      }
    }

    return items;
  }

  // 풀지 않은 문제만 가져오기
  Future<List<ItemModel>> getItemsUnsolved(String userKey) async {
    CollectionReference<Map<String, dynamic>> itemsRef = FirebaseFirestore.instance.collection(COL_ITEMS);
    DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();
    final QuerySnapshot<Map<String, dynamic>> itemsSnapshot = await itemsRef.get();

    UserModel userModel = UserModel.fromSnapshot(userSnapshot);
    var itemKeysOfSolvedItems = userModel.solvedItems;

    List<ItemModel> unsolvedItems = [];

    for (int i = 0; i < itemsSnapshot.size; i++) {
      if (!(itemKeysOfSolvedItems.contains(itemsSnapshot.docs[i].id))) {
        ItemModel itemModel = ItemModel.fromQuerySnapshot(itemsSnapshot.docs[i]);
        unsolvedItems.add(itemModel);
      }
    }

    return unsolvedItems;
  }

  // 푼 문제만 가져오기
  Future<List<ItemModel>> getItemsSolved(String userKey) async {
    CollectionReference<Map<String, dynamic>> itemsRef = FirebaseFirestore.instance.collection(COL_ITEMS);
    DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();
    final QuerySnapshot<Map<String, dynamic>> itemsSnapshot = await itemsRef.get();

    UserModel userModel = UserModel.fromSnapshot(userSnapshot);
    var itemKeysOfSolvedItems = userModel.solvedItems;

    List<ItemModel> solvedItems = [];

    for (int i = 0; i < itemsSnapshot.size; i++) {
      if ((itemKeysOfSolvedItems.contains(itemsSnapshot.docs[i].id))) {
        ItemModel itemModel = ItemModel.fromQuerySnapshot(itemsSnapshot.docs[i]);
        solvedItems.add(itemModel);
      }
    }

    return solvedItems;
  }

  // 내가 만든 문제만 제외하고 가져오기
  Future<List<ItemModel>> getItemsExceptMine(String userKey) async {
    CollectionReference<Map<String, dynamic>> itemsRef = FirebaseFirestore.instance.collection(COL_ITEMS);
    QuerySnapshot<Map<String, dynamic>> itemsSnapshot = await itemsRef.where(KEY_USERKEY, isNotEqualTo: userKey).get();

    List<ItemModel> items = [];

    for (int i = 0; i < itemsSnapshot.size; i++) {
      ItemModel itemModel = ItemModel.fromQuerySnapshot(itemsSnapshot.docs[i]);
      items.add(itemModel);
    }

    return items;
  }

  // 내가 만든 문제만 가져오기
  Future<List<ItemModel>> getMyItems(String userKey) async {
    CollectionReference<Map<String, dynamic>> itemsRef = FirebaseFirestore.instance.collection(COL_ITEMS);
    final QuerySnapshot<Map<String, dynamic>> itemsSnapshot = await itemsRef.get();

    List<ItemModel> myItems = [];
    for (int i = 0; i < itemsSnapshot.size; i++) {
      ItemModel itemModel = ItemModel.fromQuerySnapshot(itemsSnapshot.docs[i]);
      if (itemModel.userKey == userKey) {
        myItems.add(itemModel);
      }
    }

    return myItems;
  }

  // 좋아요 버튼
  Future<void> toggleLikeToItemData(String userKey, String itemKey) async {
    final DocumentReference itemRef = FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemKey);
    final DocumentSnapshot itemSnapshot = await itemRef.get();
    var itemSnapshotMap = itemSnapshot.data() as Map;
    List<dynamic> snapshotUserKeys = itemSnapshotMap[KEY_NUMOFLIKES];

    if (itemSnapshot.exists) {
      if (snapshotUserKeys.contains(userKey)) {
        itemRef.update({
          KEY_NUMOFLIKES: FieldValue.arrayRemove([userKey])
        });
      } else {
        itemRef.update({
          KEY_NUMOFLIKES: FieldValue.arrayUnion([userKey])
        });
      }
    }
  }

  // 정답을 선택한 경우
  void answerIsCorrect(List<ItemModel> itemModels, ItemModel itemModel, String userKey) async {
    // solvedItems에 해당 itemKey추가
    final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
    final DocumentSnapshot userSnapshot = await userRef.get();
    var MapOfUserDocSnapshot = userSnapshot.data() as Map;
    List<dynamic> itemKeysOfSolvedItems = MapOfUserDocSnapshot[KEY_SOLVEDITEMS];
    itemKeysOfSolvedItems.add(itemModel.itemKey);
    userRef.update({KEY_SOLVEDITEMS: itemKeysOfSolvedItems});

    // solvedUsers에 해당 userKey추가
    final DocumentReference itemRef = FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemModel.itemKey);
    final DocumentSnapshot itemSnapshot = await itemRef.get();
    var MapOfItemDocSnapshot = itemSnapshot.data() as Map;
    List<dynamic> userKeysOfSolvedUsers = MapOfItemDocSnapshot[KEY_SOLVEDUSERS];
    userKeysOfSolvedUsers.add(userKey);
    itemRef.update({KEY_SOLVEDUSERS: userKeysOfSolvedUsers});

    // 피드에서 해당 목록 삭제
    // itemModels.removeAt(index);
  }

  // 문제 삭제하기
  void deleteItem(List<ItemModel> itemModels, ItemModel itemModel, index, String userKey) async {
    if (itemModel.imageDownloadUrls.isNotEmpty) {
      // 이미지가 있는 경우에만 Storage 삭제 실행
      ImageStorage.deleteImages(itemModel.itemKey);

      // 해당 Item 삭제
      final DocumentReference itemRef = FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemModel.itemKey);
      itemRef.delete();

      // myItems에서 해당 itemKey삭제
      final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
      final DocumentSnapshot userSnapshot = await userRef.get();
      var userSnapshotMap = userSnapshot.data() as Map;
      List<dynamic> myItems = userSnapshotMap[KEY_MYITEMS];
      myItems.remove(itemModel.itemKey);
      userRef.update({KEY_MYITEMS: myItems});

      // likedItems에서도 해당 itemKey 삭제 필요. 단 모든 user의 likedItems를 불러와서 삭제해야할듯.
      // comments collection 삭제(collection은 삭제 불가, 나중에 다시 시도 예정 - 개별 comment들을 for문으로?)

      // 피드에서 해당 목록 삭제
      itemModels.removeAt(index);
    } else {
      final itemRef = FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemModel.itemKey);
      itemRef.delete();

      final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
      final DocumentSnapshot userSnapshot = await userRef.get();
      var userSnapshotMap = userSnapshot.data() as Map;
      List<dynamic> myItems = userSnapshotMap[KEY_MYITEMS];
      myItems.remove(itemModel.itemKey);
      userRef.update({KEY_MYITEMS: myItems});

      itemModels.removeAt(index);
    }

    // 댓글도 같이 지워야 완전히 삭제가 되는지?
    // 유저의 myitems리스트 지워야함
  }
}
