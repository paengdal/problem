import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/input_deco.dart';
import 'package:quiz_first/controller/firebase_auth_state.dart';
import 'package:quiz_first/util/logger.dart';
import 'package:get/get.dart';
import 'package:quiz_first/view/home_page.dart';
import 'package:quiz_first/view/widgets/or_divider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  // TextEditingController _cpwController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _pwController.dispose();
    // _cpwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(common_l_gap),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    controller: _usernameController,
                    decoration: textInputDeco('사용자명'),
                    validator: (text) {
                      if (text!.isNotEmpty) {
                        return null;
                      } else {
                        return '사용자명은 필수 입력입니다.';
                      }
                    },
                  ),
                  SizedBox(
                    height: common_xxs_gap,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _emailController,
                    decoration: textInputDeco('이메일'),
                    validator: (text) {
                      if (text!.isNotEmpty && text.contains('@')) {
                        return null;
                      } else {
                        return '정확한 이메일 주소를 입력해주세요';
                      }
                    },
                  ),
                  SizedBox(
                    height: common_xxs_gap,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    // obscureText: true,
                    controller: _pwController,
                    decoration: textInputDeco('비밀번호(6자리 이상)'),
                    validator: (text) {
                      if (text!.isNotEmpty && text.length > 5) {
                        return null;
                      } else {
                        return '비밀번호를 확인해주세요';
                      }
                    },
                  ),
                  // SizedBox(
                  //   height: common_xxs_gap,
                  // ),
                  // TextFormField(
                  //   obscureText: true,
                  //   controller: _cpwController,
                  //   decoration: textInputDeco('비밀번호 확인(6자리 이상)'),
                  //   validator: (text) {
                  //     if (text!.isNotEmpty && text == _pwController.text) {
                  //       return null;
                  //     } else {
                  //       return '비밀번호가 일치하지 않습니다';
                  //     }
                  //   },
                  // ),
                  SizedBox(
                    height: common_xxs_gap,
                  ),
                  BtnSmtSignUp(
                    formKey: _formKey,
                    usernameController: _usernameController,
                    emailController: _emailController,
                    pwController: _pwController,
                    context: context,
                    size: size,
                  ),
                  OrDivider(),
                  BtnLoginFB(),
                  SizedBox(
                    height: common_xxs_gap,
                  ),
                  BtnLoginGG(),
                  SizedBox(
                    height: common_xxs_gap,
                  ),
                  BtnLoginKaKao(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BtnSmtSignUp extends StatelessWidget {
  const BtnSmtSignUp({
    Key? key,
    required GlobalKey<FormState> formKey,
    required TextEditingController usernameController,
    required TextEditingController emailController,
    required TextEditingController pwController,
    required BuildContext context,
    required Size size,
  })  : _formKey = formKey,
        _usernameController = usernameController,
        _emailController = emailController,
        _pwController = pwController,
        context = context,
        size = size,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final TextEditingController _usernameController;
  final TextEditingController _emailController;
  final TextEditingController _pwController;
  final BuildContext context;
  final Size size;

  @override
  Widget build(BuildContext context) {
    // return TextButton(
    //   style: ButtonStyle(
    //     minimumSize: MaterialStateProperty.all(
    //       Size.fromHeight(
    //         50,
    //       ),
    //       // 버튼 자체를 Container로 감싸고 height를 50으로 줘도 동일한 결과를 보임
    //     ),
    //     shape: MaterialStateProperty.all(
    //       RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(common_xxl_gap),
    //       ),
    //     ),
    //     backgroundColor: MaterialStateProperty.all(Colors.teal),
    //   ),
    //   onPressed: () {
    //     if (_formKey.currentState!.validate()) {
    //       context.read<FirebaseAuthState>().registerUser(
    //           username: _usernameController.text,
    //           email: _emailController.text,
    //           password: _pwController.text,
    //           context: context,
    //           size: size);
    //     }
    //   },
    //   child: Text(
    //     '회원가입',
    //     style: TextStyle(color: Colors.white),
    //   ),
    // );
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<FirebaseAuthState>().registerUser(username: _usernameController.text, email: _emailController.text, password: _pwController.text, context: context, size: size);
        }
      },
      child: Text('회원가입'),
      style: ElevatedButton.styleFrom(
        primary: Color(0xff1a68ff),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
    );
  }
}

class BtnLoginKaKao extends StatelessWidget {
  const BtnLoginKaKao({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: ButtonStyle(
        side: MaterialStateProperty.all(
          BorderSide(color: Colors.black, width: 1.0, style: BorderStyle.solid),
        ),
        minimumSize: MaterialStateProperty.all(
          Size.fromHeight(
            50,
          ),
          // 버튼 자체를 Container로 감싸고 height를 50으로 줘도 동일한 결과를 보임
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(common_xxxl_gap),
          ),
        ),
      ),
      onPressed: () {},
      icon: ExtendedImage.asset(
        'assets/imgs/kakao_logo.png',
        width: 30,
        height: 30,
      ),
      label: Text(
        '카카오톡으로 로그인',
        style: TextStyle(
            // color: Color(0xFF3a75eb),
            color: Colors.black),
      ),
    );
  }
}

class BtnLoginGG extends StatelessWidget {
  const BtnLoginGG({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: ButtonStyle(
        side: MaterialStateProperty.all(
          BorderSide(color: Colors.black, width: 1.0, style: BorderStyle.solid),
        ),
        minimumSize: MaterialStateProperty.all(
          Size.fromHeight(
            50,
          ),
          // 버튼 자체를 Container로 감싸고 height를 50으로 줘도 동일한 결과를 보임
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(common_xxxl_gap),
          ),
        ),
      ),
      onPressed: () {},
      icon: ExtendedImage.asset(
        'assets/imgs/google_logo_500.png',
        width: 30,
        height: 30,
      ),
      label: Text(
        '구글 계정으로 로그인',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}

class BtnLoginFB extends StatelessWidget {
  const BtnLoginFB({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: ButtonStyle(
        side: MaterialStateProperty.all(
          BorderSide(color: Colors.black, width: 1.0, style: BorderStyle.solid),
        ),
        minimumSize: MaterialStateProperty.all(
          Size.fromHeight(
            50,
          ),
          // 버튼 자체를 Container로 감싸고 height를 50으로 줘도 동일한 결과를 보임
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(common_xxxl_gap),
          ),
        ),
      ),
      onPressed: () {
        context.read<FirebaseAuthState>().loginWithFacebook(context);
      },
      icon: ExtendedImage.asset(
        'assets/imgs/f_logo_144.png',
        width: 30,
        height: 30,
      ),
      label: Text(
        '페이스북으로 로그인',
        style: TextStyle(
            // color: Color(0xFF3a75eb),
            color: Colors.black),
      ),
    );
  }
}
