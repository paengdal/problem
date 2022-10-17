import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/controller/select_image_notifier.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/book_service.dart';
import 'package:quiz_first/repo/image_storage.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/view/screens/input/add_item.dart';
import 'package:quiz_first/view/screens/input_screen.dart';
import 'package:quiz_first/view/screens/input_screen_in_book.dart';
import 'package:quiz_first/view/widgets/multi_image_select.dart';

class InputBookScreen extends StatefulWidget {
  const InputBookScreen({Key? key}) : super(key: key);

  @override
  State<InputBookScreen> createState() => _InputBookScreenState();
}

class _InputBookScreenState extends State<InputBookScreen> {
  final List<String> _valueList = [MODE_NORMAL, MODE_TEST, MODE_TIMEATTACK];
  String _selectedValue = MODE_NORMAL;
  Map<String, String> text = {MODE_NORMAL: '기본', MODE_TEST: '시험', MODE_TIMEATTACK: '타임어택'};

  var _divider = Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey[400],
    indent: common_l_gap,
    endIndent: common_l_gap,
  );

  List<ItemModel> addedItems = [];
  List<String> addedItemKeys = [];

  void addItem(ItemModel itemModel) {
    if (addedItemKeys.contains(itemModel.itemKey)) {
      print('중복이다');
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          content: Text('이미 추가된 문제입니다.'),
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
      addedItems.add(itemModel);
      addedItemKeys.add(itemModel.itemKey);
      print('중복아니다');
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          content: Text('문제가 정상적으로 추가되었습니다.'),
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
    }
    setState(() {});
  }

  void deleteItem(ItemModel itemModel) {
    addedItems.remove(itemModel);
    addedItemKeys.remove(itemModel.itemKey);
    setState(() {});
  }

  bool isCreatingBook = false;

  TextEditingController _bookTitleController = TextEditingController();
  TextEditingController _bookDescController = TextEditingController();

  void attemptCreateBook() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    isCreatingBook = true;
    setState(() {});

    final String userKey = FirebaseAuth.instance.currentUser!.uid;
    final String email = FirebaseAuth.instance.currentUser!.email!;
    final emailId = email.split("@")[0];
    final String bookKey = BookModel.generateBookKey(userKey, _bookTitleController.text, emailId);
    List<Uint8List> images = context.read<SelectImageNotifier>().images;
    UserModel _userModel = await userNetworkRepository.getUserModel(userKey: userKey);
    final username = _userModel.username;
    List<String> downloadUrls = await ImageStorage.uploadImages(images, bookKey);

    BookModel bookModel = BookModel(
      userKey: userKey,
      username: username,
      bookKey: bookKey,
      imageDownloadUrls: downloadUrls,
      bookTitle: _bookTitleController.text,
      bookDesc: _bookDescController.text,
      bookTags: [],
      bookItems: addedItemKeys,
      bookUsers: [],
      numOfLikesBook: [],
      solvedUsersAndScore: [],
      numOfComments: 0,
      lastComment: '',
      lastCommentor: '',
      lastCommentTime: DateTime.now().toUtc(),
      createDate: DateTime.now().toUtc(),
      modeOfBook: _selectedValue,
    );

    await BookService().createNewBook(bookModel.toJson(), userKey, bookKey);

    Get.offAllNamed('/'); // 문제집 생성 시 리스트 갱신 효과를 주기 위해.(그런데 내정보의 MyBooks는 갱신되지 않음..)

    context.read<SelectImageNotifier>().images.clear(); // 이미지 피커 초기화
  }

  @override
  void dispose() {
    _bookDescController.dispose();
    _bookTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;
        return IgnorePointer(
          ignoring: isCreatingBook,
          child: Scaffold(
            appBar: AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              bottom: PreferredSize(
                  preferredSize: Size(_size.width, 2),
                  child: isCreatingBook
                      ? LinearProgressIndicator(
                          minHeight: 2,
                        )
                      : Container()),
              leading: TextButton(
                onPressed: () {
                  Get.back();
                  context.read<SelectImageNotifier>().images.clear();
                },
                child: Text(
                  '취소',
                ),
              ),
              title: Text(
                '문제집 만들기',
                style: TextStyle(color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_bookTitleController.text == "" && _bookDescController.text == "") {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('제목, 설명은 필수입력값입니다.'),
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
                    } else if (_bookTitleController.text == '') {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('제목은 필수입력값입니다.'),
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
                    } else if (_bookDescController.text == "") {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('설명은 필수입력값입니다.'),
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
                    } else if (addedItemKeys.isEmpty) {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('문제집에는 최소 1개 이상의 문제가 있어야 합니다. 문제가 없을 경우 문제부터 만들어 주세요.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.offNamed('/inputInBook');
                              },
                              child: Text('문제만들기'),
                            ),
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
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('한 번 발행된 문제집은 수정되지 않으며 삭제만 가능합니다. 발행하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                                attemptCreateBook();
                              },
                              child: Text('발행하기'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('취소'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text('완료'),
                ),
              ],
            ),
            body: ListView(
              children: [
                MultiImageSelect(),
                _divider,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          underline: SizedBox(),
                          // alignment: AlignmentDirectional.topCenter,
                          value: _selectedValue,
                          items: _valueList.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(text[value]!),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedValue = value!;
                            });
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Get.dialog(
                              barrierDismissible: false,
                              AlertDialog(
                                content: Container(
                                  height: 300,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '기본 모드',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'SDneoB',
                                          fontSize: 17,
                                        ),
                                      ),
                                      Text(
                                        '- 한 문제마다 정답을 확인하고 넘어가는 방식. 정답을 모를 경우 건너뛰기할 수 있으나 점수에는 포함되지 않음',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'SDneoR',
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        '시험 모드',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'SDneoB',
                                          fontSize: 17,
                                        ),
                                      ),
                                      Text(
                                        '- 모든 문제의 정답을 선택(혹은 입력)한 후 정답과 점수를 확인하는 방식',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'SDneoR',
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '- 풀다가 그만둘 경우 저장되지 않음',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'SDneoR',
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        '타임어택 모드',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'SDneoB',
                                          fontSize: 17,
                                        ),
                                      ),
                                      Text(
                                        '- 시험 모드와 동일한 방식이나 시간을 측정할 수 있음',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'SDneoR',
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '- 풀다가 그만둘 경우 저장되지 않음',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'SDneoR',
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                          },
                          icon: Icon(CupertinoIcons.question_circle, color: Colors.grey[400]))
                    ],
                  ),
                ),
                _divider,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                  child: Scrollbar(
                    thickness: 5,
                    radius: Radius.circular(5),
                    child: TextFormField(
                      controller: _bookTitleController,
                      scrollPadding: EdgeInsets.zero,
                      keyboardType: TextInputType.text,
                      // maxLines: 8,
                      decoration: InputDecoration(
                        // contentPadding: EdgeInsets.all(common_l_gap),
                        hintText: '문제집 제목',
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
                      controller: _bookDescController,
                      scrollPadding: EdgeInsets.zero,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      maxLength: 60,
                      inputFormatters: [LengthLimitingTextInputFormatter(60)],
                      decoration: InputDecoration(
                        // contentPadding: EdgeInsets.all(common_l_gap),
                        hintText: '문제집 설명',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                  ),
                ),
                _divider,
                ListTile(
                  onTap: () {
                    Get.to(() => AddItem(
                          addItem: addItem,
                        ));
                  },
                  dense: true,
                  title: addedItems.length == 0
                      ? Text(
                          '문제 추가하기',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        )
                      : Text(
                          '${addedItems.length}개의 문제 추가',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                  trailing: Icon(CupertinoIcons.chevron_forward),
                ),
                _divider,
                SizedBox(
                  height: 20,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: addedItems.length,
                    itemBuilder: ((context, index) {
                      ItemModel addedItem = addedItems[index];
                      return InkWell(
                        onTap: () {
                          deleteItem(addedItem);
                        },
                        child: Container(
                          // height: 120,
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(10),
                          //   shape: BoxShape.rectangle,
                          // ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: common_l_gap),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${addedItem.question}',
                                              style: TextStyle(fontSize: 18, fontFamily: 'SDneoR'),
                                            ),
                                            Text(
                                              '${categoriesMapEngToKor[addedItem.category]}',
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    (addedItem.imageDownloadUrls.isNotEmpty)
                                        ? ExtendedImage.network(
                                            addedItem.imageDownloadUrls[0],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : Stack(
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[200],
                                              ),
                                              Positioned(
                                                left: 13,
                                                top: 30,
                                                child: Text(
                                                  'no image',
                                                  style: TextStyle(color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                                Divider(
                                  thickness: 1,
                                  height: 27,
                                  indent: 0,
                                  endIndent: 90,
                                  color: Colors.grey[200],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })),
                Padding(
                  padding: const EdgeInsets.all(common_m_gap),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    // padding: EdgeInsets.all(10),
                    width: double.infinity,
                    // height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xfff8eae7),
                      borderRadius: BorderRadius.circular(common_s_gap),
                      shape: BoxShape.rectangle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(common_l_gap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '테스트 버전 안내',
                            style: TextStyle(
                              color: Color(0xffb43831),
                              fontFamily: 'SDneoB',
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '•태그, 카테고리, 이미지(?), 공개 범위 지정 또는 공개 사용자 선택 등 구현 필요',
                            style: TextStyle(
                              color: Color(0xffb43831),
                              fontFamily: 'SDneoR',
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Color(0xffb43831),
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
        );
      },
    );
  }
}
