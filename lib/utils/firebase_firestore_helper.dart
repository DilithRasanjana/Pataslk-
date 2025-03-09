import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves (or updates) user data in the specified [collection] using [uid] as the document ID.
  Future<void> saveUserData({
    required String collection,
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(uid).set(data, SetOptions(merge: true));
  }


