import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/check_in.dart';
import '../storage/check_in_storage.dart';

class CheckInProvider extends ChangeNotifier {
  CheckInProvider({CheckInStorage? storageService}) : _storageService = storageService ?? CheckInStorage() {
    loadCheckIns();
  }

  final CheckInStorage _storageService;
  final ImagePicker _imagePicker = ImagePicker();

  List<CheckIn> _checkIns = [];
  List<CheckIn> get checkIns => _checkIns;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingLocation = false;
  bool get isFetchingLocation => _isFetchingLocation;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  Future<void> loadCheckIns() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _storageService.initialize();
      _checkIns = await _storageService.getAll();
      _checkIns.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Unable to load saved check-ins.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isRestricted) {
      _errorMessage = 'Camera permission is required to take field photos.';
      notifyListeners();
      return;
    }

    if (status.isPermanentlyDenied) {
      _errorMessage = 'Camera permission is permanently denied. Please enable it in app settings.';
      notifyListeners();
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final targetPath = p.join(appDir.path, 'checkin_${DateTime.now().microsecondsSinceEpoch}${p.extension(pickedFile.path)}');
        final savedImage = await File(pickedFile.path).copy(targetPath);
        _selectedImage = savedImage;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (error) {
      _errorMessage = 'Unable to capture the photo.';
      notifyListeners();
    }
  }

  Future<void> fetchCurrentLocation() async {
    _isFetchingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final serviceStatus = await Geolocator.isLocationServiceEnabled();
      if (!serviceStatus) {
        _errorMessage = 'Location services are disabled. Please enable GPS.';
        _isFetchingLocation = false;
        notifyListeners();
        return;
      }

      var status = await Permission.location.request();
      if (status.isDenied || status.isRestricted) {
        _errorMessage = 'Location permission is required to record your field location.';
        _isFetchingLocation = false;
        notifyListeners();
        return;
      }

      if (status.isPermanentlyDenied) {
        _errorMessage = 'Location permission is permanently denied. Please enable it in app settings.';
        _isFetchingLocation = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      _currentPosition = position;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Unable to fetch your location right now.';
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
  }

  Future<void> saveCheckIn({required String note}) async {
    if (_selectedImage == null) {
      _errorMessage = 'Please capture a photo before saving.';
      notifyListeners();
      return;
    }

    if (_currentPosition == null) {
      _errorMessage = 'Please fetch the GPS location before saving.';
      notifyListeners();
      return;
    }

    if (note.trim().isEmpty) {
      _errorMessage = 'Please enter a note before saving.';
      notifyListeners();
      return;
    }

    final checkIn = CheckIn(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      note: note.trim(),
      imagePath: _selectedImage!.path,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      accuracy: _currentPosition!.accuracy,
      createdAt: DateTime.now(),
    );

    try {
      await _storageService.initialize();
      await _storageService.save(checkIn);
      _checkIns.insert(0, checkIn);
      _checkIns.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _selectedImage = null;
      _currentPosition = null;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Unable to save the check-in.';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> openAppSettingsIfNeeded() async {
    await openAppSettings();
  }
}
