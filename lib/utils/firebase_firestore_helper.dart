import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for Firebase Firestore operations
class FirestoreHelper {
  // Firebase Firestore: Initialize firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves (or updates) user data in the specified [collection] using [uid] as the document ID.
  Future<void> saveUserData({
    required String collection,
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    // Firebase Firestore: Write document with merge option to prevent overwriting existing fields
    await _firestore.collection(collection).doc(uid).set(data, SetOptions(merge: true));
  }

  /// Checks if a user exists in [collection] with the given [email].
  Future<bool> doesUserExist({
    required String collection,
    required String email,
  }) async {
    // Firebase Firestore: Query documents with where filter
    QuerySnapshot snapshot = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Checks if a customer exists in the "customers" collection with the given [phone].
  Future<bool> doesCustomerExistByPhone({required String phone}) async {
    // Firebase Firestore: Query customers collection by phone number
    QuerySnapshot snapshot = await _firestore
        .collection('customers')
        .where('phone', isEqualTo: phone)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Checks if a service provider exists in the "serviceProviders" collection with the given [phone].
  Future<bool> doesServiceProviderExistByPhone({required String phone}) async {
    // Firebase Firestore: Query serviceProviders collection by phone number
    QuerySnapshot snapshot = await _firestore
        .collection('serviceProviders')
        .where('phone', isEqualTo: phone)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Returns a stream of a user document from the given [collection] and [uid].
  Stream<DocumentSnapshot> getUserStream({
    required String collection,
    required String uid,
  }) {
    // Firebase Firestore: Create real-time document stream
    return _firestore.collection(collection).doc(uid).snapshots();
  }
}
