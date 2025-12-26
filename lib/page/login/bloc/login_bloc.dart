import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import đúng
import 'package:intl/intl.dart';
import 'package:expense_tracker/page/login/bloc/login_event.dart';
import 'package:expense_tracker/page/login/bloc/login_state.dart';
import 'package:expense_tracker/models/user.dart' as myuser;
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  String _status = "";

  // XÓA dòng khai báo biến _googleSignIn cũ đi
  // final GoogleSignIn _googleSignIn = ... (Xóa dòng này)

  LoginBloc() : super(InitState()) {
    on<LoginWithEmailPasswordEvent>((event, emit) async {
      bool check = await signInWithEmailAndPassword(
          emailAddress: event.email, password: event.password);
      if (check) {
        SharedPreferences.getInstance().then((value) {
          value.setBool("login", true);
        });
        emit(LoginSuccessState(social: Social.email));
      } else {
        emit(LoginErrorState(status: _status));
      }
    });

    on<LoginWithGoogleEvent>((event, emit) async {
      UserCredential? user = await signInWithGoogle();
      if (user != null) {
        SharedPreferences.getInstance().then((value) {
          value.setBool("login", false);
        });
        bool check = await initInfoUser();
        emit(LoginSuccessState(social: check ? Social.google : Social.newUser));
      } else {
        emit(LoginErrorState(status: _status));
      }
    });

    on<LoginWithFacebookEvent>((event, emit) async {
      bool check = await signInWithFacebook();
      if (check) {
        SharedPreferences.getInstance().then((value) {
          value.setBool("login", false);
        });
        bool check = await initInfoUser();
        emit(LoginSuccessState(
            social: check ? Social.facebook : Social.newUser));
      } else {
        emit(LoginErrorState(status: _status));
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // CODE MỚI: Dùng authenticate() thay vì signIn()
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email'], // Truyền scope tại đây
      );

      if (googleUser != null) {
        // 2. Lấy thông tin xác thực (chỉ còn idToken)
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        // 3. Tạo credential cho Firebase
        // LƯU Ý: Phiên bản mới không cần accessToken nữa, chỉ cần idToken
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: null, // Truyền null vào đây
        );

        // 4. Đăng nhập vào Firebase
        return await FirebaseAuth.instance.signInWithCredential(credential);
      }

    } catch (e) {
      // authenticate() sẽ ném lỗi nếu người dùng hủy đăng nhập, ta bắt lỗi tại đây
      _status = e.toString();
      print("Google Sign In Error: $_status");
      return null;
    }
  }

  Future<bool> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.accessToken != null) {
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(
          loginResult.accessToken!.tokenString);
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      return true;
    }

    return false;
  }

  Future<bool> signInWithEmailAndPassword(
      {required String emailAddress, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _status = e.code;
      return false;
    }
  }

  Future<bool> initInfoUser() async {
    bool check = true;
    var firestore = FirebaseFirestore.instance
        .collection("info")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await firestore.get().then((value) async {
      if (!value.exists) {
        await firestore.set(myuser.User(
            name: FirebaseAuth.instance.currentUser!.displayName.toString(),
            birthday: DateFormat("dd/MM/yyyy").format(DateTime.now()),
            money: 0,
            avatar: FirebaseAuth.instance.currentUser!.photoURL.toString())
            .toMap());
        check = false;
      }
    });
    return check;
  }
}