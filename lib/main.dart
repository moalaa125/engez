import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EngezApp());
}

class EngezApp extends StatelessWidget {
  const EngezApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 915),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: MyColors.myOrange,
              selectionColor: MyColors.myOrange.withValues(alpha: 0.3),
              selectionHandleColor: MyColors.myOrange,
            ),
          ),
          title: 'Engez - إنجز',
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}
