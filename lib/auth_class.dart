import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireAuthClass {
  static String? uid = FirebaseAuth.instance.currentUser!.uid;
  static Future<User?> loginEmailPassword(
      {required String email, required String password}) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      FireAuthClass.uid = user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("user not found");
      } else if (e.code == 'wrong-password') {
        print("wrong password");
      } else {
        print("auth error");
      }
    } catch (e) {
      print(e);
    }
    return user;
  }

  static Future<User?> registerEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("auth error");
    } catch (e) {
      print(e);
    }
    return user;
  }

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  static Future<User?> loginAnon() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("auth error");
    } catch (e) {
      print(e);
    }
    return user;
  }

  static Future<void> verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static Future<void> sendLoginEmailNoPassword({required String email}) async {
    var acs = ActionCodeSettings(
        url: 'https://rankingchatapp.page.link',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ios',
        androidPackageName: 'com.example.auth_app',
        androidInstallApp: true,
        androidMinimumVersion: '1');
    FirebaseAuth.instance
        .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
        .catchError(
            (onError) => print('Error sending email verification $onError'))
        .then((value) => print('Successfully sent email verification'));
  }

  static Future<User?> loginEmailAndLink({
    required String email,
    required Uri link,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailLink(
        email: email,
        emailLink: link.toString(),
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("auth error");
    } catch (e) {
      print(e);
    }
    return user;
  }

  static String? myVerificationId;
  static Future<void> loginPhoneNumber({required String phoneNumber}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        } else {
          print("auth error");
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        print("assigning verification id");
        myVerificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  static Future<User?> confirmLoginPhoneNumber(
      {required String verificationId, required String smsCode}) async {
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      user = (await auth.signInWithCredential(credential)).user;

      print("Successfully signed in UID: ${user?.uid}");
    } catch (e) {
      print("Failed to sign in: " + e.toString());
    }
    return user;
  }

  static Future<void> logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      print("auth error");
    } catch (e) {
      print(e);
    }
    await auth.signOut();
  }
}
