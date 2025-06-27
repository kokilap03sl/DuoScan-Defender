import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'user_page.dart';
import 'navbar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'package:flutter/services.dart';

class HistoryLogPage extends StatefulWidget {
  const HistoryLogPage({super.key});

  @override
  State<HistoryLogPage> createState() => _HistoryLogPageState();
}

class _HistoryLogPageState extends State<HistoryLogPage> {
  List<Map<String, dynamic>> urlHistory = [];
  String filter = 'All';

  List<Map<String, dynamic>> get filteredUrls {
    if (filter == 'All') {
      return urlHistory;
    } else {
      return urlHistory.where((entry) {
        final type = entry['type'];
        if (type == null) return false;
        return type.toLowerCase() == filter.toLowerCase();
      }).toList();
    }
  }

  static const browserPackages = {
    'Chrome': 'com.android.chrome',
    'Firefox': 'org.mozilla.firefox',
    'Edge': 'com.microsoft.emmx',
    'Opera': 'com.opera.browser',
    'Brave': 'com.brave.browser',
    'Samsung Internet': 'com.sec.android.app.sbrowser',
  };

  static const platform = MethodChannel('com.yourapp/browser_launcher');

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final deviceId = await _getDeviceId();
      final response = await http.get(
        Uri.parse('http://192.168.1.3:3000/get-history/$deviceId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> rawHistory =
            List<Map<String, dynamic>>.from(data['history']);

        final List<Map<String, dynamic>> typedHistory = rawHistory.map((entry) {
          final String content = entry['scanned_result'] ?? '';
          final String type = _detectType(content);
          return {
            ...entry,
            'scanned_url': content, // for consistency in the UI
            'type': type,
            'scanned_time':
                entry['scanned_time'] ?? '', // <-- Ensure time is present
          };
        }).toList();

        setState(() {
          urlHistory = typedHistory;
        });
      } else {
        log('Failed to fetch history. Status: ${response.statusCode}');
      }
    } catch (error) {
      log('Failed to fetch URL history: $error');
    }
  }

  String _detectType(String content) {
    final uri = Uri.tryParse(content);
    if (content.startsWith('http://') || content.startsWith('https://')) {
      return 'URL';
    } else if (content.startsWith('WIFI:')) {
      return 'Wi-Fi';
    } else if (content.contains('@') && content.contains('.')) {
      return 'Email';
    } else if (RegExp(r'^\d{8,13}$').hasMatch(content)) {
      return 'Product';
    } else if (uri == null || !uri.hasScheme) {
      return 'Text';
    } else {
      return 'Text';
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchHistory();
  }

  void _deleteUrl(int index) {
    setState(() {
      urlHistory.removeAt(index);
    });
  }

  Future<void> _launchUrl(String url) async {
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

    try {
      final deviceId = await _getDeviceId();
      final response = await http.post(
        Uri.parse('http://192.168.1.3:3000/update-history'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': deviceId,
          'visited_url': url,
        }),
      );

      if (response.statusCode == 200) {
        _fetchHistory();
      } else {
        log('Failed to update history. Status: ${response.statusCode}');
      }
    } catch (error) {
      log('Failed to update history after visiting URL: $error');
    }
  }

  String _formatTime(String time) {
    // time is expected to be in HH:mm:ss format
    try {
      final DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      log('Error formatting time: $e');
      return time;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final DateTime parsedDate = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      log('Error formatting date: $e');
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
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
                          builder: (context) => const UserPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'History Log',
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
            DropdownButton<String>(
              value: filter,
              onChanged: (value) {
                setState(() {
                  filter = value!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'URL', child: Text('URL')),
                DropdownMenuItem(value: 'Wi-Fi', child: Text('Wi-Fi')),
                DropdownMenuItem(value: 'Text', child: Text('Text')),
                DropdownMenuItem(value: 'Product', child: Text('Product')),
                DropdownMenuItem(value: 'Email', child: Text('Email')),
              ],
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black,
              ),
              dropdownColor: Theme.of(context).primaryColor,
              underline: const SizedBox(),
            ),
            const SizedBox(height: 20),
            filteredUrls.isEmpty
                ? Center(
                    child: Text(
                      'No URL history available.',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredUrls.length,
                      itemBuilder: (context, index) {
                        final url = filteredUrls[index];
                        return Card(
                          color: Theme.of(context).primaryColor,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () => _launchUrl(url['scanned_url']),
                            title: Text(
                              url['scanned_url'],
                              style: TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 16,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            subtitle: Text(
                              'Type: ${url['type']}\n'
                              'Date: ${_formatDate(url['scanned_date'])}\n'
                              'Time: ${_formatTime(url['scanned_time'])}\n'
                              'Status: ${url['scan_status']}',
                              style: TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 14,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Colors.black,
                              ),
                            ),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _deleteUrl(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
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
