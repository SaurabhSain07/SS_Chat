import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
// import 'package:flutter/services.dart';
// import 'package:ss_chat/email/email.dart';
import 'package:ss_chat/firebase_options.dart';
// import 'package:ss_chat/google_signin/home_google.dart';
import 'package:ss_chat/screen/auth/splash_screen.dart';
// import 'package:ss_chat/screen/auth/login_screen.dart';
// import 'package:ss_chat/screen/auth/splash_screen.dart';
// import 'package:ss_chat/screen/home_screen.dart';


// Globel object for accessing devise Screen size
late Size mq;
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white)
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

   var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats');
    print('\nNotification Channel Result: $result');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SS Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme:const AppBarTheme(centerTitle: true,
        elevation: 10,
        titleTextStyle: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.normal),),
        ),
         home: SplashView(),
      );
  }
}

