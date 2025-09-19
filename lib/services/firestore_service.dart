import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Users Collection
  static CollectionReference get usersCollection =>
      _firestore.collection('users');

  // Trips Collection
  static CollectionReference get tripsCollection =>
      _firestore.collection('trips');

  // Create or update user profile
  static Future<void> createUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      print('�� Creating user profile in Firestore...');
      print('📧 Email: $email');
      print('🆔 UID: $uid');

      final userData = {
        'uid': uid,
        'email': email,
        'displayName': displayName ?? '',
        'photoURL': photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('📝 User data: $userData');

      await usersCollection.doc(uid).set(userData, SetOptions(merge: true));

      print('✅ User profile created successfully in Firestore!');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  // Get user profile
  static Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      return await usersCollection.doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String uid,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (data != null) {
        data['updatedAt'] = FieldValue.serverTimestamp();
        await usersCollection.doc(uid).update(data);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Create trip
  static Future<DocumentReference> createTrip({
    required Map<String, dynamic> tripData,
  }) async {
    try {
      final String? userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      tripData['userId'] = userId;
      tripData['createdAt'] = FieldValue.serverTimestamp();
      tripData['updatedAt'] = FieldValue.serverTimestamp();

      return await tripsCollection.add(tripData);
    } catch (e) {
      throw Exception('Failed to create trip: ${e.toString()}');
    }
  }

  // Get user trips
  static Stream<QuerySnapshot> getUserTrips() {
    final String? userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return tripsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get trip by ID
  static Future<DocumentSnapshot> getTrip(String tripId) async {
    try {
      return await tripsCollection.doc(tripId).get();
    } catch (e) {
      throw Exception('Failed to get trip: ${e.toString()}');
    }
  }

  // Update trip
  static Future<void> updateTrip({
    required String tripId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await tripsCollection.doc(tripId).update(data);
    } catch (e) {
      throw Exception('Failed to update trip: ${e.toString()}');
    }
  }

  // Delete trip
  static Future<void> deleteTrip(String tripId) async {
    try {
      await tripsCollection.doc(tripId).delete();
    } catch (e) {
      throw Exception('Failed to delete trip: ${e.toString()}');
    }
  }

  // Search trips
  static Future<QuerySnapshot> searchTrips({
    required String searchTerm,
    int limit = 20,
  }) async {
    try {
      final String? userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return await tripsCollection
          .where('userId', isEqualTo: userId)
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .where('title', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .limit(limit)
          .get();
    } catch (e) {
      throw Exception('Failed to search trips: ${e.toString()}');
    }
  }

  // Batch operations
  static WriteBatch batch() => _firestore.batch();

  // Transaction
  static Future<T> runTransaction<T>(
    TransactionHandler<T> updateFunction, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _firestore.runTransaction(updateFunction, timeout: timeout);
  }
}
