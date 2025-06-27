import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'dart:io';
import 'themes/theme_notifier.dart';
import 'navbar.dart';
import 'history_log.dart' as history_log;
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'app_state.dart';
import 'package:flutter/services.dart';

// Function to get the device ID
Future<String> _getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    var androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else if (Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor!;
  } else {
    return 'unknown_device';
  }
}

// Function to convert rating to a string
String getRatingString(int rating) {
  switch (rating) {
    case 1:
      return '1 Star';
    case 2:
      return '2 Stars';
    case 3:
      return '3 Stars';
    case 4:
      return '4 Stars';
    case 5:
      return '5 Stars';
    default:
      return '1 Star';
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _selectedTheme = 'Light Mode';
  final TextEditingController _feedbackController = TextEditingController();

  static const browserPackages = {
    'Chrome': 'com.android.chrome',
    'Firefox': 'org.mozilla.firefox',
    'Edge': 'com.microsoft.emmx',
    'Opera': 'com.opera.browser',
    'Brave': 'com.brave.browser',
    'Samsung Internet': 'com.sec.android.app.sbrowser',
  };

  static const platform = MethodChannel('com.yourapp/browser_launcher');

  Future<void> _launchUserEducationUrl(String url) async {
    final appState = Provider.of<AppState>(context, listen: false);
    String? engine = appState.selectedSearchEngine;
    if (engine == null || engine == 'Search Engines') {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      String? package = browserPackages[engine];
      try {
        await platform.invokeMethod('launchBrowser', {
          'url': url,
          'package': package,
        });
      } catch (e) {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = MediaQuery.of(context).size.height * 0.10;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.50;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThemeDropdown(buttonWidth, buttonHeight),
                  const SizedBox(height: 20),
                  _buildButton('User Education', () {
                    _launchUserEducationUrl('https://krebsonsecurity.com/');
                  }),
                  const SizedBox(height: 20),
                  _buildButton('User Feedback', () {
                    _showFeedbackDialog(context);
                  }),
                  const SizedBox(height: 20),
                  _buildButton('History Log', () {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const history_log.HistoryLogPage(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 160,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Positioned(
          top: 58,
          left: 16,
          child: Text(
            'User',
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'Itim',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeDropdown(double buttonWidth, double buttonHeight) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<String>(
            value: _selectedTheme,
            style: TextStyle(
              fontFamily: 'Itim',
              fontSize: 20,
              color: Colors.white,
            ),
            iconEnabledColor: Colors.white,
            dropdownColor: Theme.of(context).primaryColor,
            isExpanded: true,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: 'Light Mode',
                child: Text(
                  'Light Mode',
                  style: TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'Dark Mode',
                child: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
                final isDarkMode = value == 'Dark Mode';
                Provider.of<ThemeNotifier>(context, listen: false)
                    .switchTheme(isDarkMode);
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    final double buttonHeight = MediaQuery.of(context).size.height * 0.10;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.50;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Itim',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    int rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Theme.of(context).primaryColor,
          title: Text(
            "Liking DuoScan Defender?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFF3C4E67)
                  : Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Help us improve by leaving a quick review!",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF3C4E67)
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Type your feedback here...",
                  border: const OutlineInputBorder(),
                  fillColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                  filled: true,
                ),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    icon: Icon(
                      rating > index ? Icons.star : Icons.star_border,
                      size: 30,
                      color: Colors.orange,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _feedbackController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF3C4E67)
                      : Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (rating == 0 && _feedbackController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a message or rating.'),
                    ),
                  );
                  return;
                }
                final message = _feedbackController.text.trim();
                final deviceId = await _getDeviceId();

                // Prepare the data based on what was provided
                bool messageOnly = message.isNotEmpty && rating == 0;
                bool ratingOnly = message.isEmpty && rating != 0;
                bool bothProvided = message.isNotEmpty && rating != 0;

                final url =
                    Uri.parse('http://192.168.1.3:3000/api/user_feedback');

                try {
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'device_id': deviceId,
                      'message': messageOnly || bothProvided ? message : null,
                      'rating': ratingOnly || bothProvided
                          ? getRatingString(rating)
                          : null,
                      'messageOnly': messageOnly,
                      'ratingOnly': ratingOnly,
                      'bothProvided': bothProvided,
                    }),
                  );

                  if (response.statusCode == 200) {
                    log('Feedback sent successfully: ${response.body}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thanks for your feedback!'),
                      ),
                    );
                    _feedbackController.clear();
                    Navigator.of(context).pop();
                  } else {
                    log('Failed to send feedback: ${response.statusCode} ${response.body}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Failed to send feedback. Please try again later.'),
                      ),
                    );
                  }
                } catch (e) {
                  log('Error sending feedback: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error occurred while sending feedback.'),
                    ),
                  );
                }
              },
              child: Text(
                "Send",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF3C4E67)
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height);
    final secondControlPoint = Offset(size.width * 3 / 4, size.height);
    final secondEndPoint = Offset(size.width, size.height - 30);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
