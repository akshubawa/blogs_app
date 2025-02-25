import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:assignment_app/firebase_options.dart';
import 'package:assignment_app/providers/blog_provider.dart';
import 'package:assignment_app/screens/blog_list_screen.dart';
import 'package:assignment_app/utils/deeplink_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  final _appLinks = AppLinks();
  late final StreamSubscription<Uri> _linkSubscription;
  
  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    // Handle initial link that opened the app
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _deepLinkHandler.handleLink(initialLink);
      }
    } on PlatformException {
      print('Failed to get initial app link');
    }

    // Handle links that are opened when the app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _deepLinkHandler.handleLink(uri);
    }, onError: (error) {
      print('App link error: $error');
    });
  }
  
  @override
  void dispose() {
    _linkSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return ChangeNotifierProvider(
      create: (context) => BlogProvider(),
      child: MaterialApp(
        title: 'Blog App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          fontFamily: 'Poppins',
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        navigatorKey: _deepLinkHandler.navigatorKey,
        home: const BlogListScreen(),
      ),
    );
  }
}