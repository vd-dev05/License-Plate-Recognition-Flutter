import 'package:flutter/material.dart';
import 'package:new_app_check/screens/license_plate_check_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SearchHistoryItem {
  final String licensePlate;
  final DateTime timestamp;
  final bool hasViolation;

  SearchHistoryItem({
    required this.licensePlate,
    required this.timestamp,
    required this.hasViolation,
  });
}

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  List<SearchHistoryItem> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('search_history') ?? [];
      
      final List<SearchHistoryItem> items = [];
      
      for (final json in historyJson) {
        try {
          final parts = json.split('|');
          if (parts.length >= 2) {
            final licensePlate = parts[0];
            final timestamp = DateTime.tryParse(parts[1]);
            final hasViolation = parts.length > 2 ? parts[2] == 'true' : false;
            
            if (timestamp != null) {
              items.add(SearchHistoryItem(
                licensePlate: licensePlate,
                timestamp: timestamp,
                hasViolation: hasViolation,
              ));
            }
          }
        } catch (e) {
          debugPrint('Error parsing history item: $e');
        }
      }
      
      // Sắp xếp theo thời gian gần nhất trước
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      setState(() {
        _historyItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử tra cứu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('search_history');
        
        setState(() {
          _historyItems = [];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa lịch sử tra cứu')),
          );
        }
      } catch (e) {
        debugPrint('Error clearing history: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Lịch sử tra cứu'),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearHistory,
              tooltip: 'Xóa lịch sử',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch sử tra cứu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các biển số bạn đã tra cứu sẽ hiển thị ở đây',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final dateFormat = DateFormat('HH:mm dd/MM/yyyy');
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _historyItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _historyItems[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: item.hasViolation 
                ? Colors.red.shade100 
                : Colors.green.shade100,
            child: Icon(
              item.hasViolation ? Icons.warning : Icons.check_circle,
              color: item.hasViolation ? Colors.red : Colors.green,
            ),
          ),
          title: Text(
            item.licensePlate,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Tra cứu lúc: ${dateFormat.format(item.timestamp)}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LicensePlateCheckScreen(),
              ),
            );
          },
        );
      },
    );
  }
} 