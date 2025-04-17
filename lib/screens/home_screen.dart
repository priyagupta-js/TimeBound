// 📁 home_screen.dart
import 'package:flutter/material.dart';
import 'package:timebound/screens/create_group.dart';
import 'package:timebound/screens/join_group.dart';
import 'package:timebound/screens/existing_group.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const CreateGroupScreen(),
    const JoinGroupScreen(),
    ExistingGroupScreen(),
  ];

  // 🌊 Aqua Fresh Theme Colors
  final Color primaryColor = const Color(0xFF00BFA6); // Teal
  final Color accentColor = const Color(0xFFFFC400); // Bright Yellow
  final Color backgroundColor = const Color(0xFFF0F4F8); // Soft off-white
  final Color textColor = const Color(0xFF263238); // Blue Grey

  ButtonStyle get buttonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'TimeBound',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Theme(
            data: Theme.of(context).copyWith(
              elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
            ),
            child: _tabs[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (value) => setState(() => _selectedIndex = value),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.group_add), label: "Create Group"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Join Group"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: "Existing Group"),
        ],
      ),
    );
  }
}
