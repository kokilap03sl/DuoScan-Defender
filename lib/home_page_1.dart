import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'home_page_2';
import 'navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:mobile_scanner/mobile_scanner.dart' as mobile;
import 'package:provider/provider.dart';
import 'app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Page 1',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3C4E67),
        scaffoldBackgroundColor: const Color(0xFF6A99DA),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
          labelLarge: TextStyle(fontSize: 16),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.white54,
          thumbColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF3C4E67),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(fontFamily: 'Itim'),
          unselectedLabelStyle: TextStyle(fontFamily: 'Itim'),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1E1E2C),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
          labelLarge: TextStyle(fontSize: 16),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.white54,
          thumbColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E2C),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(fontFamily: 'Itim'),
          unselectedLabelStyle: TextStyle(fontFamily: 'Itim'),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage1(),
    );
  }
}

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
  double _zoomLevel = 50;
  bool _flashlightOn = false;
  final int _currentIndex = 0;
  String? extractedUrl;

  final ImagePicker _picker = ImagePicker();
  final mlkit.BarcodeScanner _barcodeScanner = mlkit.BarcodeScanner();
  final mobile.MobileScannerController _cameraController =
      mobile.MobileScannerController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playBeepSound() async {
    await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
  }

  Future<void> _showPermissionDialogAndPickImage() async {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final Color dialogTextColor =
        isLightMode ? const Color(0xFF3C4E67) : Colors.white;

    bool? allowed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Required",
            style: TextStyle(color: dialogTextColor)),
        content: Text("Allow DuoScan Defender to access gallery?",
            style: TextStyle(color: dialogTextColor)),
        actions: [
          TextButton(
            child: Text("Deny", style: TextStyle(color: dialogTextColor)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("Allow", style: TextStyle(color: dialogTextColor)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (allowed == true) {
      _simulateScanFromGallery();
    }
  }

  Future<void> _simulateScanFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;

    if (pickedFile != null) {
      log('Picked image path: ${pickedFile.path}');
      final inputImage = mlkit.InputImage.fromFilePath(pickedFile.path);
      final List<mlkit.Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        for (mlkit.Barcode barcode in barcodes) {
          log('Scanned value: ${barcode.rawValue}');
          if (!mounted) return;
          setState(() {
            extractedUrl = barcode.rawValue;
          });

          if (extractedUrl != null && mounted) {
            if (_flashlightOn) {
              _cameraController.toggleTorch();
              _flashlightOn = false;
            }

            // Check if beep sound is enabled before playing
            if (Provider.of<AppState>(context, listen: false).isBeepEnabled) {
              await _playBeepSound(); // 🎵 Play beep sound
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage2(url: extractedUrl!)),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scanned: ${barcode.rawValue}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No barcode found in the image')),
        );
      }
    }
  }

  void _toggleFlashlight() {
    setState(() {
      _flashlightOn = !_flashlightOn;
    });
    _cameraController.toggleTorch();
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    _cameraController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              child: const Padding(
                padding: EdgeInsets.only(left: 20, top: 60),
                child: Text(
                  'Home',
                  style: TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: mobile.MobileScanner(
                      controller: _cameraController,
                      onDetect: (capture) async {
                        final List<mobile.Barcode> barcodes = capture.barcodes;
                        for (final mobile.Barcode barcode in barcodes) {
                          final String? rawValue = barcode.rawValue;
                          if (rawValue != null) {
                            log('Scanned value: $rawValue');
                            if (mounted) {
                              if (_flashlightOn) {
                                _cameraController.toggleTorch();
                                _flashlightOn = false;
                              }

                              // Check if beep sound is enabled before playing
                              if (Provider.of<AppState>(context, listen: false)
                                  .isBeepEnabled) {
                                await _playBeepSound(); // 🎵 Play beep sound
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage2(url: rawValue)),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text("-", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: _zoomLevel,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        _zoomLevel = value;
                        _cameraController.setZoomScale(value / 100);
                      });
                    },
                  ),
                ),
                const Text("+", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.white),
                    onPressed: _showPermissionDialogAndPickImage,
                  ),
                  IconButton(
                    icon: Icon(
                      _flashlightOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFlashlight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: _currentIndex),
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
