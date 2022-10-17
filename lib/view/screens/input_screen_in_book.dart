import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/controller/select_image_notifier.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/image_storage.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/util/logger.dart';
import 'package:quiz_first/view/home_page.dart';
import 'package:quiz_first/view/screens/feed_screen.dart';
import 'package:quiz_first/view/screens/input/category_input_screen.dart';
import 'package:quiz_first/view/widgets/multi_image_select.dart';

class InputScreenInBook extends StatefulWidget {
  const InputScreenInBook({Key? key}) : super(key: key);

  @override
  State<InputScreenInBook> createState() => _InputScreenInBookState();
}

class _InputScreenInBookState extends State<InputScreenInBook> {
  var _divider = Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey[400],
    indent: common_l_gap,
    endIndent: common_l_gap,
  );

  bool isCreatingItem = false;

  TextEditingController _questionController = TextEditingController();
  TextEditingController _option01Controller = TextEditingController();
  TextEditingController _option02Controller = TextEditingController();
  TextEditingController _option03Controller = TextEditingController();
  TextEditingController _option04Controller = TextEditingController();
  TextEditingController _answerController = TextEditingController();
  TextEditingController _hintController = TextEditingController();

  void attemptCreateItem() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    isCreatingItem = true;
    setState(() {});

    final String userKey = FirebaseAuth.instance.currentUser!.uid;
    final userModel = await userNetworkRepository.getUserModel(userKey: userKey);
    final username = userModel.username;
    final String itemKey = ItemModel.generateItemKey(userKey);
    List<Uint8List> images = context.read<SelectImageNotifier>().images;
    List<String> downloadUrls = await ImageStorage.uploadImages(images, itemKey);
    logger.d('upload link $downloadUrls');
    ItemModel itemModel = ItemModel(
      itemKey: itemKey,
      userKey: userKey,
      username: username,
      imageDownloadUrls: downloadUrls,
      category: context.read<CategoryNotifier>().selectedCategoryInEng,
      question: _questionController.text,
      answer: _answerController.text,
      hint: _hintController.text,
      options: [_option01Controller.text, _option02Controller.text, _option03Controller.text, _option04Controller.text],
      numOfLikes: [],
      solvedUsers: [],
      numOfComments: 0,
      // lastComment: '',
      // lastCommentor: '',
      // lastCommentTime: DateTime.now().toUtc(),
      createDate: DateTime.now().toUtc(),
    );

    await ItemService().createNewItem(itemModel.toJson(), itemKey, userKey);

    Get.back(); // 아이템 생성 시 리스트 갱신 효과를 주기 위해.(그런데 내정보의 MyItems는 갱신되지 않음..)
    context.read<CategoryNotifier>().setNewCategoryWithEng('none'); // 카테고리 초기화
    context.read<SelectImageNotifier>().images.clear(); // 이미지 피커 초기화

    _sendPushMessage();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _option01Controller.dispose();
    _option02Controller.dispose();
    _option03Controller.dispose();
    _option04Controller.dispose();
    _answerController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;
        return IgnorePointer(
          ignoring: isCreatingItem,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              // systemOverlayStyle: SystemUiOverlayStyle(
              //   // statusBarColor: Colors.green, // <-- SEE HERE
              //   // statusBarIconBrightness:
              //   //     Brightness.dark, //<-- For Android SEE HERE (dark icons)
              //   statusBarBrightness: Brightness.dark,
              // ),
              elevation: 1,
              backgroundColor: Colors.white,
              bottom: PreferredSize(
                  preferredSize: Size(_size.width, 2),
                  child: isCreatingItem
                      ? LinearProgressIndicator(
                          minHeight: 2,
                        )
                      : Container()),
              leading: TextButton(
                onPressed: () {
                  Get.back();
                  context.read<CategoryNotifier>().setNewCategoryWithEng('none');
                  context.read<SelectImageNotifier>().images.clear();
                },
                child: Text(
                  '취소',
                ),
              ),
              title: Text(
                '문제 만들기',
                style: TextStyle(color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (context.read<CategoryNotifier>().SelectedCategoryInKor == '카테고리' && _questionController.text == "" && _answerController.text == "") {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('카테고리, 문제, 정답은 필수입력값입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } else if (context.read<CategoryNotifier>().SelectedCategoryInKor == '카테고리' && _questionController.text == "") {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('카테고리, 문제는 필수입력값입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } else if (context.read<CategoryNotifier>().SelectedCategoryInKor == '카테고리' && _answerController.text == "") {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('카테고리, 정답은 필수입력값입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } else if (_questionController.text == "" && _answerController.text == "") {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('문제, 정답은 필수입력값입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } else if (context.read<CategoryNotifier>().SelectedCategoryInKor == '카테고리') {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('카테고리는 필수입력값입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } else if (_questionController.text == "") {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('문제는 필수입력값입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } else if (_answerController.text == "") {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('정답은 필수입력값입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      attemptCreateItem();
                    }
                  },
                  child: Text('완료'),
                ),
              ],
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView(
                children: [
                  MultiImageSelect(),
                  _divider,
                  ListTile(
                    onTap: () {
                      Get.toNamed('/input/category');
                    },
                    dense: true,
                    title: Text(
                      context.watch<CategoryNotifier>().SelectedCategoryInKor,
                      style: TextStyle(fontSize: 16, fontFamily: (context.watch<CategoryNotifier>().SelectedCategoryInKor != categoriesMapEngToKor['none']) ? 'SDneoB' : 'SDneoL'),
                    ),
                    trailing: Icon(CupertinoIcons.chevron_forward),
                  ),
                  _divider,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                    child: Scrollbar(
                      thickness: 5,
                      radius: Radius.circular(5),
                      child: TextFormField(
                        controller: _questionController,
                        scrollPadding: EdgeInsets.zero,
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        decoration: InputDecoration(
                          // contentPadding: EdgeInsets.all(common_l_gap),
                          hintText: '문제 입력',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ),
                  ),
                  _divider,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                    child: Scrollbar(
                      thickness: 5,
                      radius: Radius.circular(5),
                      child: TextFormField(
                        controller: _option01Controller,
                        scrollPadding: EdgeInsets.zero,
                        keyboardType: TextInputType.text,
                        // maxLines: 8,
                        decoration: InputDecoration(
                          // contentPadding: EdgeInsets.all(common_l_gap),
                          hintText: '보기 1',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ),
                  ),
                  _divider,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                    child: Scrollbar(
                      thickness: 5,
                      radius: Radius.circular(5),
                      child: TextFormField(
                        controller: _option02Controller,
                        scrollPadding: EdgeInsets.zero,
                        keyboardType: TextInputType.text,
                        // maxLines: 8,
                        decoration: InputDecoration(
                          // contentPadding: EdgeInsets.all(common_l_gap),
                          hintText: '보기 2',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ),
                  ),
                  _divider,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                    child: Scrollbar(
                      thickness: 5,
                      radius: Radius.circular(5),
                      child: TextFormField(
                        controller: _option03Controller,
                        scrollPadding: EdgeInsets.zero,
                        keyboardType: TextInputType.text,
                        // maxLines: 8,
                        decoration: InputDecoration(
                          // contentPadding: EdgeInsets.all(common_l_gap),
                          hintText: '보기 3',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ),
                  ),
                  _divider,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                    child: Scrollbar(
                      thickness: 5,
                      radius: Radius.circular(5),
                      child: TextFormField(
                        controller: _option04Controller,
                        scrollPadding: EdgeInsets.zero,
                        keyboardType: TextInputType.text,
                        // maxLines: 8,
                        decoration: InputDecoration(
                          // contentPadding: EdgeInsets.all(common_l_gap),
                          hintText: '보기 4',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ),
                  ),
                  _divider,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                    child: Scrollbar(
                      thickness: 5,
                      radius: Radius.circular(5),
                      child: TextFormField(
                        controller: _answerController,
                        scrollPadding: EdgeInsets.zero,
                        keyboardType: TextInputType.text,
                        // maxLines: 8,
                        decoration: InputDecoration(
                          // contentPadding: EdgeInsets.all(common_l_gap),
                          hintText: '정답 입력',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(common_m_gap),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      // padding: EdgeInsets.all(10),
                      width: double.infinity,
                      // height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(common_s_gap),
                        shape: BoxShape.rectangle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(common_s_gap),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '★테스트 버전 안내',
                              style: TextStyle(
                                color: Colors.black45,
                                fontFamily: 'SDneoR',
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '  •보기를 입력하지 않으면 자동으로 주관식이 됩니다.',
                              style: TextStyle(
                                color: Colors.black45,
                                fontFamily: 'SDneoR',
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '  •',
                              style: TextStyle(
                                color: Colors.black45,
                                fontFamily: 'SDneoR',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendPushMessage() async {
    try {
      var userModel = await userNetworkRepository.getUserModel(userKey: FirebaseAuth.instance.currentUser!.uid);
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAGWbrGMU:APA91bFCps7ojiWeqIjZG8VBXAlX3xBL5RA7Zemve00GpYHCq98d5N2Yniixuq-QRcLELF1Qb8D5pvOvUf-OolcMeLTAHx9wjjfZULIFNWXdncs5wfEsAQOd5cnAnHIM1YMl87MLV5Cx',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'id': '1', 'status': 'done', 'argument': 'push data send testing!!'},
            'notification': {
              'title': '새로운 문제의 등장',
              'body': '${userModel.username}님이 문제를 만들었습니다. 문제는 풀어야맛이죠?',
            },

            // 'to': "/topics/Test",
            // aa@aa.aa
            // 'to':
            //     'd3t60LmZTzuPBzPpPm5SA4:APA91bHmv-AGeFpzhAwbJ0d1IzO3ZhjlDo2_2cMJgfr-x6MONDTSzS9TMOhUrOVxs_pztAMnAZC1Fm9kPf5JJ12QUSuniWaMbzmk-GW4NXiItpIpt7yD_ly0hrKHXMaChJGcgTP6itDd',
            // qq@qq.qq
            // 'to':
            //     'c3M8tmsg7k4hvVWKrveiJG:APA91bE7YQD74RLAfGvY8UGjsmC-gRp6zLF0UiK6m9NW6lj1WDUqppRTbHg8YDvssmKxf2hkgvyNtv8zIunAGuyuatZxOjAqfdTDeODteas1iwRUs4wvU9egtf8Nisp01dqlnranEv1V',

            //모두에게
            'registration_ids': await userNetworkRepository.getUsersTokensExceptMe(FirebaseAuth.instance.currentUser!.uid),
          },
        ),
      );
    } catch (e) {
      print('error push');
    }
  }
}
