import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/screen_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/view/screens/comments_screen.dart';
import 'package:quiz_first/view/screens/feed_book_screen.dart';
import 'package:quiz_first/view/screens/feed_screen.dart';
import 'package:quiz_first/view/screens/feed/quiz_detail_screen.dart';
import 'package:quiz_first/view/screens/feed_screen_old.dart';
import 'package:quiz_first/view/screens/input_book_screen.dart';
import 'package:quiz_first/view/screens/input_screen.dart';
import 'package:quiz_first/view/screens/profile_screen.dart';
import 'package:get/get.dart';
import 'package:quiz_first/view/screens/search_screen.dart';
import 'package:quiz_first/view/screens/test_screen.dart';

class HomePage extends StatefulWidget {
  final String userKey;
  HomePage({Key? key, required this.userKey}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<Widget> _screens = [
    // 왜 코딩파파는 static을 선언하는가? 안 해도 작동하는데...
    FeedBookScreen(),
    // FeedScreen(userKey: FirebaseAuth.instance.currentUser!.uid),
    // ProfileScreen(),
    // Get.arguments != null
    //     ? SearchScreen(
    //         arguments: Get.arguments,
    //       )
    //     : SearchScreen(),
    TestScreen(), // floatingActionButton 2개
    // Container(
    //   color: Colors.accents[2],
    // ),
    Container(
      color: Colors.accents[3],
    ),

    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;
        return Scaffold(
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Get.to(() => InputScreen(), fullscreenDialog: true);
          //   },
          //   child: Icon(Icons.add),
          // ),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // bottomNavigationBar: BottomNavigationBar(
          //   currentIndex: _currentIndex,
          //   items: [
          //     BottomNavigationBarItem(
          //       icon: Icon(CupertinoIcons.folder_fill),
          //       label: 'dd',
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(CupertinoIcons.folder_fill),
          //       label: 'dd',
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(CupertinoIcons.folder_fill),
          //       label: 'dd',
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(CupertinoIcons.folder_fill),
          //       label: 'dd',
          //     ),
          //   ],
          // ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) {
              if (index == 2) {
                // Get.to(() => InputScreen(), fullscreenDialog: true);
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: Icon(CupertinoIcons.multiply)),
                              SizedBox(
                                width: _size.width,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xff1a68ff),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(30.0),
                                    ),
                                    side: BorderSide(
                                      width: 1.0,
                                      color: Color(0xff1a68ff),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Get.back();
                                    Get.to(() => InputBookScreen(), fullscreenDialog: true);
                                  },
                                  child: Text(
                                    '문제집 만들기',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: _size.width,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.grey[100],
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(30.0),
                                    ),
                                    side: BorderSide(
                                      width: 1.0,
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Get.back();
                                    Get.to(() => InputScreen(), fullscreenDialog: true);
                                  },
                                  child: Text(
                                    '문제 만들기',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              } else if (index == 1) {
                Get.to(() => SearchScreen(), fullscreenDialog: true);
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            unselectedItemColor: Colors.grey[400],
            selectedItemColor: Color(0xff1a68ff),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: (_currentIndex == 0) ? Icon(CupertinoIcons.folder_fill) : Icon(CupertinoIcons.folder), label: '피드'),
              BottomNavigationBarItem(icon: (_currentIndex == 1) ? Icon(CupertinoIcons.search) : Icon(CupertinoIcons.search), label: '검색'),
              BottomNavigationBarItem(icon: (_currentIndex == 2) ? Icon(CupertinoIcons.add_circled_solid) : Icon(CupertinoIcons.add_circled), label: '만들기'),
              BottomNavigationBarItem(icon: (_currentIndex == 3) ? Icon(CupertinoIcons.person_fill) : Icon(CupertinoIcons.person), label: '내정보'),
            ],
          ),
        );
      },
    );
  }
}
