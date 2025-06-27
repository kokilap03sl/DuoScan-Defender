import 'package:flutter/material.dart';
import 'home_page_1.dart';
import 'user_page.dart';
import 'settings_page.dart' as settings;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomNavBar({super.key, required this.currentIndex});

  // Function to send data to the backend when the user interacts with the navbar
  Future<void> _sendNavigationDataToBackend(int index) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:3000/app-data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'selectedTab': index}),
      );

      if (response.statusCode == 200) {
        // Handle success
        log('Navigation data sent successfully!');
      } else {
        // Handle server error
        log('Failed to send navigation data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network error
      log('Error sending navigation data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      onTap: (int index) async {
        if (index == currentIndex) return;

        await _sendNavigationDataToBackend(index);

        if (!context.mounted) return;
        switch (index) {
          case 0:
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage1()),
            );
            break;
          case 1:
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserPage()),
            );
            break;
          case 2:
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const settings.SettingsPage()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
