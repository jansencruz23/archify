import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScan;

  const QRScannerScreen({required this.onScan, Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  bool _permissionGranted = false;
  bool _flashlightEnabled = false;
  MobileScannerController _controller = MobileScannerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_permissionGranted) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
      });
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    } else {
      final result = await Permission.camera.request();

      setState(() {
        _permissionGranted = result.isGranted;
      });

    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Camera permission is required to scan QR codes. Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Sora',
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Sora',
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlashlight() async {
    setState(() {
      _flashlightEnabled = !_flashlightEnabled;
    });
    if (_flashlightEnabled) {
      _controller.toggleTorch();
    } else {
      _controller.toggleTorch();
    }
  }

  //Font responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join a day via QR',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_permissionGranted)
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    widget.onScan(barcode.rawValue!);
                    break;
                  }
                }
              },
            )
          else
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                child: Center(
                  child: Text(
                    'Camera permission is denied. Please allow access to use the QR scanner in settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: _getClampedFontSize(context, 0.03),
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 100),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black12.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      alignment: Alignment.center,
                      child: Text(
                        _permissionGranted
                            ? 'Find a code to scan'
                            : 'No camera found',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Sora',
                          fontSize: _getClampedFontSize(context, 0.04),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _permissionGranted
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black54,
                        width: 10.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_permissionGranted)
            Positioned(
              bottom: 60,
              left: MediaQuery.of(context).size.width * 0.5 - 30,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(90),
                ),
                padding: EdgeInsets.all(6),
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    _flashlightEnabled
                        ? Icons.flashlight_on_outlined
                        : Icons.flashlight_off_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: _toggleFlashlight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
