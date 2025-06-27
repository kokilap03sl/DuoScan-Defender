import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'app_state.dart';
import 'settings_page.dart';
import 'navbar.dart';
import 'services/api_service.dart';

class ManagePermissionsPage extends StatefulWidget {
  const ManagePermissionsPage({super.key});

  @override
  State<ManagePermissionsPage> createState() => _ManagePermissionsPageState();
}

class _ManagePermissionsPageState extends State<ManagePermissionsPage> {
  static const platform = MethodChannel('com.yourapp/search_engine_detection');

  List<String> _installedSearchEngines = [];
  String? _selectedSearchEngine;
  bool _isAutoCopyEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _fetchInstalledSearchEngines();
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? 'unknown_android_id';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios_id';
    }
    return 'unsupported_platform';
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('preferred_search_engine');

    setState(() {
      _isAutoCopyEnabled = prefs.getBool('autoCopyEnabled') ?? false;
      _selectedSearchEngine = (stored == null || stored == 'Not selected')
          ? 'Search Engine'
          : stored;
    });

    Provider.of<AppState>(context, listen: false)
        .setSelectedSearchEngine(_selectedSearchEngine!);
    Provider.of<AppState>(context, listen: false)
        .toggleBeep(prefs.getBool('beepSoundEnabled') ?? true);
  }

  Future<void> _savePreferredSearchEngine(String engine) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('preferred_search_engine', engine);
    Provider.of<AppState>(context, listen: false)
        .setSelectedSearchEngine(engine);

    setState(() => _selectedSearchEngine = engine);
    await _updatePermissions();
  }

  Future<void> _updatePermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final appState = Provider.of<AppState>(context, listen: false);
    final deviceId = await _getDeviceId();

    await prefs.setBool('beepSoundEnabled', appState.isBeepEnabled);
    await prefs.setBool('autoCopyEnabled', _isAutoCopyEnabled);

    final engineForStorage = (_selectedSearchEngine == 'Search Engine')
        ? 'Not selected'
        : _selectedSearchEngine!;

    final data = {
      'device_id': deviceId,
      'beep_enabled': appState.isBeepEnabled,
      'preferred_search_engine': engineForStorage,
      'auto_copy_to_clipboard': _isAutoCopyEnabled,
    };

    try {
      // Directly use the correct IP address for the backend as in server.js
      await ApiService.post('api/manage_permissions/update', data);
    } catch (_) {}
  }

  Future<void> _fetchInstalledSearchEngines() async {
    try {
      final List<dynamic> searchEngines =
          await platform.invokeMethod('getInstalledSearchEngines');
      List<String> engines = searchEngines
          .where((s) => s != null && s.toString().trim().isNotEmpty)
          .map((s) => s.toString())
          .toSet()
          .toList();

      if (Theme.of(context).platform == TargetPlatform.android &&
          !engines.contains('Samsung Internet')) {
        engines.add('Samsung Internet');
      } else if (Theme.of(context).platform == TargetPlatform.iOS &&
          !engines.contains('Safari')) {
        engines.add('Safari');
      }

      engines.remove('Search Engine');
      engines.insert(0, 'Search Engine');

      setState(() {
        _installedSearchEngines = engines;
        _selectedSearchEngine ??= engines.first;
      });
    } on PlatformException catch (e) {
      debugPrint('Error fetching search engines: $e');
      setState(() {
        _installedSearchEngines = ['Search Engine'];
        _selectedSearchEngine ??= 'Search Engine';
      });
    }
  }

  Future<void> _toggleAutoCopyToClipboard(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoCopyEnabled', value);
    setState(() => _isAutoCopyEnabled = value);
    await _updatePermissions();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final double buttonHeight = MediaQuery.of(context).size.height * 0.10;
    final double buttonWidth = MediaQuery.of(context).size.width * 0.80;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140.0),
        child: ClipPath(
          clipper: WaveClipper(),
          child: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(left: 10, top: 30),
              child: Row(
                children: [
                  IconButton(
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
                  const SizedBox(width: 10),
                  const Text(
                    'Manage Permissions',
                    style: TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Beep when scan successful',
                  style: TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 18,
                  ),
                ),
                Switch(
                  value: appState.isBeepEnabled,
                  onChanged: (bool value) {
                    appState.toggleBeep(value);
                    _updatePermissions();
                  },
                  activeColor: Theme.of(context).primaryColor,
                  activeTrackColor:
                      Theme.of(context).primaryColor.withOpacity(0.5),
                  inactiveThumbColor: Theme.of(context).primaryColor,
                  inactiveTrackColor:
                      Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: 30),
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
                  child: (_installedSearchEngines.isEmpty)
                      ? const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No search engines detected on this device.',
                            style: TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : DropdownButton<String>(
                          value: _selectedSearchEngine,
                          style: TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.black,
                          ),
                          iconEnabledColor: Colors.white,
                          dropdownColor: Theme.of(context).primaryColor,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _installedSearchEngines.map((engine) {
                            return DropdownMenuItem<String>(
                              value: engine,
                              child: Text(
                                engine,
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _savePreferredSearchEngine(newValue);
                            }
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Auto-copied to clipboard',
                  style: TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 18,
                  ),
                ),
                Switch(
                  value: _isAutoCopyEnabled,
                  onChanged: (bool value) {
                    _toggleAutoCopyToClipboard(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                  activeTrackColor:
                      Theme.of(context).primaryColor.withOpacity(0.5),
                  inactiveThumbColor: Theme.of(context).primaryColor,
                  inactiveTrackColor:
                      Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
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
