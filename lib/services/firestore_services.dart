import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new group with name, creator name, and expiry time
  Future<String> createGroup({
    required String groupName,
    required String creatorName,
    required Duration expiryDuration,
  }) async {
    final groupId = _firestore.collection('groups').doc().id;
    final now = DateTime.now();
    final expiryTime = now.add(expiryDuration);

    await _firestore.collection('groups').doc(groupId).set({
      'name': groupName,
      'creator': creatorName,
      'createdAt': now,
      'expiry': expiryTime,
      'groupId': groupId,
    });

    return groupId;
  }

  /// Join a group by checking if it exists and not expired
  Future<bool> checkGroupExists(String groupId) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();

    if (!doc.exists) return false;

    final expiry = (doc['expiry'] as Timestamp).toDate();
    return expiry.isAfter(DateTime.now());
  }

  /// Send a message to a group
  Future<void> sendMessage({
    required String groupId,
    required String sender,
    required String message,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add({
      'sender': sender,
      'message': message,
      'timestamp': DateTime.now(),
    });
  }

  /// (Optional) Get group name and expiry
  Future<Map<String, dynamic>?> getGroupDetails(String groupId) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}
