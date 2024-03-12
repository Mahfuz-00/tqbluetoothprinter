import 'dart:convert';
//import 'dart:typed_data';

//import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footer/footer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:usb_serial/usb_serial.dart';


import '../API/apiservice.dart';
import '../Models/models.dart';
import '../Z100 SDK/z100sdk.dart';

class UIScreen extends StatefulWidget {
  UIScreen({Key? key}) : super(key: key);

  @override
  _UIScreenState createState() => _UIScreenState();
}

class _UIScreenState extends State<UIScreen> {
  final ApiService _apiService = ApiService();
  //platform = MethodChannel('your_channel_name');

  @override
  void initState() {
    super.initState();
    // Call initSdk method here
    initSdk();
  }

  Future<void> initSdk() async {
    try {
      await ZCSPosSdk.initSdk(context);
    } catch (e) {
      print('Error initializing SDK: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isFullScreen = false;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey, // Specify your desired border color here
                width: 1.0, // Specify the width of the border
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            shadowColor: Colors.black26,
            /*title: InkWell(
            onTap: () {
          // Toggle fullscreen mode
          setState(() {
            isFullScreen = !isFullScreen;
          });

          // Toggle system UI mode
          if (isFullScreen) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
          } else {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
              SystemUiOverlay.top,
              SystemUiOverlay.bottom,
            ]);
          }
              },
              child:*/ title: Image.asset(
            'Assets/TQLogo.png',
            height: screenHeight * 0.1,
            width: screenWidth * 0.2,
          ),
            //),
             actions: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0,bottom: 8.0,left: 8.0,right: 20.0),
                child: IconButton(
                  icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                  onPressed: () {
                    setState(() {
                      isFullScreen = !isFullScreen;
                    });
                    if (isFullScreen) {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
                    } else {
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
                        SystemUiOverlay.top,
                        SystemUiOverlay.bottom,
                      ]);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'WELCOME!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025,),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Please Select an option',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05,),
              FutureBuilder<Map<String, dynamic>>(
                future: _apiService.fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text('Error: ${snapshot.error ?? "No data"}'));
                  }
                  /*if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }*/
                  final String companyName = snapshot.data!['company']?.name ?? '';
                  final List<dynamic> categoriesData = snapshot.data!['categories'] ?? [];

                  return Column(
                    children: categoriesData.map<Widget>((category) {
                      final String nameEn = category.nameEn;
                      final String nameBn = category.nameBn;
                      return Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              fixedSize: Size(screenWidth * 0.8, screenHeight * 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () async {
                              final categoryID = category.id;
                              final url = 'https://tqueue.touchandsolve.com/api/create-token?id=$categoryID';
                              final response = await http.get(Uri.parse(url));

                              if (response.statusCode == 200) {
                                final responseData = json.decode(response.body);
                                print(responseData);
                                final data = responseData['data'];
                                final Token = data['token'];
                                final Time = data['time'];
                                print('Token: $Token, Time and Date: $Time');

                                /*SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                String companyName = prefs.getString('companyName') ?? '';*/
                                /*const snackBar = SnackBar(
                                  content: Text('Printing'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
                                //final companyName = companyData['name'];
                                final ZCSPosSdk zcsPosSdk = ZCSPosSdk();
                                await zcsPosSdk.printReceipt(context, '$Token', '$Time', '$nameEn', '$nameBn', '$companyName');
                                /*await zcsPosSdk.printReceipt(context, '$Token', '$Time', '$nameEn', '$nameBn', '$companyName') .then((_) {
                                  const snackBar2 = SnackBar(
                                    content: Text('Printing Complete'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar2);
                                });*/
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: buildAlertDialog(Token, Time, '$nameEn ($nameBn)'),
                                    );
                                  },
                                );
                                //printReceipt(Token, Time, nameEn, nameBn, companyName);

                              } else {
                                print('Failed to fetch data: ${response.statusCode}');
                              }
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$nameEn ($nameBn)',
                                style: const TextStyle(
                                  fontSize: 25, // Adjust font size as needed
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: screenHeight*0.075, // Set the desired height
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey, // Adjust the color as needed
              width: 1.0, // Adjust the width as needed
            ),
          ),
          /*boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Adjust shadow color and opacity as needed
              spreadRadius: 1, // Adjust spread radius
              blurRadius: 5, // Adjust blur radius
              offset: Offset(0, -3), // Adjust shadow offset
            ),
          ],*/
        ),
        child: Footer(
          backgroundColor: Colors.grey[200],
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('©Copyright 2024 Touch Queue. All Rights Reserved.'),
              SizedBox(width: screenWidth*0.35,),
              Text('Developed and Maintained by: Touch and Solve'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAlertDialog(String token, String time, String name) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.only(top: 24, bottom: 12, left: 24, right: 24),
      title: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.1,
            height: MediaQuery.of(context).size.height * 0.1,
            child: Image.asset(
              'Assets/Tick mark.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.20,
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Your Token No: $token',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '$name',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.1,
            color: Theme.of(context).colorScheme.primary,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

 /* // Method to retrieve company name from SharedPreferences
  Future<String?> getCompanyName() async {
    final company = await ApiService().getCompanyFromPrefs();
    print(company?.name);
    return company?.name; // Assuming the company name is stored in a property called 'name'
  }*/

  // Method to print the receipt
  /*Future<void> printReceipt(String token, String time, String nameEn, String nameBn, String companyName) async {
    //final companyName = await getCompanyName();

    // Call the printReceipt method from the ZCSPrinter class
    await ZCSPrinter.printReceipt(token, time, nameEn, nameBn, companyName);
  }*/

/*  Future<void> _printData(String token, String time, String nameEn, String nameBn) async {
    try {
      PrinterDiscovery.discoverPrinters();
      *//*final usbConnection = UsbConnection(context);
      await usbConnection.init();
      final ticket = await testTicket(token, time, nameEn, nameBn);
      await usbConnection.sendData(Uint8List.fromList(ticket));
      await usbConnection.close();*//*
      // Generate the receipt content
      final List<int> ticket = await testTicket(token, time, nameEn, nameBn);

      // Print directly to the built-in thermal printer
      // Replace the following line with the method to print to the built-in printer
      print('Printing receipt: $ticket');
    } catch (e) {
      print('Error printing: $e');
    }
  }

  Future<List<int>> testTicket(String token, String time, String nameEn, String nameBn) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final Company? company = await ApiService().getCompanyFromPrefs();
    if (company != null) {
      final String companyName = company.name;
      bytes += generator.text('$companyName\n',
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
    }
    bytes += generator.text('Token No: $token\n',
        styles: PosStyles(
          height: PosTextSize.size6,
          width: PosTextSize.size6,
        ));
    bytes += generator.text('Date and Time: $time\n',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.text('Developed by Touch and Solve\n\n');

    bytes += generator.cut();

    return bytes;
  }
}

const String _channelName = 'printerDiscoveryChannel';
const String _discoverPrintersMethod = 'discoverPrinters';

class PrinterInfo {
  final String name;
  final String ipAddress;

  PrinterInfo({required this.name, required this.ipAddress});

  factory PrinterInfo.fromMap(Map<dynamic, dynamic> map) {
    return PrinterInfo(
      name: map['name'],
      ipAddress: map['ipAddress'],
    );
  }
}

class PrinterDiscovery {
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<List<PrinterInfo>> discoverPrinters() async {
    try {
      final List<dynamic> printerData = await _channel.invokeMethod(_discoverPrintersMethod);
      return printerData.map((data) => PrinterInfo.fromMap(data)).toList();
    } on PlatformException catch (e) {
      print("Failed to discover printers: '${e.message}'.");
      return [];
    }
  }*/
}

/*class UsbConnection {
  final BuildContext context;

  UsbConnection(this.context);

  Future<void> init() async {
    try {
      // Initialize USB connection (platform-specific code)
      const snackBar = SnackBar(
        content: Text('Preparing USB Connection/Start'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
      const MethodChannel _channel = MethodChannel('usb_printer_channel');
      const snackBar2 = SnackBar(
        content: Text('Invoking USB Connection'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar2);
      await _channel.invokeMethod('initUsbConnection');
    } catch (e) {
      const snackBar3 = SnackBar(
        content: Text('Failed to Connect USB'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar3);
      throw Exception('Failed to initialize USB connection: $e');
    }
  }

  Future<void> sendData(Uint8List data) async {
    try {
      // Send data to USB printer (platform-specific code)
      const snackBar4 = SnackBar(
        content: Text('Preparing USB Connection/Data'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar4);
      const MethodChannel _channel = MethodChannel('usb_printer_channel');
      const snackBar5 = SnackBar(
        content: Text('Sending Data to USB Printer'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar5);
      await _channel.invokeMethod('sendDataToUsbPrinter', {'data': data});
    } catch (e) {
      const snackBar6 = SnackBar(
        content: Text('Failed to send Data to USB Printer'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar6);
      throw Exception('Failed to send data to USB printer: $e');
    }
  }

  Future<void> close() async {
    try {
      // Close USB connection (platform-specific code)
      const snackBar7 = SnackBar(
        content: Text('Preparing USB Connection/Close'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar7);
      const MethodChannel _channel = MethodChannel('usb_printer_channel');
      await _channel.invokeMethod('closeUsbConnection');
    } catch (e) {
      const snackBar8 = SnackBar(
        content: Text('Failed to close USB Connection'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar8);
      throw Exception('Failed to close USB connection: $e');
    }
  }
}*/
