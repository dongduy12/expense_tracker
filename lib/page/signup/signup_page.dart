import 'package:expense_tracker/constants/function/on_will_pop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/page/signup/bloc/signup_bloc.dart';
import 'package:expense_tracker/page/signup/signup_form.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () => onWillPop(
          action: (now) => currentBackPressTime = now,
          currentBackPressTime: currentBackPressTime,
        ),
        child: SafeArea(
          child: BlocProvider(
            create: (context) => SignupBloc(),
            child: const SignupForm(),
          ),
        ),
      ),
    );
  }
}
