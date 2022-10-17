import 'package:algolia/algolia.dart';
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
import 'package:quiz_first/pages/notification_details_page.dart';
import 'package:quiz_first/pages/notification_details_page_termi.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/util/logger.dart';
import 'package:quiz_first/view/screens/auth_screen.dart';
import 'package:quiz_first/view/screens/feed/book_detail_screen.dart';
import 'package:quiz_first/view/screens/feed/book_detail_screen_list.dart';
import 'package:quiz_first/view/screens/feed/quiz_detail_screen.dart';
import 'package:quiz_first/view/screens/feed_screen_old.dart';
import 'package:logger/logger.dart';
import 'package:quiz_first/view/home_page.dart';
import 'package:quiz_first/view/home_page_get.dart';
import 'package:quiz_first/view/screens/input/add_item.dart';
import 'package:quiz_first/view/screens/input/category_input_screen.dart';
import 'package:quiz_first/view/screens/input_book_screen.dart';
import 'package:quiz_first/view/screens/input_screen.dart';
import 'package:quiz_first/view/screens/input_screen_in_book.dart';
import 'package:quiz_first/view/screens/notification_screen.dart';
import 'package:quiz_first/view/screens/profile_screen.dart';
import 'package:quiz_first/view/screens/search_screen.dart';
import 'package:quiz_first/view/screens/test.dart';
import 'package:quiz_first/view/widgets/my_progress_indicator.dart';

// FCM관련 https://velog.io/@leedool3003/Flutter-FCM-Firebase-Cloud-Messagin-연동 의 코드 적용 버전
// 앱이 실행중일때 동일한 push가 2번 오는 버그가 있다. 수정해야함.
// 그런데 유일하게 알림소리(또는 진동)가 전달되는 알림은 앱이 실행중일때의 그 두번째 중복 알림이다..뭐지? ㅠㅠ
//------------------------------------------------------

// Firebase Messaging 관련 코드 : 시작 ----------------------------
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

// Firebase Messaging 관련 코드 : 끝 ----------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

// Firebase Messaging 관련 코드 : 시작 ----------------------------

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // foreground에서의 푸시 알림 표시를 위한 알림 중요도 설정
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  // 안드로이드 알림 올 때 앱 아이콘 설정
  var initialzationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS 알림, 뱃지, 사운드 권한 셋팅
  // 만약에 사용자에게 앱 권한을 안 물어봤을 경우 이 셋팅으로 인해 permission check 함
  var initialzationSettingsIOS = IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

// foreground에서의 푸시 알림 표시를 위한 local notifications 설정
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

// foreground에서의 푸시 알림 클릭 액션 설정
  var initializationSettings = InitializationSettings(android: initialzationSettingsAndroid, iOS: initialzationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) {
      // 여기에 실행할 콜백 추가
      print('foreground click: $payload');
      // Get.offAllNamed('/', arguments: payload);
      Get.toNamed('/detail/${payload}');
    },
  );

  // foreground 푸시 알림 핸들링
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    AppleNotification? apple = message.notification?.apple;

    if (notification != null && android != null) {
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['itemKey'],
      );
    }
  });

  // background에서의 푸시 알림 클릭 액션 설정 : fore, back 구분없이 클릭시의 액션 설정같은데?..
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    // print('background click: ${message.notification!.title}');
    if (message.data['id'] == '1') {
      Get.offAllNamed(
        '/',
        // arguments: message.data['back'],
        arguments: message.data,
      );
    } else if (message.data['id'] == '2') {
      Get.toNamed(
        '/input',
        // arguments: message.data['back'],
        arguments: message.data,
      );
    } else if (message.data['id'] == '3') {
      Get.toNamed(
        '/detail/${message.data['itemKey']}',
        arguments: message.data,
      );
    }
  });

  // Terminated 상태에서 도착한 메시지에 대한 처리
  // RemoteMessage? initialMessage =
  //     await FirebaseMessaging.instance.getInitialMessage();
  // if (initialMessage != null) {
  // 해당 아이템 페이지로 가는 링크는 앱이 꺼진 상태에서는 작동하지 않았음
  // Get.toNamed('/detail/${initialMessage.data['itemKey']}',
  //     arguments: initialMessage.data);

  // 앱이 꺼진 상태에서의 알림은 무조건 홈페이지로 이동
  // 이후에 앱 내의 알림(혹은 알림 서랍 페이지)을 통해 링크로 이동할 수 있도록 하면 될 것
  // Get.toNamed('/auth');
  // Get.to(NotificationDetailsPage());
  // }

  // Terminated 상태에서 도착한 메시지에 대한 처리
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    var a = initialMessage.data['itemKey'];
  }

  // Firebase Messaging 관련 코드 : 끝 ----------------------------

  runApp(MyApp());
}

// WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp();
// 아래의 futurebuilder대신 위 두줄의 코드로 대체 가능했음.

// class App extends StatelessWidget {
//   const App({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: Firebase.initializeApp(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Container(
//               child: Center(
//                 child: Text('Something went wrong. Plz try again later.'),
//               ),
//             );
//           }
//           if (snapshot.connectionState == ConnectionState.done) {
//             return MyApp();
//           }

