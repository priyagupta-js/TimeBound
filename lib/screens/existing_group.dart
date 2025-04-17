// 📁 existing_group_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_services.dart';
import 'chat_screen.dart';

class ExistingGroupScreen extends StatefulWidget {
  const ExistingGroupScreen({super.key});

  @override
  State<ExistingGroupScreen> createState() => _ExistingGroupScreenState();
}

class _ExistingGroupScreenState extends State<ExistingGroupScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserName = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = snapshot.data?.docs;

        if (groups == null || groups.isEmpty) {
          return const Center(child: Text("Nothing to show"));
        }

        final activeGroups = groups.where((group) {
          final expiry = (group['expiry'] as Timestamp).toDate();
          return DateTime.now().isBefore(expiry);
        }).toList();

        final expiredGroups = groups.where((group) {
          final expiry = (group['expiry'] as Timestamp).toDate();
          return DateTime.now().isAfter(expiry);
        }).toList();

        final sortedGroups = [...activeGroups, ...expiredGroups];

        return ListView.builder(
          itemCount: sortedGroups.length,
          itemBuilder: (context, index) {
            final group = sortedGroups[index];
            final groupName = group['name'];
            final groupId = group['groupId'];
            final expiry = (group['expiry'] as Timestamp).toDate();
            final isExpired = DateTime.now().isAfter(expiry);

            return ListTile(
              title: Text(
                groupName,
                style: TextStyle(color: isExpired ? Colors.grey : Colors.black),
              ),
              subtitle: Text(
                "Group ID: $groupId",
                style:
                    TextStyle(color: isExpired ? Colors.grey : Colors.black54),
              ),
              trailing: isExpired
                  ? const Icon(Icons.lock, color: Colors.grey)
                  : const Icon(Icons.chat),
              enabled: !isExpired,
              onTap: isExpired || _currentUserName == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            groupId: groupId,
                            groupName: groupName,
                            userName: _currentUserName!,
                          ),
                        ),
                      );
                    },
            );
          },
        );
      },
    );
  }
}
