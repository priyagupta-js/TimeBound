import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new group
  Future<String> createGroup({
    required String groupName,
    required DateTime expiryTime,
  }) async {
    final docRef = _firestore.collection('groups').doc();
    await docRef.set({
      'groupId': docRef.id,
      'name': groupName,
      'expiry': Timestamp.fromDate(expiryTime),
      'createdAt': Timestamp.now(),
    });
    return docRef.id;
  }

  // Get group details by group code
  Future<DocumentSnapshot?> getGroup(String groupId) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();
    if (doc.exists) {
      return doc;
    }
    return null;
  }

  // Send a chat message
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
      'timestamp': Timestamp.now(),
    });
  }

  // Stream chat messages
  Stream<QuerySnapshot> getMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get all groups
  Stream<QuerySnapshot> getAllGroups() {
    return _firestore.collection('groups').orderBy('createdAt').snapshots();
  }
}
