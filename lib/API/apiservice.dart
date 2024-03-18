import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/models.dart';

class ApiService {
  static const String baseUrl = 'https://touch-queue.com/api/init';

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      print('Fetched data: ${response.statusCode}');
      final data = json.decode(response.body);

      final company = await fetchCompanyData();
      final categories = await fetchCategories();
      return {'categories': categories, 'company': company};
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      throw Exception('Failed to fetch data');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl'));

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
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Company.fromJson(data['company']);
    } else {
      print('Failed to fetch company data: ${response.statusCode}');
      throw Exception('Failed to fetch company data');
    }
  }
}
