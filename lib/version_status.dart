import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'navbar.dart';

class VersionStatusPage extends StatefulWidget {
  const VersionStatusPage({super.key});

  @override
  State<VersionStatusPage> createState() => _VersionStatusPageState();
}

class _VersionStatusPageState extends State<VersionStatusPage> {
  String currentVersion = 'v1.0.0';
  String statusMessage = 'Loading version status...';
  bool isUpToDate = true;

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
  }

  Future<void> _checkAppVersion() async {
    try {
      final response =
          await http.get(Uri.parse('http://your-api-url/version-status'));

      if (response.statusCode == 200) {
        final versionData = jsonDecode(response.body);
        final latestVersion = versionData['latest_version'];

        if (latestVersion == currentVersion) {
          setState(() {
            statusMessage = '✅ The app is up-to-date.';
            isUpToDate = true;
          });
        } else {
          setState(() {
            statusMessage = '⚠️ A new version is available: v$latestVersion';
            isUpToDate = false;
          });
        }
      } else {
        setState(() {
          statusMessage = 'Failed to check version. Please try again later.';
          isUpToDate = false;
        });
      }
    } catch (e) {
      log('Error checking version: $e');
      setState(() {
        statusMessage = 'Error connecting to server. Please try again later.';
        isUpToDate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Positioned(
                top: 60,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
              const Positioned(
                top: 58,
                left: 60,
                child: Text(
                  'Version Status',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '📦 You are using DuoScan Defender $currentVersion',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Last updated: April 1, 2025',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 2),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
