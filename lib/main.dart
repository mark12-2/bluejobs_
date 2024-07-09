import 'package:bluejobs/firebase_options.dart';
import 'package:bluejobs/provider/auth_provider.dart';
import 'package:bluejobs/provider/notifications/notifications_provider.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bluejobs/screens_for_auth/signin.dart';
import 'package:provider/provider.dart';

// firebase connection
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Blue Jobs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const SignInPage(),
      ),
    );
  }
}
