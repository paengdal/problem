import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/util/logger.dart';
import 'package:quiz_first/view/screens/auth_screen.dart';
import 'package:quiz_first/view/widgets/my_progress_indicator.dart';

class FirebaseAuthState extends ChangeNotifier {
  FirebaseAuthStatus _firebaseAuthStatus = FirebaseAuthStatus.signout;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  get firebaseAuthStatus => _firebaseAuthStatus;
  User? _user;
  User get user => _user!;
  FacebookLogin? _facebookLogin;
  bool initiated = false;

  void watchAuthChange() async {
    _firebaseAuth.authStateChanges().listen((user) {
      if (user == null && _user == null) {
        changeFirebaseAuthStatus();
        return;
      } else if (user != _user) {
        _user = user;
        changeFirebaseAuthStatus();
      }
    });
  }

  Future<void> registerUser(
      // 고민: createUserWithEmailAndPassword가 Future인데 registerUser를 Future<void>로 하지 않아도 되는지?
      {
    required String username,
    required String email,
    required String password,
    required BuildContext context,
    required Size size,
  }) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyProgressIndicator(),
            fullscreenDialog: true));
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .catchError((error) {
      Navigator.pop(context);

      String _message = "";
      String _title = "";
      switch (error.code) {
        case 'email-already-in-use':
          _title = '이메일 중복';
          _message = "이미 가입된 이메일주소입니다.";
          break;
        case 'invalid-email':
          _title = '올바르지 않은 이메일';
          _message = "올바른 형식의 이메일을 넣어주세요.";
          break;
        case 'weak-password':
          _title = '비밀번호 보안 위험';
          _message = "6자리 이상의 영문숫자 혼합을 추천합니다.";
          break;
        case 'operation-not-allowed':
          _title = '사용 정지 계정';
          _message = "사용이 중지된 계정입니다.";
          break;
      }

      Get.snackbar(_title, _message,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black87,
          margin: EdgeInsets.all(0),
          borderRadius: 0,
          // isDismissible: true,
          // dismissDirection: DismissDirection.horizontal,
          colorText: Colors.white);

      // Get.defaultDialog(
      //   title: error.code,
      //   middleText: _message,
      //   textConfirm: '확인',
      //   onConfirm: () {
      //     Get.off(() => AuthScreen());
      //   },

      // );
    });

    Navigator.pop(context);

    _user = userCredential.user; // 고민: non-nullabel이 맞나?..
    if (_user == null) {
      Get.snackbar('계정 생성 에러', '회원가입이 실패했습니다. 다시 시도해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black87,
          margin: EdgeInsets.all(0),
          borderRadius: 0,
          // isDismissible: true,
          // dismissDirection: DismissDirection.horizontal,
          colorText: Colors.white);
    } else {
      userNetworkRepository.attemptCreateUser(
        userKey: _user!.uid,
        email: _user!.email!,
        username: username,
      );
    }
  }

  void login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    // _firebaseAuthStatus.value = FirebaseAuthStatus.progress;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyProgressIndicator(),
            fullscreenDialog: true));
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .catchError((error) {
      Navigator.pop(context);

      String _message = "";
      String _title = "";
      switch (error.code) {
        case 'user-disabled':
          _title = '사용 정지 계정';
          _message = "사용이 중지된 계정입니다.";
          break;
        case 'invalid-email':
          _title = '올바르지 않은 이메일';
          _message = "올바른 형식의 이메일을 넣어주세요.";
          break;
        case 'wrong-password':
          _title = '비밀번호 오류';
          _message = "비밀번호를 확인해 주세요.";
          break;
        case 'user-not-found':
          _title = '가입되지 않은 이메일';
          _message = "사용자 데이터에서 해당 이메일을 찾을 수 없습니다.";
          break;
      }

      Get.snackbar(_title, _message,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black87,
          margin: EdgeInsets.all(0),
          borderRadius: 0,
          // isDismissible: true,
          // dismissDirection: DismissDirection.horizontal,
          colorText: Colors.white);

      // Get.defaultDialog(
      //   title: error.code,
      //   middleText: _message,
      //   textConfirm: '확인',
      //   onConfirm: () {
      //     Get.off(() => AuthScreen());
      //   },

      // );
    });
    Navigator.pop(context);

    _user = userCredential.user;
    if (_user == null) {
      Get.snackbar('로그인 에러', '로그인이 실패했습니다. 다시 시도해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black87,
          margin: EdgeInsets.all(0),
          borderRadius: 0,
          // isDismissible: true,
          // dismissDirection: DismissDirection.horizontal,
          colorText: Colors.white);
    }
  }

  void signOut() async {
    _firebaseAuthStatus = FirebaseAuthStatus.signout;
    if (_user != null) {
      _user = null;
      await _firebaseAuth.signOut();
      if (await _facebookLogin != null) {
        if (await _facebookLogin!.isLoggedIn) {
          await _facebookLogin!.logOut();
        }
      }
    }
    notifyListeners();
  }

  void changeFirebaseAuthStatus([firebaseAuthStatus]) {
    if (firebaseAuthStatus != null) {
      _firebaseAuthStatus = firebaseAuthStatus;
    } else if (_user != null) {
      _firebaseAuthStatus = FirebaseAuthStatus.signin;
    } else {
      _firebaseAuthStatus = FirebaseAuthStatus.signout;
    }
    notifyListeners();
  }

  void loginWithFacebook(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyProgressIndicator(),
            fullscreenDialog: true));
    if (_facebookLogin == null) {
      _facebookLogin = FacebookLogin();
    }
    final result = await _facebookLogin!.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (result.status) {
      case FacebookLoginStatus.success:
        _handleFacebookTokenWithFirebase(context, result.accessToken!.token);
        break;
      case FacebookLoginStatus.cancel:
        Navigator.pop(context);
        Get.snackbar('로그인 취소', '사용자가 페이스북 로그인을 취소하였습니다.',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
            backgroundColor: Colors.black87,
            margin: EdgeInsets.all(0),
            borderRadius: 0,
            // isDismissible: true,
            // dismissDirection: DismissDirection.horizontal,
            colorText: Colors.white);
        break;
      case FacebookLoginStatus.error:
        Navigator.pop(context);
        Get.snackbar('로그인 에러', '페이스북 로그인에 에러가 발생했습니다.',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
            backgroundColor: Colors.black87,
            margin: EdgeInsets.all(0),
            borderRadius: 0,
            // isDismissible: true,
            // dismissDirection: DismissDirection.horizontal,
            colorText: Colors.white);
        _facebookLogin?.logOut();
        break;
    }
  }

  void _handleFacebookTokenWithFirebase(
      BuildContext context, String token) async {
    // TODO: 토큰을 사용해서 파이어베이스로 로그인하기
    final AuthCredential credential = FacebookAuthProvider.credential(token);

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) {
      Get.snackbar('Facebook login Error, try again!!',
          'Facebook login Error, try again!!',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.black87,
          margin: EdgeInsets.all(0),
          borderRadius: 0,
          // isDismissible: true,
          // dismissDirection: DismissDirection.horizontal,
          colorText: Colors.white);
    } else {
      _user = user;
    }
    notifyListeners();
    Navigator.pop(context);
  }
}

enum FirebaseAuthStatus { signout, progress, signin }