//           return CircularProgressIndicator();
//         });
//   }
// }

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  Widget? currentWidget;
  FirebaseAuthState _firebaseAuthState = FirebaseAuthState();

  @override
  Widget build(BuildContext context) {
// Firebase Messaging 관련 코드 : 시작 ----------------------------

// https://kanoos-stu.tistory.com/72 의 코드 시작

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //     flutterLocalNotificationsPlugin.show(
    //         message.hashCode,
    //         message.notification?.title,
    //         message.notification?.body,
    //         NotificationDetails(
    //             android: AndroidNotificationDetails(
    //               channel.id,
    //               channel.name,
    //               channelDescription: channel.description,
    //               icon: '@mipmap/ic_launcher',
    //             ),
    //             iOS: const IOSNotificationDetails(
    //               badgeNumber: 1,
    //               subtitle: 'the subtitle',
    //               sound: 'slow_spring_board.aiff',
    //             )));
    //   }
    // });
// https://kanoos-stu.tistory.com/72 의 코드 끝

// ㅁㅁㅁㅁㅁㅁ 이 코드를 쓰면 foreground 알림이 한 번 실행됨 ㅁㅁㅁㅁㅁㅁ 시작

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             channelDescription: channel.description,
    //             icon: android.smallIcon,
    //           ),
    //         ));
    //   }
    // });

// ㅁㅁㅁㅁㅁㅁ 이 코드를 쓰면 foreground 알림이 한 번 실행됨 ㅁㅁㅁㅁㅁㅁ 끝

// ㅁㅁㅁㅁㅁㅁ 이 코드를 쓰면 foreground 알림이 두 번 실행됨 ㅁㅁㅁㅁㅁㅁ 시작

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   var androidNotiDetails = AndroidNotificationDetails(
    //     channel.id,
    //     channel.name,
    //     channelDescription: channel.description,
    //   );
    //   var iOSNotiDetails = const IOSNotificationDetails(
    // // badgeNumber: 100,
    // subtitle: 'the subtitle',
    // sound: 'slow_spring_board.aiff',);
    //   var details =
    //       NotificationDetails(android: androidNotiDetails, iOS: iOSNotiDetails);
    //   if (notification != null) {
    //     flutterLocalNotificationsPlugin.show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       details,
    //     );
    //   }
    // });

    // background에서의 푸시 알림 클릭 액션 설정
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print('background click: ${message.notification!.title}');
    //   Get.to(() => HomePage(
    //         userKey: FirebaseAuth.instance.currentUser!.uid,
    //       ));
    // });

// ㅁㅁㅁㅁㅁㅁ 이 코드를 쓰면 foreground 알림이 두 번 실행됨 ㅁㅁㅁㅁㅁㅁ 끝

// Firebase Messaging 관련 코드 : 끝 ----------------------------

    _firebaseAuthState.watchAuthChange();
//중요!!!!! 반드시 있어야 한다!!!!! 없으면 회원가입/로그인 버튼을 눌러도 반응이 없음.

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseAuthState>.value(value: _firebaseAuthState),
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
        getPages: [
          GetPage(
            name: '/',
            page: () => HomePage(userKey: FirebaseAuth.instance.currentUser!.uid),
          ),
          GetPage(
            name: '/input',
            page: () => InputScreen(),
            transition: Transition.downToUp,
          ),
          GetPage(
            name: '/input/category',
            page: () => CategoryInputScreen(),
          ),
          GetPage(
            name: '/inputInBook',
            page: () => InputScreenInBook(),
          ),
          GetPage(
            name: '/inputBook',
            page: () => InputBookScreen(),
            transition: Transition.downToUp,
          ),
          GetPage(
            name: '/inputBook/addItem',
            page: () => AddItem(),
          ),
          GetPage(
            name: '/auth',
            page: () => AuthScreen(),
          ),
          GetPage(
            name: '/detail/:itemKey',
            page: () => QuizDetailScreen(),
          ),
          GetPage(
            name: '/bookDetail/:bookKey',
            page: () => BookDetailScreen(),
          ),
          GetPage(
            name: '/bookDetailOld/:bookKey',
            page: () => BookDetailScreenList(),
          ),
          GetPage(
            name: '/notification',
            page: () => NotificationScreen(),
          ),
          GetPage(
            name: '/search',
            page: () => SearchScreen(),
          ),
        ],
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
        home: Consumer<FirebaseAuthState>(builder: (context, firebaseAuthState, child) {
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

  void _initUserModel(FirebaseAuthState firebaseAuthState, BuildContext context) {
    UserModelState userModelState = Provider.of<UserModelState>(context, listen: false);

    userModelState.currentStreamSub = userNetworkRepository.getUserModelStream(firebaseAuthState.user.uid).listen((usrMl) {
      userModelState.userModel = usrMl;
    });
  }

  void _clearUserModel(BuildContext context) {
    UserModelState userModelState = Provider.of<UserModelState>(context, listen: false);
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
