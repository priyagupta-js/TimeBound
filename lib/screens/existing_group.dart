// 📁 existing_group_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_services.dart';
import 'chat_screen.dart';

class ExistingGroupScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ExistingGroupScreen({super.key});

  Future<String?> _promptForName(BuildContext context) async {
    String userName = "";
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter your name"),
          content: TextField(
            onChanged: (value) => userName = value,
            decoration: const InputDecoration(hintText: "e.g., Alex"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, userName),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
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
              onTap: isExpired
                  ? null
                  : () async {
                      final userName = await _promptForName(context);
                      if (userName == null || userName.isEmpty) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            groupId: groupId,
                            groupName: groupName,
                            userName: userName,
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
