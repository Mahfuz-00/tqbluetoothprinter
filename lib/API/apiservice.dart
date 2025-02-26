import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/models.dart';

class ApiService {
  static const String baseUrl = 'https://tq-test.alhadiexpress.com.bd/api/init';
  final String authToken = 'f80222b0fd806104411f2c27782da05e63fe265209b2988b69770e7eaa60eacd';

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('$baseUrl'), headers: {'Authorization': '$authToken'});

    if (response.statusCode == 200) {
      print('Fetched data: ${response.statusCode}');
      final data = json.decode(response.body);
      print(data);
      final company = await fetchCompanyData();
      final categories = await fetchCategories();
      final config = await fetchConfigData();
      print(company);
      print(categories);
      return {'categories': categories, 'company': company, 'config': config};
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      throw Exception('Failed to fetch data');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl'), headers: {'Authorization': '$authToken'});
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      print('Fetched categories data: ${response.statusCode}');
      final Map<String, dynamic> dataMap = json.decode(response.body);
      final List<dynamic> categoriesData = dataMap['categories']  ?? [];
      return categoriesData.map((json) => Category.fromJson(json)).toList();
    } else {
      print('Failed to fetch categories data: ${response.statusCode}');
      throw Exception('Failed to fetch categories data');
      /*throw Exception('Failed to fetch categories data');*/
    }
  }

  Future<Company?> fetchCompanyData() async {
    final response = await http.get(Uri.parse('$baseUrl'), headers: {'Authorization': '$authToken'});

    if (response.statusCode == 200) {
      print('Fetched company data: ${response.statusCode}');
      final data = json.decode(response.body);
      return Company.fromJson(data['company']);
    } else {
      print('Failed to fetch company data: ${response.statusCode}');
      throw Exception('Failed to fetch company data');
    }
  }

  Future<Map<String, dynamic>?>fetchConfigData() async {
    final response = await http.get(Uri.parse('$baseUrl'), headers: {'Authorization': '$authToken'});
    if(response.statusCode == 200){
      print('Fetched config data: ${response.statusCode}');
      final data = json.decode(response.body);
      return data['config'];
    }else{
      print('Failed to fetch config data: ${response.statusCode}');
      throw Exception('Failed to fetch config data');
    }
  }
}