import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'navbar.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendPrivacyPolicyVisitDataToBackend() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:3000/privacy-policy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pageVisited': 'PrivacyPolicyPage'}),
      );

      if (response.statusCode == 200) {
        log('Privacy policy page visit data sent successfully!');
      } else {
        log('Failed to send privacy policy page visit data: ${response.statusCode}');
      }
    } catch (error) {
      log('Error sending privacy policy page visit data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    _sendPrivacyPolicyVisitDataToBackend();

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
                  'Privacy Policy',
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
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 8,
              radius: const Radius.circular(5),
              scrollbarOrientation: ScrollbarOrientation.right,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('📅 Effective Date: April 1st 2025'),
                      const SizedBox(height: 10),
                      _sectionText(
                        'At DuoScan Defender, we value your privacy. This policy explains how we collect, use, and protect your personal information while using our app.',
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('🔍 1. Information We Collect'),
                      _sectionText(
                        '• Usage Data: We collect app usage data, including device information and how you interact with the app.\n'
                        '• Link Data: We process URLs from scanned QR codes and barcodes to check for safety, but do not store the data unless needed for troubleshooting.',
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('⚙️ 2. How We Use Your Information'),
                      _sectionText(
                        'We use your information to:\n'
                        '• Enhance and improve app functionality.\n'
                        '• Ensure security and prevent misuse.\n'
                        '• Provide updates, support, and communication.',
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('🔒 3. Data Sharing'),
                      _sectionText(
                        'We do not sell or share your personal data with third parties. If data is shared with partners to help run the app, they are under strict confidentiality agreements.',
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('🛡️ 4. Data Security'),
                      _sectionText(
                        'We take appropriate steps to safeguard your data. However, no method of transmission over the internet is 100% secure.',
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('🧍 5. Your Rights'),
                      _sectionText(
                        'You have the right to access, update, or delete your personal information by reaching out to us at:',
                      ),
                      const SizedBox(height: 5),
                      _emailWithIcon(),
                      const SizedBox(height: 20),
                      _sectionTitle('🔁 6. Changes to This Policy'),
                      _sectionText(
                        'We may update our Privacy Policy periodically. By continuing to use the app, you agree to the updated terms.',
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('📬 7. Contact Us'),
                      _sectionText(
                          'For any questions or concerns, contact us at:'),
                      const SizedBox(height: 5),
                      _emailWithIcon(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _emailWithIcon() {
    return GestureDetector(
      onTap: () async {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: 'kokilaperera16@gmail.com',
          query: _encodeQueryParameters(<String, String>{
            'subject': 'User Inquiry from DuoScan Defender',
          }),
        );
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        } else {
          throw 'Could not launch $emailLaunchUri';
        }
      },
      child: Row(
        children: [
          const Icon(Icons.email, size: 18, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            'duoscandefender@gmail.com',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
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
