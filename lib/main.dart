import 'package:flutter/material.dart';
import 'package:new_app_check/screens/license_plate_check_screen.dart';
import 'package:new_app_check/screens/scan_license_plate_screen.dart';
import 'package:new_app_check/screens/search_history_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('vi_VN', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiểm tra phạt nguội',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _plateController = TextEditingController();

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Kiểm tra phạt nguội'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchHistoryScreen(),
                ),
              );
            },
            tooltip: 'Lịch sử tra cứu',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/3774/3774278.png',
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'Kiểm tra vi phạm giao thông',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập hoặc quét biển số xe để kiểm tra phạt nguội',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final licensePlate = _plateController.text.trim();
                if (licensePlate.isNotEmpty) {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const LicensePlateCheckScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập biển số xe'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('KIỂM TRA'),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanLicensePlateScreen(),
                  ),
                );
                
                if (result != null && result is String) {
                  setState(() {
                    _plateController.text = result;
                  });
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('QUÉT BIỂN SỐ'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const Spacer(),
            const Text(
              'Ứng dụng hỗ trợ tra cứu thông tin vi phạm giao thông',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
