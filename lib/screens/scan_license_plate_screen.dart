import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:new_app_check/services/license_plate_service.dart';

class ScanLicensePlateScreen extends StatefulWidget {
  const ScanLicensePlateScreen({super.key});

  @override
  State<ScanLicensePlateScreen> createState() => _ScanLicensePlateScreenState();
}

class _ScanLicensePlateScreenState extends State<ScanLicensePlateScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessingImage = false;
  File? _capturedImage;
  String? _detectedLicensePlate;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Xử lý khi ứng dụng thay đổi trạng thái (ẩn/hiện)
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }
  
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initCamera();
    } else {
      setState(() {
        _errorMessage = 'Cần quyền truy cập camera để sử dụng chức năng này';
      });
    }
  }
  
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0], 
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Không tìm thấy camera trên thiết bị';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể khởi tạo camera: $e';
      });
    }
  }
  
  Future<void> _takePicture() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    
    try {
      setState(() {
        _isProcessingImage = true;
      });
      
      final XFile image = await _cameraController!.takePicture();
      
      setState(() {
        _capturedImage = File(image.path);
        _isProcessingImage = false;
      });
      
      // Giả lập nhận dạng biển số xe
      await _processImage();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chụp ảnh: $e';
        _isProcessingImage = false;
      });
    }
  }
  
  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
        
        await _processImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chọn ảnh: $e';
      });
    }
  }
  
  Future<void> _processImage() async {
    // Giả lập nhận dạng biển số xe
    setState(() {
      _isProcessingImage = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    // Fake detection - trong thực tế sẽ sử dụng ML model để nhận dạng
    final List<String> fakePlates = [
      '30A-12345',
      '51F-88888',
      '29H-13579',
      '92C-54321',
    ];
    fakePlates.shuffle();
    
    setState(() {
      _detectedLicensePlate = fakePlates.first;
      _isProcessingImage = false;
    });
  }
  
  void _resetState() {
    setState(() {
      _capturedImage = null;
      _detectedLicensePlate = null;
    });
  }
  
  void _proceedToCheck() {
    if (_detectedLicensePlate != null) {
      Navigator.pop(context, _detectedLicensePlate);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Quét biển số xe'),
      ),
      body: _capturedImage == null ? _buildCameraView() : _buildResultView(),
    );
  }
  
  Widget _buildCameraView() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CameraPreview(_cameraController!),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: const Center(
                        child: Text(
                          'Đặt biển số xe vào khung',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_isProcessingImage)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
              ),
              IconButton(
                onPressed: _isProcessingImage ? null : _takePicture,
                icon: const Icon(Icons.camera, color: Colors.white, size: 48),
              ),
              const IconButton(
                onPressed: null,
                icon: Icon(Icons.settings, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildResultView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_capturedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _capturedImage!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                const SizedBox(height: 24),
                
                if (_isProcessingImage)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang nhận dạng biển số xe...'),
                    ],
                  )
                else if (_detectedLicensePlate != null)
                  Column(
                    children: [
                      const Text(
                        'Biển số xe được nhận dạng:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Text(
                          _detectedLicensePlate!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetState,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('CHỤP LẠI'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _detectedLicensePlate == null ? null : _proceedToCheck,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('KIỂM TRA'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 