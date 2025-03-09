import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initiates phone number verification.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto sign in on Android if auto-retrieval succeeds.
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Optional: Handle auto-retrieval timeout if needed.
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }
  /// Signs in using the provided [verificationId] and [smsCode].
  /// Returns a map with keys 'user' and 'isNewUser'.
  Future<Map<String, dynamic>?> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      return {"user": userCredential.user, "isNewUser": isNewUser};
    } catch (e) {
      print("Error in signInWithOTP: $e");
      return null;
    }
  }

  /// Signs in using Google.
  /// Returns a map with keys 'user' and 'isNewUser'.
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      return {"user": userCredential.user, "isNewUser": isNewUser};
    } catch (e) {
      print("Error in signInWithGoogle: $e");
      return null;
    }
  }
}
