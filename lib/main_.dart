import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/controller/firebase_auth_state.dart';
import 'package:quiz_first/controller/select_image_notifier.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/util/logger.dart';
import 'package:quiz_first/view/screens/auth_screen.dart';
import 'package:quiz_first/view/screens/feed_screen_old.dart';
import 'package:logger/logger.dart';
import 'package:quiz_first/view/home_page.dart';
import 'package:quiz_first/view/home_page_get.dart';
import 'package:quiz_first/view/widgets/my_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
// FCM관련 https://yjyoon-dev.github.io/flutter/2021/12/04/flutter-07/ 의 코드 적용 버전
// ---------------- FCM 관련 코드 시작 -----------------------------------
  await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true);

  // foreground에서의 푸시 알림 표시를 위한 알림 중요도 설정
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  // foreground에서의 푸시 알림 표시를 위한 local notifications 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon'),
          iOS: IOSInitializationSettings()),
      onSelectNotification: (String? payload) async {});

  // foreground 푸시 알림 핸들링
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ));
    }
  });

  // 사용자가 푸시 알림을 허용했는지 확인 (optional)
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final isFCMEnabled = await prefs.getBool('FCM_ENABLED');
  if (isFCMEnabled == null || isFCMEnabled) {
    // firebase token 발급
    String? firebaseToken = await FirebaseMessaging.instance.getToken();
    print("token main : ${firebaseToken ?? 'token NULL!'}");

    // 서버로 firebase token 갱신
    // if (firebaseToken != null) {
    //   var dio = Dio();
    //   final firebaseTokenUpdateResponse =
    //       await dio.put('/token', data: {'token': firebaseToken});
    // }
  }

  // ---------------- FCM 관련 코드 끝 -----------------------------------

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  Widget? currentWidget;
  FirebaseAuthState _firebaseAuthState = FirebaseAuthState();

  @override
  Widget build(BuildContext context) {
    _firebaseAuthState.watchAuthChange();
//중요!!!!! 반드시 있어야 한다!!!!! 없으면 회원가입/로그인 버튼을 눌러도 반응이 없음.

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseAuthState>.value(
            value: _firebaseAuthState),
        ChangeNotifierProvider<UserModelState>(
          create: (context) => UserModelState(),
        ),
        ChangeNotifierProvider<CategoryNotifier>(
          create: (context) => CategoryNotifier(),
        ),
        ChangeNotifierProvider<SelectImageNotifier>(
          create: (context) => SelectImageNotifier(),
        ),
      ],
      child: GetMaterialApp(
        title: 'Quiz App',
        theme: ThemeData(
          fontFamily: 'SDneoR',
          // primarySwatch: createMaterialColor(
          //   Color(0xFF000000),
          // ),
          textTheme: TextTheme(
            button: TextStyle(fontSize: 16),
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              //<-- SEE HERE
              // Status bar color
              statusBarColor: Colors.red, // 안드로이드만?? (iOS에서는 아무 변화없음)
              // statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light, // iOS에서 먹히는 설정(검정 글씨로 표시됨)
            ),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontFamily: 'SDneoM',
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
            actionsIconTheme: IconThemeData(color: Colors.black87),
          ),
        ),
        home: Consumer<FirebaseAuthState>(
            builder: (context, firebaseAuthState, child) {
          switch (firebaseAuthState.firebaseAuthStatus) {
            case FirebaseAuthStatus.signout:
              _clearUserModel(context);
              currentWidget = AuthScreen();
              break;
            case FirebaseAuthStatus.signin:
              _initUserModel(firebaseAuthState, context);
              currentWidget = HomePage(
                userKey: FirebaseAuth.instance.currentUser!.uid,
              );
              break;
            default:
              currentWidget = MyProgressIndicator();
            // currentWidget = CircularProgressIndicator(
            //   color: Colors.white,
            // );
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            // switchInCurve: Curves.easeInOutBack,
            // switchOutCurve: Curves.easeInOut,
            child: currentWidget,
          );
        }),
      ),
    );
  }

  void _initUserModel(
      FirebaseAuthState firebaseAuthState, BuildContext context) {
    UserModelState userModelState =
        Provider.of<UserModelState>(context, listen: false);

    userModelState.currentStreamSub = userNetworkRepository
        .getUserModelStream(firebaseAuthState.user.uid)
        .listen((usrMl) {
      userModelState.userModel = usrMl;
    });
  }

  void _clearUserModel(BuildContext context) {
    UserModelState userModelState =
        Provider.of<UserModelState>(context, listen: false);
    userModelState.clear();
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}
