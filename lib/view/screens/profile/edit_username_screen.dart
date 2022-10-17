import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditUsernameScreen extends StatefulWidget {
  final username;
  final editUsername;
  const EditUsernameScreen({Key? key, this.username, this.editUsername})
      : super(key: key);

  @override
  State<EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 0,
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left),
          // constraints: BoxConstraints(),
          iconSize: 22,
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text('사용자명 수정'),
        actions: [
          TextButton(
            onPressed: () {
              if (_controller.text == "") {
                Get.dialog(
                  barrierDismissible: false,
                  AlertDialog(
                    content: Text('이름은 빈칸일 수 없습니다. 이름을 입력해주세요.'),
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
                widget.editUsername(_controller.text);
                Get.back();
              }
            },
            child: Text('완료'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          autofocus: true,
          controller: _controller..text = widget.username,
        ),
      ),
    );
  }
}
