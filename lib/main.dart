import 'package:firebase_core/firebase_core.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/cart/manager/cart_cubit.dart';
import 'package:engez/features/place/place_cubit.dart';
import 'package:engez/repositories/place_repository.dart';
import 'package:engez/features/order/manager/order_cubit.dart';
import 'package:engez/features/order/repositories/order_repository.dart';
import 'package:engez/features/offer/manager/offer_cubit.dart';
import 'package:engez/features/offer/repositories/offer_repository.dart';
import 'package:engez/features/admin/manager/admin_requests_cubit.dart';
import 'package:engez/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';

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
        BlocProvider(create: (_) => PlaceCubit(PlaceRepository())),
        BlocProvider(create: (_) => OrderCubit(OrderRepository())),
        BlocProvider(
          create: (_) => OfferCubit(OfferRepository())..fetchOffers(),
        ),
        BlocProvider(create: (_) => AdminRequestsCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 915),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            locale: const Locale('ar', 'EG'),
            supportedLocales: const [Locale('ar', 'EG')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            theme: ThemeData(
              fontFamily: 'cairo',
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: MyColors.myOrange,
                selectionColor: MyColors.myOrange.withValues(alpha: 0.3),
                selectionHandleColor: MyColors.myOrange,
              ),
            ),
            title: 'Engez - إنجز',
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
