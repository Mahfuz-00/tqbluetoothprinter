import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footer/footer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../API/apiservice.dart';
import '../Z100 SDK/z100sdk.dart';

class UIScreen extends StatefulWidget {
  UIScreen({Key? key}) : super(key: key);

  @override
  _UIScreenState createState() => _UIScreenState();
}

class _UIScreenState extends State<UIScreen> {
  final ApiService _apiService = ApiService();
  bool isFullScreen = false;
  int isLoadingIndex = -1;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late Future<Map<String, dynamic>> _futureData;


  @override
  void initState() {
    super.initState();
    _futureData = _apiService.fetchData();
    initSdk();
  }

  Future<void> initSdk() async {
    try {
      await ZCSPosSdk.initSdk(context);
    } catch (e) {
      print('Error initializing SDK: $e');
    }
  }

  IconData _getIcon() {
    return isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double paddingValue = screenWidth * 0.06;

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.white,
                shadowColor: Colors.black26,
                title: Padding(
                  padding: EdgeInsets.only(left: paddingValue),
                  child: Image.asset(
                    'Assets/TQLogo.png',
                    height: screenHeight * 0.07,
                    width: screenWidth * 0.15,
                  ),
                ),
                //),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: paddingValue + 2),
                    child: Visibility(
                      visible: !isFullScreen,
                      child: Container(
                        child: IconButton(
                          icon: Icon(_getIcon()),
                          onPressed: () {
                            setState(() {
                              isFullScreen = true;
                              print('isFullScreen: $isFullScreen');
                              if (isFullScreen) {
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.manual,
                                    overlays: []);
                              }
                            });
                          },
                        ),
                      ),
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
                        SizedBox(
                          height: screenHeight * 0.025,
                        ),
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
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _futureData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(
                            child: Text('Error: ${snapshot.error ?? "No data"}'));
                      }
                      final String companyName =
                          snapshot.data!['company']?.name ?? '';
                      final List<dynamic> categoriesData =
                          snapshot.data!['categories'] ?? [];
                      final bool shouldDialog =
                          snapshot.data!['config']['collect_data'] ?? '';
                      print(shouldDialog);

