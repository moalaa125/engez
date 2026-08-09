import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/presentation/screens/home_screen.dart';
import 'package:engez/features/auth/presentation/screens/login_screen.dart';
import 'package:engez/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:engez/features/cart/manager/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';

// TODO: استيراد لوحة تحكم صاحب المطعم عند إنشائها
// import 'package:engez/features/auth/presentation/screens/owner_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EngezApp());
}

class EngezApp extends StatelessWidget {
  const EngezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartCubit()),
      ],
      child: ScreenUtilInit(
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
            home: FutureBuilder<User?>(
              future: FirebaseAuth.instance.authStateChanges().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                final user = snapshot.data;

                if (user == null) {
                  return const LoginScreen();
                }

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const RoleSelectionScreen();
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final role = data['role'] ?? 'customer';

                    if (role == 'owner') {
                      return const Placeholder(
                        child: Center(
                          child: Text(
                            'صاحب مطعم - لوحة التحكم قيد التطوير',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const HomeScreen();
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}