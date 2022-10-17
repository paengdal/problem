import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/controller/edit_profile_controller.dart';
import 'package:quiz_first/controller/firebase_auth_state.dart';
import 'package:quiz_first/controller/select_image_notifier.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/view/screens/auth_screen.dart';
import 'package:quiz_first/view/screens/input/my_book_list.dart';
import 'package:quiz_first/view/screens/input/my_item_list.dart';
import 'package:quiz_first/view/screens/input/my_item_list_in_profile.dart';
import 'package:quiz_first/view/screens/input/solved_book_list.dart';
import 'package:quiz_first/view/screens/profile/edit_profile_screen.dart';
import 'package:quiz_first/view/widgets/my_solved_item_list.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/view/widgets/rounded_avatar_me.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _init = false;
  List<ItemModel> _myItems = [];
  @override
  void initState() {
    if (!_init) {
      _onRefresh();
      _init = true;
    }
    super.initState();
  }

  Future _onRefresh() async {
    if (FirebaseAuth.instance.currentUser != null) _myItems.clear();
    _myItems.addAll(await ItemService().getItemsSolved(FirebaseAuth.instance.currentUser!.uid));
    _myItems.sort(
      (a, b) => a.createDate.compareTo(b.createDate),
    );
    setState(() {});
  }

  final controller = Get.put(EditProfileController());

  int _numOfMyBooks = 0;
  int _numOfSolvedBooks = 0;
  int _numOfMyItems = 0;

  void setNumOfMyBooks(newNum) {
    _numOfMyBooks = newNum;
  }

  void setNumOfSolvedBooks(newNum) {
    _numOfSolvedBooks = newNum;
  }

  void setNumOfMyItems(newNum) {
    _numOfMyItems = newNum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Consumer<UserModelState>(
            builder: (BuildContext context, UserModelState userModelState, Widget? child) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(common_xl_gap, 0, common_xs_gap, 0),
                    child: SizedBox(
                      height: 90,
                      child: Row(
                        children: [
                          RoundedAvatarMe(
                            avatarSize: 50,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${userModelState.userModel == null ? "userModel is null" : userModelState.userModel!.username}',
                                style: TextStyle(fontFamily: 'SDneoB', fontSize: 20),
                              ),
                              Text(
                                '${userModelState.userModel == null ? "userModel is null" : userModelState.userModel!.email}',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                          // IconButton(
                          //   onPressed: () {
                          //     // context.read<FirebaseAuthState>().signOut();
                          //     Provider.of<FirebaseAuthState>(context,
                          //             listen: false)
                          //         .signOut();
                          //   },
                          //   icon: Icon(CupertinoIcons.escape),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0,
                        side: BorderSide(
                          width: 1.0,
                          color: Color(0xff1a68ff),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        Get.to(() => EditProfileScreen(), fullscreenDialog: true);
                        if (context.read<UserModelState>().userModel != null && context.read<UserModelState>().userModel!.imageDownloadUrls.isNotEmpty)
                          Get.find<EditProfileController>().setTempUrls(context.read<UserModelState>().userModel!.imageDownloadUrls[0]);
                      },
                      child: Text(
                        '프로필 수정',
                        style: TextStyle(
                          color: Color(0xff1a68ff),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: common_l_gap),
                  //   child: Card(
                  //     // elevation: 20,
                  //     // shadowColor: Colors.black87,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     child: Container(
                  //       height: 80,
                  //       decoration: BoxDecoration(
                  //         color: Colors.amber,
                  //         borderRadius: BorderRadius.circular(20),
                  //         shape: BoxShape.rectangle,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(common_xxl_gap, 0, 0, 0),
                    child: Row(
                      children: [
                        ExtendedImage.asset(
                          'assets/imgs/list.png',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          '내가 만든 문제집',
                          style: TextStyle(fontSize: 16, fontFamily: 'SDneoB', color: Colors.black),
                        ),
                        Text(
                          ' (${_numOfMyBooks}개)',
                          style: TextStyle(fontSize: 16, fontFamily: 'SDneoB', color: Colors.black),
                        )
                      ],
                    ),
                  ),
                  // Divider(
                  //   indent: common_xl_gap,
                  //   endIndent: common_xl_gap,
                  //   thickness: 1,
                  //   height: 11,
                  //   color: Colors.grey[200],
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(common_l_gap, 0, common_l_gap, 0),
                    child: Container(
                      child: MyBookList(setNumOfMyBooks: setNumOfMyBooks),
                      padding: const EdgeInsets.fromLTRB(0, common_xs_gap, 0, common_s_gap),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(common_xxl_gap, 0, 0, 0),
                    child: Row(
                      children: [
                        ExtendedImage.asset(
                          'assets/imgs/assign.png',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          '내가 만든 문제',
                          style: TextStyle(fontSize: 16, fontFamily: 'SDneoB', color: Colors.black),
                        ),
                        Text(
                          ' (${_numOfMyItems}개)',
                          style: TextStyle(fontSize: 16, fontFamily: 'SDneoB', color: Colors.black),
                        )
                      ],
                    ),
                  ),
                  // Divider(
                  //   indent: common_xl_gap,
                  //   endIndent: common_xl_gap,
                  //   thickness: 1,
                  //   height: 11,
                  //   color: Colors.grey[200],
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  // MySolvedItemList(myItems: _myItems),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(common_l_gap, 0, common_l_gap, 0),
                    child: Container(
                      child: MyItemListInProfile(setNumOfMyItems: setNumOfMyItems),
                      padding: const EdgeInsets.fromLTRB(0, common_xs_gap, 0, common_s_gap),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(common_xxl_gap, 0, 0, 0),
                    child: Row(
                      children: [
                        ExtendedImage.asset(
                          'assets/imgs/completed-task.png',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          '내가 푼 문제집',
                          style: TextStyle(fontSize: 16, fontFamily: 'SDneoB', color: Colors.black),
                        ),
                        Text(
                          ' (${_numOfSolvedBooks}개)',
                          style: TextStyle(fontSize: 16, fontFamily: 'SDneoB', color: Colors.black),
                        )
                      ],
                    ),
                  ),
                  // Divider(
                  //   indent: common_xl_gap,
                  //   endIndent: common_xl_gap,
                  //   thickness: 1,
                  //   height: 11,
                  //   color: Colors.grey[200],
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  userModelState.userModel != null
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(common_l_gap, 0, common_l_gap, 0),
                          child: Container(
                            child: SolvedBookList(userModel: userModelState.userModel!, setNumOfSolvedBooks: setNumOfSolvedBooks),
                            padding: const EdgeInsets.fromLTRB(0, common_xs_gap, 0, common_s_gap),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 30,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
