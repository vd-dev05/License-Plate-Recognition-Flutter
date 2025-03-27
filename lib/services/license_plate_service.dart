import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_app_check/models/violation.dart';

class LicensePlateService {
  // Trong thực tế, URL này sẽ được thay thế bằng API thật từ CSGT
  static const String apiUrl = 'https://api.example.com/check-license-plate';
  
  // Mock data cho mục đích demo
  static final Map<String, List<Violation>> _mockViolations = {
    '30A12345': [
      Violation(
        id: '001',
        licensePlate: '30A12345',
        violationType: 'Vượt đèn đỏ',
        location: 'Ngã tư Lê Văn Lương - Láng Hạ, Hà Nội',
        date: DateTime(2023, 11, 15, 14, 30),
        fine: 1200000,
        imageUrl: 'https://example.com/images/violation1.jpg',
      ),
    ],
    '51F88888': [
      Violation(
        id: '002',
        licensePlate: '51F88888',
        violationType: 'Đỗ xe sai quy định',
        location: 'Đường Nguyễn Huệ, TP. Hồ Chí Minh',
        date: DateTime(2023, 12, 1, 9, 15),
        fine: 700000,
        imageUrl: 'https://example.com/images/violation2.jpg',
      ),
      Violation(
        id: '003',
        licensePlate: '51F88888',
        violationType: 'Vượt quá tốc độ',
        location: 'Đường Võ Văn Kiệt, TP. Hồ Chí Minh',
        date: DateTime(2023, 12, 10, 22, 45),
        fine: 1500000,
        imageUrl: 'https://example.com/images/violation3.jpg',
      ),
    ],
  };

  // Phương thức để kiểm tra biển số xe có vi phạm hay không
  static Future<List<Violation>> checkLicensePlate(String licensePlate) async {
    // Loại bỏ tất cả khoảng trắng, dấu gạch ngang... từ biển số
    final normalizedPlate = licensePlate.replaceAll(RegExp(r'[\s-]+'), '').toUpperCase();
    
    try {
      // Trong môi trường thực tế sẽ gọi API thật
      // final response = await http.get(Uri.parse('$apiUrl/$normalizedPlate'));
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => Violation.fromJson(json)).toList();
      // }
      
      // Sử dụng mock data cho demo
      await Future.delayed(const Duration(seconds: 2)); // Giả lập thời gian gọi API
      
      if (_mockViolations.containsKey(normalizedPlate)) {
        return _mockViolations[normalizedPlate]!;
      }
      
      return [];
    } catch (e) {
      throw Exception('Không thể kiểm tra biển số: $e');
    }
  }
} 