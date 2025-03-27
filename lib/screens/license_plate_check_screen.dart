import 'package:flutter/material.dart';
import 'package:new_app_check/services/license_plate_service.dart';
import 'package:new_app_check/models/violation.dart';
import 'package:new_app_check/screens/violation_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicensePlateCheckScreen extends StatefulWidget {
  const LicensePlateCheckScreen({super.key});

  @override
  State<LicensePlateCheckScreen> createState() => _LicensePlateCheckScreenState();
}

class _LicensePlateCheckScreenState extends State<LicensePlateCheckScreen> {
  final TextEditingController _plateController = TextEditingController();
  bool _isLoading = false;
  List<Violation> _violations = [];
  String _errorMessage = '';

  Future<void> _checkLicensePlate() async {
    final licensePlate = _plateController.text.trim();
    
    if (licensePlate.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập biển số xe';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _violations = [];
    });

    try {
      final violations = await LicensePlateService.checkLicensePlate(licensePlate);
      
      setState(() {
        _isLoading = false;
        _violations = violations;
        if (violations.isEmpty) {
          _errorMessage = 'Biển số $licensePlate không có vi phạm giao thông!';
        }
      });
      
      // Lưu lịch sử tra cứu
      _saveSearchHistory(licensePlate, violations.isNotEmpty);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã xảy ra lỗi: $e';
      });
    }
  }

  Future<void> _saveSearchHistory(String licensePlate, bool hasViolation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList('search_history') ?? [];
      
      // Format: licensePlate|timestamp|hasViolation
      final historyItem = '$licensePlate|${DateTime.now().toIso8601String()}|$hasViolation';
      
      // Check if the list already has too many items
      if (historyList.length >= 50) {
        historyList.removeLast(); // Remove oldest item
      }
      
      // Add new item at the beginning
      historyList.insert(0, historyItem);
      
      await prefs.setStringList('search_history', historyList);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Kiểm tra phạt nguội'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Nhập biển số xe để kiểm tra phạt nguội',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Biển số xe',
                hintText: 'Ví dụ: 30A-12345',
                prefixIcon: Icon(Icons.directions_car),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkLicensePlate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : const Text('KIỂM TRA'),
            ),
            const SizedBox(height: 24),
            if (_errorMessage.isNotEmpty && _violations.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _errorMessage.contains('không có vi phạm') 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _errorMessage.contains('không có vi phạm') 
                        ? Colors.green 
                        : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _errorMessage.contains('không có vi phạm') 
                          ? Icons.check_circle 
                          : Icons.error,
                      color: _errorMessage.contains('không có vi phạm') 
                          ? Colors.green 
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: _errorMessage.contains('không có vi phạm') 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_violations.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Tìm thấy ${_violations.length} vi phạm cho biển số ${_plateController.text}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _violations.length,
                  itemBuilder: (context, index) {
                    final violation = _violations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          violation.violationType,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Địa điểm: ${violation.location}'),
                            Text('Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(violation.date)}'),
                            Text(
                              'Tiền phạt: ${currencyFormat.format(violation.fine)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViolationDetailsScreen(violation: violation),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 