
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZCSPosSdk {
  static const MethodChannel _channel = MethodChannel('ZCSPOSSDK');

  static Future<void> initSdk(BuildContext context) async {
    try {
     /* print('Accepted');
      const snackBar = SnackBar(
        content: Text('Initilizing SDK'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);*/
      await _channel.invokeMethod('initializeSdk');
      /*await _channel.invokeMethod('initializeSdk').then((success) {
        if (success) {
          final snackBar = SnackBar(
            content: Text('SDK Initialized'),
          );
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
        } else {
          final snackBar = SnackBar(
            content: Text('SDK Initialization Failed'),
          );
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
        }
      });*/
      //print('Accepted<>');
    } on PlatformException catch (e) {
      /*const snackBar3 = SnackBar(
        content: Text('Failed to Initilize SDK'),
      );
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar3);*/
      print("Failed to initialize SDK: '${e.message}'.");
    }
  }

  Future<bool> printReceipt(BuildContext context, String token, String time, String nameEn, String nameBn, String companyName) async {
    try {
      /*// Show snackbar indicating printing started
      final snackBar = SnackBar(
        content: Text('Printing receipt...'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);*/

      final snackBar = SnackBar(
        content: Text(companyName),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Invoke the method channel to send the receipt data to the printer
      await _channel..invokeMethod('printReceipt', {
        'token': token,
        'time': time,
        'nameEn': nameEn,
        'nameBn': nameBn,
        'companyName': companyName,
      });

     /* // Show snackbar indicating printing completed
      final snackBar2 = SnackBar(
        content: Text('Printing complete'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar2);*/

      return true; // Printing succeeded
    } catch (e) {
      print("Failed to print receipt: $e");
      return false; // Printing failed
    }
  }

}