import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/edit_profile_controller.dart';
import 'package:quiz_first/controller/firebase_auth_state.dart';
import 'package:quiz_first/controller/select_image_notifier.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/image_storage.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/view/screens/profile/edit_username_screen.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';
import 'package:quiz_first/view/widgets/rounded_avatar_edit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String username = '';
  bool _isProcessing = false;
  bool _isPickingImage = false;

  Future<void> editProfile() async {
    setState(() {
      _isProcessing = true;
    });
    final userKey = FirebaseAuth.instance.currentUser!.uid;
    List<Uint8List> images = context.read<SelectImageNotifier>().profileImages;
    List<dynamic> downloadUrls = [];
    if (context.read<SelectImageNotifier>().profileImages.isNotEmpty) {
      downloadUrls = await ImageStorage.uploadImages(images, userKey);
    } else {
      if (Get.find<EditProfileController>().tempUrls.isNotEmpty) {
        downloadUrls = Get.find<EditProfileController>().tempUrls;
      } else {
        downloadUrls = Get.find<EditProfileController>().tempUrls;
        ImageStorage.deleteProfileImages(userKey);
      }
    }

    userNetworkRepository.editProfile(
      userKey,
      username,
      downloadUrls,
    );
    setState(() {
      _isProcessing = false;
    });

    context.read<SelectImageNotifier>().profileImages.clear();
  }

  void editUsername(newName) {
    setState(() {
      username = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;
        return Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
                preferredSize: Size(_size.width, 2),
                child: _isProcessing
                    ? LinearProgressIndicator(
                        minHeight: 2,
                      )
                    : Container()),
            centerTitle: true,
            titleSpacing: 0,
            leadingWidth: 60,
            leading: TextButton(
              onPressed: () {
                Get.back();
                context.read<SelectImageNotifier>().profileImages.clear();
              },
              child: Text('취소'),
            ),
            title: Text('프로필 수정'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (username == '') {
                    username = context.read<UserModelState>().userModel!.username;
                    await editProfile();
                    Get.back();
                  } else {
                    await editProfile();
                    Get.back();
                  }
                },
                child: Text('완료'),
              ),
            ],
          ),
          body: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () async {
                      // 하단 팝업 메뉴 시작
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context1) => CupertinoActionSheet(
                          // 그냥 'context'로 둘 경우 provider의 context와 혼돈이 생겨 에러가 남.
                          // title: Text(
                          //   "프로필 이미지",
                          //   style: TextStyle(
                          //     fontSize: 20,
                          //   ),
                          // ),
                          // message: Text(
                          //   'Select any action :',
                          //   style: TextStyle(fontSize: 20),
                          // ),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              child: Text(
                                "갤러리에서 이미지 선택",
                                style: TextStyle(
                                  fontFamily: 'SDneoM',
                                  fontWeight: FontWeight.w100,
                                  // fontSize: 10,
                                ),
                              ),
                              isDefaultAction: true,
                              onPressed: () async {
                                Get.back();
                                setState(() {
                                  _isPickingImage = true;
                                });
                                final ImagePicker _picker = ImagePicker();
                                XFile? image = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 20,
                                );
                                if (image != null) {
                                  context.read<SelectImageNotifier>().setNewProfielImage(image);
                                }
                                _isPickingImage = false;
                                setState(() {});
                              },
                            ),
                            // 프로필 이미지가 있는 경우에만 삭제 버튼 보여주기
                            if ((context.watch<SelectImageNotifier>().profileImages.isNotEmpty) ||
                                (context.watch<UserModelState>().userModel != null && context.watch<UserModelState>().userModel!.imageDownloadUrls.isNotEmpty))
                              CupertinoActionSheetAction(
                                child: Text(
                                  "프로필 이미지 삭제",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: 'SDneoM',
                                    fontWeight: FontWeight.w100,
                                    // fontSize: 10,
                                  ),
                                ),
                                isDefaultAction: true,
                                onPressed: () {
                                  context.read<SelectImageNotifier>().removeProfileImage();
                                  Get.find<EditProfileController>().delTempUrls();
                                  Get.back();
                                },
                              ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: Text("취소하기"),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                      );
                      // 하단 팝업 메뉴 끝
                    },
                    child: !_isPickingImage
                        ? RoundedAvatarEdit(
                            avatarSize: 140,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(50),
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (username == '') {
                        username = context.read<UserModelState>().userModel!.username;
                        Get.to(() => EditUsernameScreen(
                              username: username,
                              editUsername: editUsername,
                            ));
                      } else {
                        Get.to(() => EditUsernameScreen(
                              username: username,
                              editUsername: editUsername,
                            ));
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 50,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: common_s_gap + 3, vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Colors.grey[200],
                                // borderRadius: BorderRadius.circular(6),
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              username != '' ? '$username' : '${context.read<UserModelState>().userModel!.username}',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'SDneoR',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  // TextField(
                  //   controller: ,
                  // ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff1a68ff),
                    elevation: 0,
                    // side: BorderSide(
                    //   width: 1.0,
                    //   color: Colors.teal,
                    // ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Get.dialog(
                      barrierDismissible: false,
                      AlertDialog(
                        content: Text('로그아웃하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                              Provider.of<FirebaseAuthState>(context, listen: false).signOut();
                              Get.back();
                            },
                            child: Text('로그아웃'),
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
                  },
                  child: Text(
                    '로그아웃',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
