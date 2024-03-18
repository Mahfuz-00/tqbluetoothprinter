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

  @override
  void initState() {
    super.initState();
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

    return Scaffold(
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
                 padding: EdgeInsets.only(right: paddingValue+2),
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
                             SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
                  final String companyName = snapshot.data!['company']?.name ?? '';
                  final List<dynamic> categoriesData = snapshot.data!['categories'] ?? [];

                  return Column(
                    children: categoriesData.map<Widget>((category) {
                      final String nameEn = category.nameEn;
                      final String nameBn = category.nameBn;
                          return StatefulBuilder(
                            builder: (context, setState) {
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
                                        setState(() {
                                          isLoadingIndex =
                                              categoriesData.indexOf(
                                                  category);
                                          showLoadingOverlay(context);
                                        });
                                        final int categoryID = category.id;
                                        final url = 'https://touch-queue.com/api/create-token?id=$categoryID';
                                        final response = await http.get(Uri.parse(url));

                                        if (response.statusCode == 200) {
                                          final responseData = json.decode(response.body);
                                          print(responseData);
                                          final data = responseData['data'];
                                          final Token = data['token'];
                                          final Time = data['time'];
                                          print('Token: $Token, Time and Date: $Time');

                                          final ZCSPosSdk z100PosSdk = ZCSPosSdk();
                                          await z100PosSdk.printReceipt(context, '$Token', '$Time', '$nameEn', '$nameBn', '$companyName');

                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Center(
                                                child: buildAlertDialog(Token, Time, '$nameEn ($nameBn)'),
                                              );
                                            },
                                          );
                                        } else {
                                          print('Failed to fetch data: ${response.statusCode}');
                                        }
                                        setState(() {
                                          isLoadingIndex = -1;
                                        });
                                      },
                                      child: FittedBox(
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
                            }
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
        height: screenHeight*0.075,
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
                      borderRadius: BorderRadius.circular(10), // Add a border for visibility
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