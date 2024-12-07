import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScan;

  const QRScannerScreen({required this.onScan, super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with WidgetsBindingObserver {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions(); // Re-check permissions when the app resumes
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.status;
    setState(() {
      _permissionGranted = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_permissionGranted)
            MobileScanner(
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
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 10.0),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
