import 'package:flutter/material.dart';
import 'privacy_policy.dart' as privacy;
import 'new_impovements.dart';
import 'version_status.dart' as version;
import 'manage_permissions.dart';
import 'navbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String _selectedUpdate = 'Updates';

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = MediaQuery.of(context).size.height * 0.10;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.50;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160.0),
        child: ClipPath(
          clipper: WaveClipper(),
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 60),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildButton('Privacy Policy', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const privacy.PrivacyPolicyPage(),
                ),
              );
            }),
            const SizedBox(height: 20),
            _buildButton('Manage Permissions', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManagePermissionsPage(),
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
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
                    value: _selectedUpdate,
                    style: TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    iconEnabledColor: Colors.white,
                    dropdownColor: Theme.of(context).primaryColor,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: 'Updates',
                        child: _dropdownMenuItemText('Updates'),
                      ),
                      DropdownMenuItem(
                        value: 'Version Status',
                        child: _dropdownMenuItemText('Version Status'),
                      ),
                      DropdownMenuItem(
                        value: 'New Improvements',
                        child: _dropdownMenuItemText('New Improvements'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedUpdate = value!);
                      if (value == 'Version Status') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const version.VersionStatusPage(),
                          ),
                        );
                      } else if (value == 'New Improvements') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewImprovementsPage(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    final double buttonHeight = MediaQuery.of(context).size.height * 0.10;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.50;

    return SizedBox(
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownMenuItemText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Itim',
          color: Colors.white,
        ),
      ),
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
