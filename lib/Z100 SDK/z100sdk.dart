
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZCSPosSdk {
  static const MethodChannel _channel = MethodChannel('ZCSPOSSDK');

  static Future<void> initSdk(BuildContext context) async {
    try {
      await _channel.invokeMethod('initializeSdk');
    } on PlatformException catch (e) {
      print("Failed to initialize SDK: '${e.message}'.");
    }
  }

  Future<bool> printReceipt(BuildContext context, String token, String time, String nameEn, String nameBn, String companyName) async {
    try {
      await _channel..invokeMethod('printReceipt', {
        'token': token,
        'time': time,
        'nameEn': nameEn,
        'nameBn': nameBn,
        'companyName': companyName,
      });
      return true;
    } catch (e) {
      print("Failed to print receipt: $e");
      return false;
    }
  }

}