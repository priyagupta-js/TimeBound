import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_services.dart';
import 'chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  String? _selectedDuration;
  bool _isCreating = false;
  String? _currentUserName;

  final List<String> _durations = ['2 min', '1 hour', '6 hours', '1 day'];

  Duration _getDurationFromString(String duration) {
    switch (duration) {
      case '2 min':
        return const Duration(minutes: 2);
      case '1 hour':
        return const Duration(hours: 1);
      case '6 hours':
        return const Duration(hours: 6);
      case '1 day':
        return const Duration(days: 1);
      default:
        return const Duration(hours: 1);
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserName = prefs.getString('username');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _createGroup() async {
    if (_groupNameController.text.isEmpty ||
        _selectedDuration == null ||
        _currentUserName == null) return;

    setState(() => _isCreating = true);

    final expiryTime =
        DateTime.now().add(_getDurationFromString(_selectedDuration!));
    final groupId = await FirestoreService().createGroup(
      groupName: _groupNameController.text.trim(),
      expiryTime: expiryTime,
    );

    setState(() => _isCreating = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          groupId: groupId,
          groupName: _groupNameController.text.trim(),
          userName: _currentUserName!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDuration,
              items: _durations
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDuration = value),
              decoration: const InputDecoration(labelText: 'Expiry Duration'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCreating ? null : _createGroup,
              child: _isCreating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
