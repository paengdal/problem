import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/constants/input_deco.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/controller/progress_bar_controller.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/book_service.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/view/screens/feed/book_result_screen.dart';
import 'package:quiz_first/view/widgets/options.dart';

class BookDetailScreen extends StatelessWidget {
  BookDetailScreen({Key? key}) : super(key: key);

  dynamic argumentData = Get.arguments;

  final String bookKey = Get.parameters['bookKey']!;
  final sizedBoxH = SizedBox(
    height: 10,
  );

  // 풀던 문제번호(페이지) 저장을 위한 변수
  int _solvingPage = 0;

  List<List<String>> _selectedOptionsSet = [];
  List<List<String>> _answerOptionsSet = [];

  // String _selectedOption = '';

  @override
  Widget build(BuildContext context) {
    BookModel bookModel = argumentData[0];
    int _pageNum = argumentData[1];
    int _score = argumentData[2];
    String _solvingStatus = argumentData[3];
    PageController _pageController = PageController(initialPage: _pageNum);
    final progressBarController = Get.put(ProgressBarController());
    final itemKeys = bookModel.bookItems;

    // 사용자가 선택한 답 리스트 생성
    _selectedOptionsSet = List.generate(itemKeys.length, (index) => []);

    print('_selectedOptionsSet: $_selectedOptionsSet');

    // 사용자가 option을 선택할 때 '선택한 정답 목록'에 해당 option을 추가 또는 갱신
    void getSelectedOptionsSet(selectedOptionsSet) {
      _selectedOptionsSet = selectedOptionsSet;
      print('_selectedOptionsSet: $_selectedOptionsSet');
    }

    // 다음 문제 또는 완료 버튼을 누를 때 '선택한 정답 목록'에 해당 주관식 답을 추가 또는 갱신
    void addShortAnswerToSet(String shortAnswer, index) {
      List<String> a = [];
      a.add(shortAnswer);
      _selectedOptionsSet[index] = a;
      print(_selectedOptionsSet);
    }

    // 점수 계산
    List<int> _indexOfCorrect = [];
    List<int> _indexOfUnCorrect = [];
    void giveScroe(List<List<String>> answersOptionsSet, List<List<String>> selectedOptionsSet) {
      for (int i = 0; i < itemKeys.length; i++) {
        var answer = answersOptionsSet[i];
        var select = selectedOptionsSet[i];

        if (answer[0] == select[0]) {
          _indexOfCorrect.add(i);
        } else {
          _indexOfUnCorrect.add(i);
        }
      }
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              // toolbarHeight: 100,
              centerTitle: true,
              titleSpacing: 0,
              leadingWidth: 50,
              leading: IconButton(
                icon: Icon(
                  // CupertinoIcons.arrow_left,
                  CupertinoIcons.multiply,
                ),
                // constraints: BoxConstraints(),
                iconSize: 22,
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  if (bookModel.modeOfBook == 'normal') {
                    await BookService().saveSolvingPage(bookKey, FirebaseAuth.instance.currentUser!.uid, _solvingPage, _score, _solvingStatus);
                    Get.offAllNamed('/');
                    // Get.dialog(
                    //   barrierDismissible: false,
                    //   AlertDialog(
                    //     insetPadding: EdgeInsets.all(20),
                    //     content: Column(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         SizedBox(
                    //           width: _size.width,
                    //           child: Text('문제집 풀이를 중단하시겠습니까?'),
                    //         ),
                    //         SizedBox(
                    //           height: 50,
                    //         ),
                    //         SizedBox(
                    //           width: _size.width,
                    //           child: ElevatedButton(
                    //             style: ElevatedButton.styleFrom(
                    //               primary: Color(0xfff4f7fe),
                    //               elevation: 0,
                    //               side: BorderSide(
                    //                 width: 1.0,
                    //                 color: Color(0xff1a68ff),
                    //               ),
                    //               padding: const EdgeInsets.symmetric(vertical: 10),
                    //             ),
                    //             onPressed: () async {
                    //               Get.back();
                    //               await BookService().saveSolvingPage(bookKey, FirebaseAuth.instance.currentUser!.uid, _solvingPage, _score, _solvingStatus);
                    //               Get.offAllNamed('/');
                    //             },
                    //             child: Text(
                    //               '번호 저장 후 중단',
                    //               style: TextStyle(color: Color(0xff1a68ff)),
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           width: _size.width,
                    //           child: ElevatedButton(
                    //             style: ElevatedButton.styleFrom(
                    //               primary: Colors.red[50],
                    //               elevation: 0,
                    //               side: BorderSide(
                    //                 width: 1.0,
                    //                 color: Colors.red,
                    //               ),
                    //               padding: const EdgeInsets.symmetric(vertical: 10),
                    //             ),
                    //             child: Text(
                    //               '번호 저장하지 않고 중단',
                    //               style: TextStyle(color: Colors.red),
                    //             ),
                    //             onPressed: () async {
                    //               Get.back();
                    //               Get.offAllNamed('/');
                    //             },
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           width: _size.width,
                    //           child: ElevatedButton(
                    //             style: ElevatedButton.styleFrom(
                    //               primary: Colors.white,
                    //               elevation: 0,
                    //               side: BorderSide(
                    //                 width: 1.0,
                    //                 color: Color(0xff1a68ff),
                    //               ),
                    //               padding: const EdgeInsets.symmetric(vertical: 10),
                    //             ),
                    //             child: Text(
                    //               '취소',
                    //               style: TextStyle(color: Color(0xff1a68ff)),
                    //             ),
                    //             onPressed: () {
                    //               Get.back();
                    //             },
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // );
                  } else {
                    Get.dialog(
                      barrierDismissible: false,
                      AlertDialog(
                        content: Text('저장이 불가능한 모드입니다. 풀이를 중단할 경우 처음부터 다시 풀어야 합니다. 중단하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                              Get.offAllNamed('/');
                            },
                            child: Text(
                              '중단하기',
                              style: TextStyle(color: Colors.red),
                            ),
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
              ),
              // title: Column(
              //   children: [
              //     Text('${bookModel.bookTitle}'),
              //     Obx(() => Text(
              //         '${progressBarController.currentPage.value}/${itemKeys.length}')),
              //   ],
              // ),
              title: Text('${bookModel.bookTitle}'),
              bottom: PreferredSize(
                preferredSize: Size(10, 4),
                child: itemKeys.length > 1
                    ? Stack(
                        children: [
                          Container(
                            color: Colors.grey[200],
                            height: 4,
                          ),
                          Obx(
                            () => Container(
                              color: Colors.pinkAccent,
                              width: _size.width / itemKeys.length * (progressBarController.currentPage.value),
                              height: 4,
                            ),
                          )
                        ],
                      )
                    : Container(),
              ),
            ),
            body: FutureBuilder<List<ItemModel>>(
                future: ItemService().getSomeItemsByItemKeys(itemKeys),
                builder: (context, snapshot) {
                  // future 데이터가 있는지 체크
                  if (snapshot.hasData && snapshot.data!.isNotEmpty)
                  // future 데이터가 있으면
                  {
                    List<ItemModel> bookItems = snapshot.data!;

                    // 문제집의 정답 리스트 생성
                    for (int i = 0; i < itemKeys.length; i++) {
                      List<String> answerOptions = [];
                      answerOptions.add(bookItems[i].answer);
                      _answerOptionsSet.add(answerOptions);
                    }

                    return PageView.builder(
                        onPageChanged: (value) {},
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: bookItems.length,
                        itemBuilder: (context, index) {
                          _solvingPage = index;
                          TextEditingController _answerController = TextEditingController(
                              // 입력된 답이 있을 경우 이전 문제로 돌아올때 그 답을 보여주기 위한 코드
                              text: _selectedOptionsSet[index] != null && _selectedOptionsSet[index].isNotEmpty ? '${_selectedOptionsSet[index][0]}' : '');
                          // 커서 위치를 입력된 텍스트의 끝으로 지정해주기 위한 코드(없으면 항상 가장 앞으로 오게 됨)
                          if (_selectedOptionsSet[index].isNotEmpty) {
                            _answerController..selection = TextSelection.fromPosition(TextPosition(offset: _selectedOptionsSet[index][0].length));
                          }

                          ItemModel bookItem = bookItems[index];

                          return SafeArea(
                            child: CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: 20,
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  // 문제
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                                    child: Text(
                                      '${itemKeys.length}-${index + 1}. ${bookItem.question}',
                                      style: TextStyle(
                                        fontFamily: 'SDneoSB',
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: 20,
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  // 이미지가 있으면 보여주기
                                  child: Padding(
                                    // padding: const EdgeInsets.symmetric(
                                    //     horizontal: common_s_gap),
                                    padding: const EdgeInsets.all(0),
                                    child: bookItem.imageDownloadUrls.isNotEmpty
                                        ? Column(
                                            children: [
                                              ExtendedImage.network(bookItem.imageDownloadUrls[0]),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: 10,
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  // 객관식 보기 선택 및 주관식 정답 입력
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                                    child: bookItem.options[0].isNotEmpty
                                        ? Options(
                                            itemModel: bookItem,
                                            sizedBoxH: sizedBoxH,
                                            getSelectedOptionsSet: getSelectedOptionsSet,
                                            itemIndex: index,
                                            selectedOptionsSet: _selectedOptionsSet,
                                          )
                                        : TextField(
                                            controller: _answerController,
                                            decoration: textInputDecoShortAnswer('정답 입력'),
                                            onChanged: (value) {
                                              addShortAnswerToSet(value.trim(), index);
                                            },
                                          ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: 10,
                                  ),
                                ),
                                bookModel.modeOfBook == MODE_TEST
                                    // TEST(시험)모드일때의 하단 버튼들
                                    ? SliverFillRemaining(
                                        hasScrollBody: false,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 110,
                                            child: ListView(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              children: [
                                                // 다음 문제 또는 완료 버튼
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                                                  child: index != itemKeys.length - 1
                                                      // 마지막 문제가 아니면(다음 문제 버튼)
                                                      ? ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Color(0xff1a68ff),
                                                            elevation: 0,
                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                          ),
                                                          onPressed: () {
                                                            FocusManager.instance.primaryFocus?.unfocus(); // textfield의 focus를 없애는 코드
                                                            // 객관식인지 체크
                                                            if (bookItem.options[0].isNotEmpty)

                                                            // 객관식이면
                                                            {
                                                              // 답을 입력했는지 체크
                                                              if (_selectedOptionsSet[index].isNotEmpty)
                                                              // 답을 입력했으면
                                                              {
                                                                progressBarController.increment();
                                                                _pageController.animateToPage(
                                                                  index + 1,
                                                                  duration: Duration(milliseconds: 300),
                                                                  curve: Curves.easeInOut,
                                                                );
                                                              }
                                                              // 답을 입력 안 했으면
                                                              else {
                                                                Get.dialog(
                                                                  barrierDismissible: false,
                                                                  AlertDialog(
                                                                    content: Text('반드시 정답을 입력해야 다음 문제로 넘어갈 수 있습니다. 정답은 다시 수정이 가능합니다.'),
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
                                                            }
                                                            // 주관식이면
                                                            else {
                                                              // 답을 입력했는지 체크
                                                              if (_answerController.text != '')
                                                              // 답을 입력했으면
                                                              {
                                                                addShortAnswerToSet(_answerController.text.trim(), index);
                                                                progressBarController.increment();
                                                                _pageController.animateToPage(
                                                                  index + 1,
                                                                  duration: Duration(milliseconds: 300),
                                                                  curve: Curves.easeInOut,
                                                                );
                                                              }
                                                              // 답을 입력 안 했으면
                                                              else {
                                                                Get.dialog(
                                                                  barrierDismissible: false,
                                                                  AlertDialog(
                                                                    content: Text('반드시 정답을 입력해야 다음 문제로 넘어갈 수 있습니다. 정답은 다시 수정이 가능합니다.'),
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
                                                            }
                                                          },
                                                          child: Text('다음 문제'),
                                                        )
                                                      // 마지막 문제이면(완료 버튼)
                                                      : ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Colors.black,
                                                            elevation: 0,
                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                          ),
                                                          onPressed: () async {
                                                            UserModel userModel = await userNetworkRepository.getUserModel(userKey: FirebaseAuth.instance.currentUser!.uid);
                                                            // 객관식인지 체크
                                                            if (bookItem.options[0].isNotEmpty)
                                                            // 객관식이면
                                                            {
                                                              // 답을 입력했는지 체크
                                                              if (_selectedOptionsSet[index].isNotEmpty)
                                                              // 답을 입력했으면
                                                              {
                                                                giveScroe(_answerOptionsSet, _selectedOptionsSet);
                                                                print(_indexOfCorrect);

                                                                await BookService().doneSolvingBook(
                                                                    bookKey, FirebaseAuth.instance.currentUser!.uid, bookModel.userKey, (_indexOfCorrect.length / itemKeys.length * 100).round());
                                                                Get.to(
                                                                    () => BookResultScreen(
                                                                          itemKeys: itemKeys,
                                                                          indexOfCorrect: _indexOfCorrect,
                                                                          indexOfUnCorrect: _indexOfUnCorrect,
                                                                          bookItems: bookItems,
                                                                          bookModel: bookModel,
                                                                        ),
                                                                    fullscreenDialog: true);
                                                              }
                                                              // 답을 입력 안 했으면
                                                              else {
                                                                Get.dialog(
                                                                  barrierDismissible: false,
                                                                  AlertDialog(
                                                                    content: Text('반드시 정답을 입력해야 합니다.'),
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
                                                            }
                                                            // 주관식이면
                                                            else {
                                                              // 답을 입력했는지 체크
                                                              if (_answerController.text != '')
                                                              // 답을 입력했으면
                                                              {
                                                                addShortAnswerToSet(_answerController.text.trim(), index);
                                                                giveScroe(_answerOptionsSet, _selectedOptionsSet);

                                                                await BookService().doneSolvingBook(
                                                                    bookKey, FirebaseAuth.instance.currentUser!.uid, bookModel.userKey, (_indexOfCorrect.length / itemKeys.length * 100).round());

                                                                _answerController.clear();
                                                                Get.to(
                                                                    () => BookResultScreen(
                                                                          itemKeys: itemKeys,
                                                                          indexOfCorrect: _indexOfCorrect,
                                                                          indexOfUnCorrect: _indexOfUnCorrect,
                                                                          bookItems: bookItems,
                                                                          bookModel: bookModel,
                                                                        ),
                                                                    fullscreenDialog: true);
                                                              }
                                                              // 답을 입력 안 했으면
                                                              else {
                                                                Get.dialog(
                                                                  barrierDismissible: false,
                                                                  AlertDialog(
                                                                    content: Text('반드시 정답을 입력해야 합니다.'),
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
                                                            }
                                                          },
                                                          child: Text('완료'),
                                                        ),
                                                ),
                                                // 이전 문제 버튼
                                                // 처음 문제인지 체크
                                                index != 0
                                                    // 처음 문제가 아니면
                                                    ? Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Colors.white,
                                                            elevation: 0,
                                                            side: BorderSide(
                                                              width: 1.0,
                                                              color: Color(0xff1a68ff),
                                                            ),
                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                          ),
                                                          onPressed: () {
                                                            progressBarController.decrement();
                                                            _pageController.animateToPage(
                                                              index - 1,
                                                              duration: Duration(milliseconds: 300),
                                                              curve: Curves.easeInOut,
                                                            );
                                                          },
                                                          child: Text(
                                                            '이전 문제',
                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                          ),
                                                        ),
                                                      )
                                                    // 처음 문제이면
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    // TEST(시험)모드가 아닐때의 하단 버튼들
                                    : SliverFillRemaining(
                                        hasScrollBody: false,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 110,
                                            child: ListView(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              children: [
                                                // 정답 확인 버튼
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Color(0xff1a68ff),
                                                      elevation: 0,
                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                    ),
                                                    child: Text('정답 확인'),
                                                    onPressed: () async {
                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                      UserModel userModel = await userNetworkRepository.getUserModel(userKey: FirebaseAuth.instance.currentUser!.uid);
                                                      // 객관식인지 체크
                                                      if (bookItem.options[0].isNotEmpty)
                                                      // 객관식이면
                                                      {
                                                        // 답을 입력했는지 체크
                                                        if (_selectedOptionsSet[index].isNotEmpty)
                                                        // 답을 입력했으면
                                                        {
                                                          // 입력한 답이 정답인지 체크
                                                          if (_selectedOptionsSet[index][0] == bookItem.answer)
                                                          // 정답이면
                                                          {
                                                            // 이미 푼 문제인지 체크
                                                            if (!_indexOfCorrect.contains(index) && !_indexOfUnCorrect.contains(index)) _indexOfCorrect.add(index);

                                                            print('_indexOfCorrect:$_indexOfCorrect');
                                                            // 마지막 문제인지 체크
                                                            if (index != itemKeys.length - 1)
                                                            // 마지막 문제가 아니면
                                                            {
                                                              Get.dialog(
                                                                barrierDismissible: false,
                                                                AlertDialog(
                                                                  insetPadding: EdgeInsets.all(20),
                                                                  content: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: ExtendedImage.asset(
                                                                          'assets/imgs/clapping-3.png',
                                                                          // 'assets/imgs/confetti.png',
                                                                          // 'assets/imgs/fireworks.png',
                                                                          width: 160,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: Text(
                                                                          '정답입니다!',
                                                                          style: TextStyle(fontFamily: 'SDneoB', fontSize: 26, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 40,
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Color(0xff1a68ff),
                                                                            elevation: 0,
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          onPressed: () async {
                                                                            Get.back();
                                                                            progressBarController.increment();
                                                                            _pageController.animateToPage(
                                                                              index + 1,
                                                                              duration: Duration(milliseconds: 300),
                                                                              curve: Curves.easeInOut,
                                                                            );
                                                                          },
                                                                          child: Text(
                                                                            '다음 문제로 이동',
                                                                            style: TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Color(0xfff4f7fe),
                                                                            elevation: 0,
                                                                            side: BorderSide(
                                                                              width: 1.0,
                                                                              color: Color(0xff1a68ff),
                                                                            ),
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          child: Text(
                                                                            '친구와 함께 풀기',
                                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                                          ),
                                                                          onPressed: () async {
                                                                            Get.back();
                                                                          },
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Colors.white,
                                                                            elevation: 0,
                                                                            side: BorderSide(
                                                                              width: 1.0,
                                                                              color: Color(0xff1a68ff),
                                                                            ),
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          child: Text(
                                                                            '문제 평가하기',
                                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                                          ),
                                                                          onPressed: () {
                                                                            Get.back();
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            // 마지막 문제이면
                                                            else {
                                                              await BookService().doneSolvingBook(
                                                                  bookKey, FirebaseAuth.instance.currentUser!.uid, bookModel.userKey, (_indexOfCorrect.length / itemKeys.length * 100).round());
                                                              // Get.dialog(
                                                              //   barrierDismissible: false,
                                                              //   AlertDialog(
                                                              //     content: Column(
                                                              //       children: [
                                                              //         Text('정답입니다!'),
                                                              //         Text(
                                                              //             // '모든 문제를 풀었습니다. 점수는 ${(_indexOfCorrect.length / itemKeys.length * 100).round()}점입니다. 홈으로 이동합니다.'),
                                                              //             // '모든 문제를 풀었습니다. ${itemKeys.length}문제 중 ${_indexOfCorrect.length}개를 맞혔습니다. 홈으로 이동합니다.'),
                                                              //             '모든 문제를 풀었습니다. 홈으로 이동합니다.'),
                                                              //       ],
                                                              //     ), // 문제를 풀다가 중단할 경우, 앞에 풀었던 문제에 대해서는 정답여부를 체크할 수가 없어서 맞힌 개수 표시를 일단 없앰.
                                                              //     actions: [
                                                              //       TextButton(
                                                              //         onPressed: () {
                                                              //           Get.back();
                                                              //           Get.offAllNamed('/');
                                                              //         },
                                                              //         child: Text('확인'),
                                                              //       ),
                                                              //     ],
                                                              //   ),
                                                              // );
                                                              Get.dialog(
                                                                barrierDismissible: false,
                                                                AlertDialog(
                                                                  insetPadding: EdgeInsets.all(20),
                                                                  content: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: ExtendedImage.asset(
                                                                          'assets/imgs/clapping-3.png',
                                                                          // 'assets/imgs/confetti.png',
                                                                          // 'assets/imgs/fireworks.png',
                                                                          width: 160,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: Text(
                                                                          '정답입니다!',
                                                                          style: TextStyle(fontFamily: 'SDneoB', fontSize: 26, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: Text(
                                                                          '모든 문제를 풀었습니다. 홈으로 이동합니다.',
                                                                          style: TextStyle(fontFamily: 'SDneoM', fontSize: 16, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 30,
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Color(0xfff4f7fe),
                                                                            elevation: 0,
                                                                            side: BorderSide(
                                                                              width: 1.0,
                                                                              color: Color(0xff1a68ff),
                                                                            ),
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          onPressed: () async {
                                                                            Get.back();
                                                                            Get.offAllNamed('/');
                                                                          },
                                                                          child: Text(
                                                                            '홈으로 이동',
                                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Colors.white,
                                                                            elevation: 0,
                                                                            side: BorderSide(
                                                                              width: 1.0,
                                                                              color: Color(0xff1a68ff),
                                                                            ),
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          child: Text(
                                                                            '문제집 평가하기',
                                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                                          ),
                                                                          onPressed: () async {
                                                                            Get.back();
                                                                          },
                                                                        ),
                                                                      ),
                                                                      // SizedBox(
                                                                      //   width: _size.width,
                                                                      //   child: ElevatedButton(
                                                                      //     style: ElevatedButton.styleFrom(
                                                                      //       primary: Colors.transparent,
                                                                      //       elevation: 0,
                                                                      //       side: BorderSide(
                                                                      //         width: 1.0,
                                                                      //         color: Colors.teal,
                                                                      //       ),
                                                                      //       padding: const EdgeInsets.symmetric(vertical: 10),
                                                                      //     ),
                                                                      //     child: Text(
                                                                      //       '광고보기??',
                                                                      //       style: TextStyle(color: Colors.teal),
                                                                      //     ),
                                                                      //     onPressed: () {
                                                                      //       Get.back();
                                                                      //     },
                                                                      //   ),
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                          // 오답이면
                                                          else {
                                                            // 이미 푼 문제인지 체크
                                                            if (!_indexOfCorrect.contains(index) && !_indexOfUnCorrect.contains(index)) _indexOfUnCorrect.add(index);

                                                            print('_indexOfUnCorrect:$_indexOfUnCorrect');
                                                            Get.dialog(
                                                              barrierDismissible: false,
                                                              AlertDialog(
                                                                insetPadding: EdgeInsets.all(20),
                                                                content: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    SizedBox(
                                                                      // width: _size.width,
                                                                      child: ExtendedImage.asset(
                                                                        'assets/imgs/cry.png',
                                                                        width: 160,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    SizedBox(
                                                                      // width: _size.width,
                                                                      child: Text(
                                                                        '오답입니다!',
                                                                        style: TextStyle(fontFamily: 'SDneoB', fontSize: 26, color: Colors.red[200]),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 40,
                                                                    ),
                                                                    SizedBox(
                                                                      width: _size.width,
                                                                      child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          primary: Color(0xfff4f7fe),
                                                                          elevation: 0,
                                                                          side: BorderSide(
                                                                            width: 1.0,
                                                                            color: Color(0xff1a68ff),
                                                                          ),
                                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                                        ),
                                                                        child: Text(
                                                                          '다시 풀기',
                                                                          style: TextStyle(color: Color(0xff1a68ff)),
                                                                        ),
                                                                        onPressed: () async {
                                                                          Get.back();
                                                                        },
                                                                      ),
                                                                    ),
                                                                    // SizedBox(
                                                                    //   width: _size.width,
                                                                    //   child: ElevatedButton(
                                                                    //     style: ElevatedButton.styleFrom(
                                                                    //       primary: Colors.white,
                                                                    //       elevation: 0,
                                                                    //       side: BorderSide(
                                                                    //         width: 1.0,
                                                                    //         color: Color(0xff1a68ff),
                                                                    //       ),
                                                                    //       padding: const EdgeInsets.symmetric(vertical: 10),
                                                                    //     ),
                                                                    //     child: Text(
                                                                    //       '힌트 보기',
                                                                    //       style: TextStyle(color: Color(0xff1a68ff)),
                                                                    //     ),
                                                                    //     onPressed: () {
                                                                    //       Get.back();
                                                                    //     },
                                                                    //   ),
                                                                    // ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                        // 답을 입력 안 했으면
                                                        else {
                                                          Get.dialog(
                                                            barrierDismissible: false,
                                                            AlertDialog(
                                                              content: Text('정답을 입력해주세요.'),
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
                                                      }
                                                      // 주관식이면
                                                      else {
                                                        // 답을 입력했는지 체크
                                                        if (_answerController.text != '')
                                                        // 답을 입력했으면
                                                        {
                                                          // 입력한 답이 정답인지 체크
                                                          if (_answerController.text.trim() == bookItem.answer)
                                                          // 정답이면
                                                          {
                                                            // 이미 푼 문제인지 체크
                                                            if (!_indexOfCorrect.contains(index) && !_indexOfUnCorrect.contains(index)) _indexOfCorrect.add(index);
                                                            print('_indexOfCorrect:$_indexOfCorrect');
                                                            // 마지막 문제인지 체크
                                                            if (index != itemKeys.length - 1)
                                                            // 마지막 문제가 아니면
                                                            {
                                                              Get.dialog(
                                                                barrierDismissible: false,
                                                                AlertDialog(
                                                                  insetPadding: EdgeInsets.all(20),
                                                                  content: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: ExtendedImage.asset(
                                                                          'assets/imgs/clapping-3.png',
                                                                          // 'assets/imgs/confetti.png',
                                                                          // 'assets/imgs/fireworks.png',
                                                                          width: 160,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: Text(
                                                                          '정답입니다!',
                                                                          style: TextStyle(fontFamily: 'SDneoB', fontSize: 26, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 40,
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Color(0xff1a68ff),
                                                                            elevation: 0,
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          onPressed: () async {
                                                                            Get.back();
                                                                            addShortAnswerToSet(_answerController.text.trim(), index);
                                                                            progressBarController.increment();
                                                                            _pageController.animateToPage(
                                                                              index + 1,
                                                                              duration: Duration(milliseconds: 300),
                                                                              curve: Curves.easeInOut,
                                                                            );
                                                                          },
                                                                          child: Text(
                                                                            '다음 문제로 이동',
                                                                            style: TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Color(0xfff4f7fe),
                                                                            elevation: 0,
                                                                            side: BorderSide(
                                                                              width: 1.0,
                                                                              color: Color(0xff1a68ff),
                                                                            ),
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          child: Text(
                                                                            '친구와 함께 풀기',
                                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                                          ),
                                                                          onPressed: () async {
                                                                            Get.back();
                                                                          },
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Colors.white,
                                                                            elevation: 0,
                                                                            side: BorderSide(
                                                                              width: 1.0,
                                                                              color: Color(0xff1a68ff),
                                                                            ),
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          child: Text(
                                                                            '문제 평가하기',
                                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                                          ),
                                                                          onPressed: () {
                                                                            Get.back();
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            // 마지막 문제이면
                                                            else {
                                                              await BookService().doneSolvingBook(
                                                                  bookKey, FirebaseAuth.instance.currentUser!.uid, bookModel.userKey, (_indexOfCorrect.length / itemKeys.length * 100).round());
                                                              // Get.dialog(
                                                              //   barrierDismissible: false,
                                                              //   AlertDialog(
                                                              //     content: Column(
                                                              //       children: [
                                                              //         Text('정답입니다!'),
                                                              //         Text(
                                                              //             // '모든 문제를 풀었습니다. 점수는 ${(_indexOfCorrect.length / itemKeys.length * 100).round()}점입니다. 홈으로 이동합니다.'),
                                                              //             // '모든 문제를 풀었습니다. ${itemKeys.length}문제 중 ${_indexOfCorrect.length}개를 맞혔습니다. 홈으로 이동합니다.'),
                                                              //             '모든 문제를 풀었습니다. 홈으로 이동합니다.'),
                                                              //       ],
                                                              //     ), // 문제를 풀다가 중단할 경우, 앞에 풀었던 문제에 대해서는 정답여부를 체크할 수가 없어서 맞힌 개수 표시를 일단 없앰.
                                                              //     actions: [
                                                              //       TextButton(
                                                              //         onPressed: () {
                                                              //           Get.back();
                                                              //           Get.offAllNamed('/');
                                                              //         },
                                                              //         child: Text('확인'),
                                                              //       ),
                                                              //     ],
                                                              //   ),
                                                              // );
                                                              Get.dialog(
                                                                barrierDismissible: false,
                                                                AlertDialog(
                                                                  insetPadding: EdgeInsets.all(20),
                                                                  content: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: ExtendedImage.asset(
                                                                          'assets/imgs/clapping-3.png',
                                                                          // 'assets/imgs/confetti.png',
                                                                          // 'assets/imgs/fireworks.png',
                                                                          width: 160,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: Text(
                                                                          '정답입니다!',
                                                                          style: TextStyle(fontFamily: 'SDneoB', fontSize: 26, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        // width: _size.width,
                                                                        child: Text(
                                                                          '모든 문제를 풀었습니다. 홈으로 이동합니다.',
                                                                          style: TextStyle(fontFamily: 'SDneoM', fontSize: 16, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 30,
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Color(0xfff4f7fe),
                                                                            elevation: 0,
                                                                            side: BorderSide(
                                                                              width: 1.0,
                                                                              color: Color(0xff1a68ff),
                                                                            ),
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          onPressed: () async {
                                                                            Get.back();
                                                                            Get.offAllNamed('/');
                                                                          },
                                                                          child: Text(
                                                                            '홈으로 이동',
                                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _size.width,
                                                                        child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            primary: Colors.white,
                                                                            elevation: 0,
                                                                            side: BorderSide(
                                                                              width: 1.0,
                                                                              color: Color(0xff1a68ff),
                                                                            ),
                                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                                          ),
                                                                          child: Text(
                                                                            '문제집 평가하기',
                                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                                          ),
                                                                          onPressed: () async {
                                                                            Get.back();
                                                                          },
                                                                        ),
                                                                      ),
                                                                      // SizedBox(
                                                                      //   width: _size.width,
                                                                      //   child: ElevatedButton(
                                                                      //     style: ElevatedButton.styleFrom(
                                                                      //       primary: Colors.transparent,
                                                                      //       elevation: 0,
                                                                      //       side: BorderSide(
                                                                      //         width: 1.0,
                                                                      //         color: Colors.teal,
                                                                      //       ),
                                                                      //       padding: const EdgeInsets.symmetric(vertical: 10),
                                                                      //     ),
                                                                      //     child: Text(
                                                                      //       '광고보기??',
                                                                      //       style: TextStyle(color: Colors.teal),
                                                                      //     ),
                                                                      //     onPressed: () {
                                                                      //       Get.back();
                                                                      //     },
                                                                      //   ),
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                          // 오답이면
                                                          else {
                                                            // 이미 푼 문제인지 체크
                                                            if (!_indexOfCorrect.contains(index) && !_indexOfUnCorrect.contains(index)) _indexOfUnCorrect.add(index);
                                                            print('_indexOfUnCorrect:$_indexOfUnCorrect');
                                                            Get.dialog(
                                                              barrierDismissible: false,
                                                              AlertDialog(
                                                                insetPadding: EdgeInsets.all(20),
                                                                content: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    SizedBox(
                                                                      // width: _size.width,
                                                                      child: ExtendedImage.asset(
                                                                        'assets/imgs/cry.png',
                                                                        width: 160,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    SizedBox(
                                                                      // width: _size.width,
                                                                      child: Text(
                                                                        '오답입니다!',
                                                                        style: TextStyle(fontFamily: 'SDneoB', fontSize: 26, color: Colors.red[200]),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 40,
                                                                    ),
                                                                    SizedBox(
                                                                      width: _size.width,
                                                                      child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          primary: Color(0xfff4f7fe),
                                                                          elevation: 0,
                                                                          side: BorderSide(
                                                                            width: 1.0,
                                                                            color: Color(0xff1a68ff),
                                                                          ),
                                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                                        ),
                                                                        child: Text(
                                                                          '다시 풀기',
                                                                          style: TextStyle(color: Color(0xff1a68ff)),
                                                                        ),
                                                                        onPressed: () async {
                                                                          Get.back();
                                                                        },
                                                                      ),
                                                                    ),
                                                                    // SizedBox(
                                                                    //   width: _size.width,
                                                                    //   child: ElevatedButton(
                                                                    //     style: ElevatedButton.styleFrom(
                                                                    //       primary: Colors.white,
                                                                    //       elevation: 0,
                                                                    //       side: BorderSide(
                                                                    //         width: 1.0,
                                                                    //         color: Color(0xff1a68ff),
                                                                    //       ),
                                                                    //       padding: const EdgeInsets.symmetric(vertical: 10),
                                                                    //     ),
                                                                    //     child: Text(
                                                                    //       '힌트보기',
                                                                    //       style: TextStyle(color: Color(0xff1a68ff)),
                                                                    //     ),
                                                                    //     onPressed: () {
                                                                    //       Get.back();
                                                                    //     },
                                                                    //   ),
                                                                    // ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                        // 답을 입력 안 했으면
                                                        else {
                                                          Get.dialog(
                                                            barrierDismissible: false,
                                                            AlertDialog(
                                                              content: Text('정답을 입력해주세요.'),
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
                                                      }
                                                    },
                                                  ),
                                                ),
                                                // 이전 문제 버튼
                                                // index != 0
                                                //     ? Padding(
                                                //         padding: const EdgeInsets
                                                //                 .symmetric(
                                                //             horizontal:
                                                //                 common_s_gap),
                                                //         child: ElevatedButton(
                                                //           style: ElevatedButton
                                                //               .styleFrom(
                                                //             primary: Colors
                                                //                 .transparent,
                                                //             elevation: 0,
                                                //             side: BorderSide(
                                                //               width: 1.0,
                                                //               color:
                                                //                   Colors.teal,
                                                //             ),
                                                //             padding:
                                                //                 const EdgeInsets
                                                //                         .symmetric(
                                                //                     vertical:
                                                //                         10),
                                                //           ),
                                                //           onPressed: () {
                                                //             progressBarController
                                                //                 .decrement();
                                                //             _pageController
                                                //                 .animateToPage(
                                                //               index - 1,
                                                //               duration: Duration(
                                                //                   milliseconds:
                                                //                       300),
                                                //               curve: Curves
                                                //                   .easeInOut,
                                                //             );
                                                //           },
                                                //           child: Text(
                                                //             '이전 문제',
                                                //             style: TextStyle(
                                                //                 color: Colors
                                                //                     .teal),
                                                //           ),
                                                //         ),
                                                //       )
                                                //     : Container(),

                                                // 건너뛰기 버튼
                                                // Padding(
                                                //   padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                                                //   child: ElevatedButton(
                                                //     style: ElevatedButton.styleFrom(
                                                //       primary: Colors.white,
                                                //       elevation: 0,
                                                //       side: BorderSide(
                                                //         width: 1.0,
                                                //         color: Color(0xff1a68ff),
                                                //       ),
                                                //       padding: const EdgeInsets.symmetric(vertical: 10),
                                                //     ),
                                                //     child: Text(
                                                //       '건너뛰기',
                                                //       style: TextStyle(color: Color(0xff1a68ff)),
                                                //     ),
                                                //     onPressed: () async {
                                                //       FocusManager.instance.primaryFocus?.unfocus();
                                                //       UserModel userModel = await userNetworkRepository.getUserModel(userKey: FirebaseAuth.instance.currentUser!.uid);
                                                //       // 마지막 문제인지 체크
                                                //       if (index != itemKeys.length - 1)
                                                //       // 마지막 문제가 아니면
                                                //       {
                                                //         progressBarController.increment();
                                                //         _pageController.animateToPage(
                                                //           index + 1,
                                                //           duration: Duration(milliseconds: 300),
                                                //           curve: Curves.easeInOut,
                                                //         );
                                                //       }
                                                //       // 마지막 문제이면
                                                //       else {
                                                //         await BookService().doneSolvingBook(
                                                //             bookKey, FirebaseAuth.instance.currentUser!.uid, bookModel.userKey, (_indexOfCorrect.length / itemKeys.length * 100).round());
                                                //         // Get.dialog(
                                                //         //   barrierDismissible: false,
                                                //         //   AlertDialog(
                                                //         //     content: Text(
                                                //         //         // '모든 문제를 풀었습니다. 점수는 ${(_indexOfCorrect.length / itemKeys.length * 100).round()}점입니다. 홈으로 이동합니다.'),
                                                //         //         // '모든 문제를 풀었습니다. ${itemKeys.length}문제 중 ${_indexOfCorrect.length}개를 맞혔습니다. 홈으로 이동합니다.'),
                                                //         //         '모든 문제를 풀었습니다. 홈으로 이동합니다.'), // 문제를 풀다가 중단할 경우, 앞에 풀었던 문제에 대해서는 정답여부를 체크할 수가 없어서 맞힌 개수 표시를 일단 없앰.
                                                //         //     actions: [
                                                //         //       TextButton(
                                                //         //         onPressed: () {
                                                //         //           Get.back();
                                                //         //           Get.offAllNamed('/');
                                                //         //         },
                                                //         //         child: Text('확인'),
                                                //         //       ),
                                                //         //     ],
                                                //         //   ),
                                                //         // );
                                                //         Get.dialog(
                                                //           barrierDismissible: false,
                                                //           AlertDialog(
                                                //             insetPadding: EdgeInsets.all(20),
                                                //             content: Column(
                                                //               mainAxisSize: MainAxisSize.min,
                                                //               children: [
                                                //                 // SizedBox(
                                                //                 //   // width: _size.width,
                                                //                 //   child: ExtendedImage.asset(
                                                //                 //     'assets/imgs/clapping-3.png',
                                                //                 //     // 'assets/imgs/confetti.png',
                                                //                 //     // 'assets/imgs/fireworks.png',
                                                //                 //     width: 160,
                                                //                 //   ),
                                                //                 // ),
                                                //                 // SizedBox(
                                                //                 //   height: 10,
                                                //                 // ),
                                                //                 // SizedBox(
                                                //                 //   // width: _size.width,
                                                //                 //   child: Text(
                                                //                 //     '정답입니다!',
                                                //                 //     style: TextStyle(fontFamily: 'SDneoB', fontSize: 26, color: Colors.black54),
                                                //                 //   ),
                                                //                 // ),
                                                //                 SizedBox(
                                                //                   // width: _size.width,
                                                //                   child: Text(
                                                //                     '모든 문제를 풀었습니다. 홈으로 이동합니다.',
                                                //                     style: TextStyle(fontFamily: 'SDneoM', fontSize: 16, color: Colors.black54),
                                                //                   ),
                                                //                 ),
                                                //                 SizedBox(
                                                //                   height: 30,
                                                //                 ),
                                                //                 SizedBox(
                                                //                   width: _size.width,
                                                //                   child: ElevatedButton(
                                                //                     style: ElevatedButton.styleFrom(
                                                //                       primary: Color(0xfff4f7fe),
                                                //                       elevation: 0,
                                                //                       side: BorderSide(
                                                //                         width: 1.0,
                                                //                         color: Color(0xff1a68ff),
                                                //                       ),
                                                //                       padding: const EdgeInsets.symmetric(vertical: 10),
                                                //                     ),
                                                //                     onPressed: () async {
                                                //                       Get.back();
                                                //                       Get.offAllNamed('/');
                                                //                     },
                                                //                     child: Text(
                                                //                       '홈으로 이동',
                                                //                       style: TextStyle(color: Color(0xff1a68ff)),
                                                //                     ),
                                                //                   ),
                                                //                 ),
                                                //                 SizedBox(
                                                //                   width: _size.width,
                                                //                   child: ElevatedButton(
                                                //                     style: ElevatedButton.styleFrom(
                                                //                       primary: Colors.white,
                                                //                       elevation: 0,
                                                //                       side: BorderSide(
                                                //                         width: 1.0,
                                                //                         color: Color(0xff1a68ff),
                                                //                       ),
                                                //                       padding: const EdgeInsets.symmetric(vertical: 10),
                                                //                     ),
                                                //                     child: Text(
                                                //                       '문제집 평가하기',
                                                //                       style: TextStyle(color: Color(0xff1a68ff)),
                                                //                     ),
                                                //                     onPressed: () async {
                                                //                       Get.back();
                                                //                     },
                                                //                   ),
                                                //                 ),
                                                //                 // SizedBox(
                                                //                 //   width: _size.width,
                                                //                 //   child: ElevatedButton(
                                                //                 //     style: ElevatedButton.styleFrom(
                                                //                 //       primary: Colors.transparent,
                                                //                 //       elevation: 0,
                                                //                 //       side: BorderSide(
                                                //                 //         width: 1.0,
                                                //                 //         color: Colors.teal,
                                                //                 //       ),
                                                //                 //       padding: const EdgeInsets.symmetric(vertical: 10),
                                                //                 //     ),
                                                //                 //     child: Text(
                                                //                 //       '광고보기??',
                                                //                 //       style: TextStyle(color: Colors.teal),
                                                //                 //     ),
                                                //                 //     onPressed: () {
                                                //                 //       Get.back();
                                                //                 //     },
                                                //                 //   ),
                                                //                 // ),
                                                //               ],
                                                //             ),
                                                //           ),
                                                //         );
                                                //       }
                                                //     },
                                                //   ),
                                                // ),

                                                // 힌트 보기 버튼
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Colors.white,
                                                      elevation: 0,
                                                      side: BorderSide(
                                                        width: 1.0,
                                                        color: (bookItem.hint == null || bookItem.hint == " " || bookItem.hint == "") ? Colors.grey[300]! : Color(0xff1a68ff),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                    ),
                                                    child: (bookItem.hint == null || bookItem.hint == " " || bookItem.hint == "")
                                                        ? Text(
                                                            '힌트 없음',
                                                            style: TextStyle(color: Colors.grey[300]),
                                                          )
                                                        : Text(
                                                            '힌트 보기',
                                                            style: TextStyle(color: Color(0xff1a68ff)),
                                                          ),
                                                    onPressed: () {
                                                      if (bookItem.hint == null || bookItem.hint == " " || bookItem.hint == "") {
                                                        return null;
                                                      } else {
                                                        Get.dialog(
                                                          barrierDismissible: false,
                                                          AlertDialog(
                                                            insetPadding: EdgeInsets.all(20),
                                                            content: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                SizedBox(
                                                                  // width: _size.width,
                                                                  child: Text(
                                                                    '${bookItem.hint}',
                                                                    // style: TextStyle(fontFamily: 'SDneoB', fontSize: 26, color: Colors.red[200]),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                SizedBox(
                                                                  width: _size.width,
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      primary: Color(0xfff4f7fe),
                                                                      elevation: 0,
                                                                      side: BorderSide(
                                                                        width: 1.0,
                                                                        color: Color(0xff1a68ff),
                                                                      ),
                                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                                    ),
                                                                    child: Text(
                                                                      '확인',
                                                                      style: TextStyle(color: Color(0xff1a68ff)),
                                                                    ),
                                                                    onPressed: () async {
                                                                      Get.back();
                                                                    },
                                                                  ),
                                                                ),
                                                                // SizedBox(
                                                                //   width: _size.width,
                                                                //   child: ElevatedButton(
                                                                //     style: ElevatedButton.styleFrom(
                                                                //       primary: Colors.white,
                                                                //       elevation: 0,
                                                                //       side: BorderSide(
                                                                //         width: 1.0,
                                                                //         color: Color(0xff1a68ff),
                                                                //       ),
                                                                //       padding: const EdgeInsets.symmetric(vertical: 10),
                                                                //     ),
                                                                //     child: Text(
                                                                //       '힌트보기',
                                                                //       style: TextStyle(color: Color(0xff1a68ff)),
                                                                //     ),
                                                                //     onPressed: () {
                                                                //       Get.back();
                                                                //     },
                                                                //   ),
                                                                // ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          );
                        });
                  }
                  // future 데이터가 없으면
                  else {
                    return Container();
                  }
                }),
          ),
        );
      },
    );
  }
}
