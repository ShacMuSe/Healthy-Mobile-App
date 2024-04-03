import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(MaterialApp(
    title: 'Barcode Scanner',
    home: MyApp(),
  ));
}






class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  String _scanBarcodeResult = '';

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6656',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }



  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Barcode Scan'),
    ),
    body: Builder(
      builder: (context) => Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => scanBarcodeNormal(),
              child: const Text('Start scan barcode'),
            ),
            Text('Scan barcode Result: $_scanBarcodeResult\n')
          ],
        ),
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              scanBarcodeNormal();
              break;
            case 1:
              // Handle Search option
              break;
            case 2:
              // Handle Profile option
              break;
          }
        },
      ),
  );
}
