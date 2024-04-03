import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.green),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _nutritionFacts = []; // Empty list initially
  List<String> _nutritionElementNames = [
    "Fat",
    "Saturated Fat",
    "Carbohydrates",
    "Sugars",
    "Fiber",
    "Protein",
    "Salt"
  ];
  String _productName = '';
  String _productImage = '';
  String _responseBody = ''; // Added variable to store the response body
  String _productClassification = '';
  String _scanBarcodeResult = '';

  Future<void> fetchData() async {
    final url = Uri.parse('https://barcodes1.p.rapidapi.com/?query=$_scanBarcodeResult'); // Use $_responseBody here
    final headers = {
      "X-RapidAPI-Key": "1a310970f1msh212a8f970e5a376p14a45cjsnf297dcdc4880",
      "X-RapidAPI-Host": "barcodes1.p.rapidapi.com"
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nutritionFactsStr = data['product']['nutrition_facts'];
        final productName = data['product']['title'];
        final productImage = data['product']['images'][0];



        // Extract nutrition facts from the API response and update _nutritionFacts list
        setState(() {
          _nutritionFacts = [
            "Fat ${data['fat']} g",
            "Saturated Fat ${data['saturated_fat']} g",
            "Carbohydrates ${data['carbohydrates']} g",
            "Sugars ${data['sugars']} g",
            "Fiber ${data['fiber']} g",
            "Protein ${data['protein']} g",
            "Salt ${data['salt']} g"
          ];
        });

        // Classify the product
        _classifyProduct(nutritionFactsStr);

        setState(() {
          _nutritionFacts = nutritionFactsStr.split(',').map<String>((fact) => fact.toString().trim()).toList();
          _productName = productName;
          _productImage = productImage;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error: $error');


      // Display error message as a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data. Please try again later.'),
        ),
      );
    }
  }

  // Function to classify each nutrient as "good", "bad", or "unknown"
  String classifyNutrient(String nutrient, String nutrientName) {
  try {
    switch (nutrientName) {
      case 'Fat':
        double fatValue = double.parse(nutrient.split(" ")[1].replaceAll('g', ''));
        if (fatValue <= 10) {
          return 'Good'; // Low fat content is considered good
        } else if (fatValue > 20) {
          return 'Bad'; // High fat content is considered bad
        }
        break;
      case 'Saturated Fat':
        double saturatedFatValue = double.parse(nutrient.split(" ")[2].replaceAll('g', ''));
        if (saturatedFatValue <= 5) {
          return 'Good'; // Low saturated fat content is considered good
        } else if (saturatedFatValue > 10) {
          return 'Bad'; // High saturated fat content is considered bad
        }
        break;
      case 'Sugars':
        double sugarsValue = double.parse(nutrient.split(" ")[1].replaceAll('g', ''));
        if (sugarsValue <= 5) {
          return 'Good'; // Low sugar content is considered good
        } else if (sugarsValue > 15) {
          return 'Bad'; // High sugar content is considered bad
        }
        break;
      // Add more cases for other nutrients if needed
    }
    return 'Unknown'; // If nutrient doesn't match any criteria, classify as unknown
  } catch (e) {
    print('Error parsing nutrient string: $nutrient');
    print(e);
    return 'Unknown';
  }
}


  // Function to get the color for the circle based on nutrient classification
  Color getColorForNutrientClassification(String classification) {
    switch (classification) {
      case 'Good':
        return Colors.green;
      case 'Bad':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }







  



  // Function to classify the product based on fat and sugar content
  void _classifyProduct(String nutritionFactsStr) {
    // Extract fat and sugar content from the nutrition facts string
    final fatRegex = RegExp(r'Fat ([\d.]+) g');
    final sugarRegex = RegExp(r'Sugars ([\d.]+) g');

    final fatMatch = fatRegex.firstMatch(nutritionFactsStr);
    final sugarMatch = sugarRegex.firstMatch(nutritionFactsStr);

    if (fatMatch != null && sugarMatch != null) {
      final fat = double.tryParse(fatMatch.group(1) ?? '0.0') ?? 0.0;
      final sugar = double.tryParse(sugarMatch.group(1) ?? '0.0') ?? 0.0;


      // Define thresholds for fat and sugar content
      const double maxFatThreshold = 5.0; // Define your threshold
      const double maxSugarThreshold = 10.0; // Define your threshold

      // Classify the product based on thresholds
      if (fat <= maxFatThreshold && sugar <= maxSugarThreshold) {
        _productClassification = 'Good';
      } else {
        _productClassification = 'Bad';
      }
    } else {
      _productClassification = 'Unknown';
    }
  }


  

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
      fetchData();
      _scanBarcodeResult = barcodeScanRes;
    });
  }





  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage.isNotEmpty
                ? Image.network(
                    _productImage,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : SizedBox.shrink(),
            SizedBox(height: 16.0),
            Text(
              'Product Name: $_productName',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Extracted Nutrition Facts:',
              style: Theme.of(context).textTheme.headline6, // Use custom text theme for headline
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: _nutritionFacts.length,
                itemBuilder: (context, index) {
                  // Classify each nutrition element
                  String classification =
                      classifyNutrient(_nutritionFacts[index], _nutritionElementNames[index]);

                  // Get color for the circle based on classification
                  Color circleColor = getColorForNutrientClassification(classification);

                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleColor,
                          ),
                        ),
                        title: Text(
                          _nutritionFacts[index],
                          style: Theme.of(context).textTheme.bodyText2, // Use custom text theme for list tile text
                        ),
                      ),
                      Divider(), // Add a divider after each ListTile
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Product Classification: $_productClassification',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
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
}
