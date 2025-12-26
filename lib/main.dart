import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <--- Thêm import này
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/constants/app_colors.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/page/forgot/forgot_page.dart';
import 'package:expense_tracker/page/forgot/success_page.dart';
import 'package:expense_tracker/page/login/login_page.dart';
import 'package:expense_tracker/page/main/home/home_page.dart';
import 'package:expense_tracker/page/main/main_page.dart';
import 'package:expense_tracker/page/onboarding/onboarding_page.dart';
import 'package:expense_tracker/page/signup/verify/verify_page.dart';
import 'package:expense_tracker/setting/bloc/setting_cubit.dart';
import 'package:expense_tracker/setting/bloc/setting_state.dart';
import 'package:expense_tracker/setting/localization/app_localizations_setup.dart';

bool loginMethod = false;
int? language;
bool isDark = false;
bool isFirstStart = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Khởi tạo Google Sign In 1 lần duy nhất
  await GoogleSignIn.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  language = prefs.getInt('language');
  isDark = prefs.getBool("isDark") ?? false;
  isFirstStart = prefs.getBool("firstStart") ?? true;
  loginMethod = prefs.getBool("login") ?? false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((value) {
      value.setBool("firstStart", false);
    });
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingCubit>(
          create: (_) => SettingCubit(language: language, isDark: isDark),
        ),
      ],
      child: BlocBuilder<SettingCubit, SettingState>(
          buildWhen: (previous, current) => previous != current,
          builder: (_, settingState) {
            return MaterialApp(
              supportedLocales: AppLocalizationsSetup.supportedLocales,
              localizationsDelegates:
                  AppLocalizationsSetup.localizationsDelegates,
              localeResolutionCallback:
                  AppLocalizationsSetup.localeResolutionCallback,
              locale: settingState.locale,
              debugShowCheckedModeBanner: false,
              title: 'Spending Management',
              theme: settingState.isDark
                  ? ThemeData(
                      brightness: Brightness.dark,
                      primarySwatch: Colors.blue,
                    )
                  : ThemeData(
                      cardColor: Colors.white,
                      colorScheme:
                          const ColorScheme.light(background: Colors.white),
                      brightness: Brightness.light,
                      primarySwatch: Colors.blue,
                      scaffoldBackgroundColor: AppColors.whisperBackground,
                      bottomAppBarTheme: BottomAppBarThemeData(
                        color: AppColors.whisperBackground,
                      ),
                      floatingActionButtonTheme:
                          const FloatingActionButtonThemeData(
                        backgroundColor: Color.fromRGBO(121, 158, 84, 1),
                      ),
                      appBarTheme: AppBarTheme(
                        backgroundColor: AppColors.whisperBackground,
                        iconTheme: const IconThemeData(color: Colors.black),
                        titleTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      primaryColor: const Color.fromRGBO(242, 243, 247, 1),
                    ),
              initialRoute: FirebaseAuth.instance.currentUser == null
                  ? (isFirstStart ? "/" : "/login")
                  : loginMethod
                      ? (FirebaseAuth.instance.currentUser!.emailVerified
                          ? '/main'
                          : '/verify')
                      : '/main',
              routes: {
                '/': (context) => const OnBoardingPage(),
                '/login': (context) => const LoginPage(),
                '/home': (context) => const HomePage(),
                '/main': (context) => const MainPage(),
                '/forgot': (context) => const ForgotPage(),
                '/success': (context) => const SuccessPage(),
                '/verify': (context) => const VerifyPage(),
              },
            );
          }),
    );
  }
}