                      return Column(
                        children: categoriesData.map<Widget>((category) {
                          final String nameEn = category.nameEn;
                          final String nameBn = category.nameBn;
                          final String DocBn = category.DocBn;
                          final String DocEn = category.DocEn;
                          final String DocDesignation = category.DocDesignation;
                          final String DocRoom = category.DocRoom;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                      fixedSize: Size(
                                          screenWidth * 0.8, screenHeight * 0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        isLoadingIndex =
                                            categoriesData.indexOf(category);
                                        showLoadingOverlay(context);
                                      });
                                      final int categoryID = category.id;
                                      // final String authToken = '16253100c9ba119436b8089c338cb86cf420a51c4ed4bb0626dcbac295b2fd66';
                                      final String authToken = URLs().token;
                                      // final String authToken = 'f80222b0fd806104411f2c27782da05e63fe265209b2988b69770e7eaa60eacd';
                                      if (shouldDialog == false) {
                                        // final url = 'https://tq-test.alhadiexpress.com.bd/api/create-token';
                                        final url = '${URLs().Basepath}/api/create-token';

                                        final response = await http
                                            .post(Uri.parse(url), headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': '$authToken',
                                        }, body: {
                                          'id': categoryID,
                                        });
                                        if (response.statusCode == 200) {
                                          final responseData =
                                          json.decode(response.body);
                                          print(responseData);
                                          final data = responseData['data'];
                                          final Token = data['token'];
                                          final Time = data['time'];
                                          print(
                                              'Token: $Token, Time and Date: $Time');

                                          final ZCSPosSdk z100PosSdk = ZCSPosSdk();
                                          await z100PosSdk.printReceipt(
                                              context,
                                              '$Token',
                                              '$Time',
                                              '$nameEn',
                                              '$nameBn',
                                              '$companyName',
                                              shouldDialog,
                                              '',
                                              '',
                                              '',
                                              '');

                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Center(
                                                child: buildAlertDialog(Token, Time,
                                                    '$nameEn ($nameBn)'),
                                              );
                                            },
                                          );

                                          setState(() {
                                            isLoadingIndex = -1;
                                          });
                                        } else {
                                          print(
                                              'Failed to fetch data: ${response.statusCode}');
                                        }
                                      } else if (shouldDialog == true) {
                                        final TextEditingController nameController =
                                        TextEditingController();
                                        final TextEditingController
                                        phoneController =
                                        TextEditingController();

                                        final scaffoldContext = context;

                                        showDialog(
                                          context: scaffoldContext,
                                          barrierDismissible: false,
                                          builder: (BuildContext dialogContext) {
                                            return AlertDialog(
                                              title: Text('Enter Details'),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // TextFormField for Name
                                                    TextFormField(
                                                      controller: nameController,
                                                      decoration: InputDecoration(
                                                          labelText:
                                                          'Patient Name (রোগীর নাম)'),
                                                    ),
                                                    SizedBox(height: 10),
                                                    // TextFormField for Phone Number
                                                    TextFormField(
                                                      controller: phoneController,
                                                      decoration: InputDecoration(
                                                          labelText:
                                                          'Mobile Number (মোবাইল নম্বর)'),
                                                      keyboardType:
                                                      TextInputType.phone,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                // Print Button that triggers the API call and receipt printing
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    // Store the current context for later use
                                                    final BuildContext currentContext = context;

                                                    // Close the first dialog
                                                    Navigator.of(dialogContext).pop();
                                                    // Build the API URL
                                                    // final url = 'https://tq-test.alhadiexpress.com.bd/api/create-token';
                                                    final url = '${URLs().Basepath}/api/create-token';

                                                    // Make the POST API call using the values entered by the user
                                                    final response =
                                                    await http.post(
                                                      Uri.parse(url),
                                                      headers: {
                                                        'Content-Type':
                                                        'application/json',
                                                        'Authorization':
                                                        '$authToken',
                                                      },
                                                      // Encode the body as JSON
                                                      body: jsonEncode({
                                                        'name': nameController.text,
                                                        'id': categoryID,
                                                        'mobile_number':
                                                        phoneController.text,
                                                      }),
                                                    );
                                                    print(
                                                        'Status Code : ${response.statusCode}');
                                                    print(
                                                        'Resposnse BODY: ${response.body}');
                                                    if (response.statusCode ==
                                                        200) {
                                                      final responseData = json
                                                          .decode(response.body);
                                                      print(responseData);
                                                      final data =
                                                      responseData['data'];
                                                      final token = data['token'];
                                                      final time = data['time'];
                                                      final categoryName =
                                                      data['category'];
                                                      final doctor = data['doctor'];
                                                      final designation =
                                                      data['designation'];
                                                      final room = data['room'];
                                                      print(
                                                          'Token: $token, Time and Date: $time, Category: $categoryName, doctor: $doctor, designation: $designation, Room: $room');

                                                      // Print the receipt using SunmiPosSdk
                                                      final ZCSPosSdk z100PosSdk =
                                                      ZCSPosSdk();
                                                      await z100PosSdk.printReceipt(
                                                          currentContext,
                                                          '$token',
                                                          '$time',
                                                          nameController.text,
                                                          '$nameBn',
                                                          '$companyName',
                                                          shouldDialog,
                                                          '$DocEn',
                                                          '$DocBn',
                                                          '$DocDesignation',
                                                          '$DocRoom');


                                                      // Dismiss the dialog after successful printing
                                                      /*      Navigator.of(dialogContext)
                                                        .pop();*/


                                                      // Introduce a brief delay before showing the second dialog
                                                      /*   await Future.delayed(Duration(milliseconds: 100));*/


                                                      // _showCompletionDialog(scaffoldContext, token, time, nameEn, nameBn);
                                                      showDialog(
                                                        context: navigatorKey.currentContext!,
                                                        barrierDismissible: false,
                                                        builder: (BuildContext context) {
                                                          return Center(
                                                            child: buildAlertDialog(token, time, '$nameEn ($nameBn)'),
                                                          );
                                                        },
                                                      );

                                                      setState(() {
                                                        isLoadingIndex = -1;
                                                      });
                                                    } else {
                                                      print(
                                                          'Failed to fetch data: ${response.statusCode}');
                                                      // Optionally, you could show an error message to the user here.
                                                    }
                                                  },
                                                  child: Text('Print'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: shouldDialog
                                        ? FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '$DocEn ($DocBn), $DocDesignation, Room No (রুম নং): $DocRoom',
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '$nameEn ($nameBn)',
                                            style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    )
                                        : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$nameEn ($nameBn)',
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                ],
                              );
                            },
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
            height: screenHeight * 0.075,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
            ),
            child: Footer(
              backgroundColor: Colors.grey[200],
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('©Copyright 2024 Touch Queue. All Rights Reserved.'),
                  SizedBox(
                    width: screenWidth * 0.35,
                  ),
                  Text('Developed and Maintained by: Touch and Solve'),
                ],
              ),
            ),
          ),
        ),);
      },
    );
  }

  void _showCompletionDialog(BuildContext context, String token, String time, String nameEn, String nameBn) {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: buildAlertDialog(token, time, '$nameEn ($nameBn)'),
          );
        },
      );
    }
  }


  Widget buildAlertDialog(String token, String time, String name) {
    return AlertDialog(
      iconPadding: EdgeInsets.only(top: 15),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      icon: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.height * 0.2,
          child: Image.asset(
            'Assets/Success.gif',
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.1,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Future.delayed(Duration(milliseconds: 10), () {
                    closeLoadingOverlay(context);
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return Theme.of(context).colorScheme.primary;
                  }),
                  /*textStyle: MaterialStateProperty.all(
                    TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),*/
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Add a border for visibility
                    ),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void closeLoadingOverlay(BuildContext context) {
    Navigator.of(context).pop();
  }
}
