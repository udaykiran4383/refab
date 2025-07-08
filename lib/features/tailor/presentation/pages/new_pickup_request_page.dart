import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/pickup_request_model.dart';
import '../../data/repositories/tailor_repository.dart';
import '../../providers/tailor_provider.dart';

class NewPickupRequestPage extends ConsumerStatefulWidget {
  final UserModel user;
  
  const NewPickupRequestPage({super.key, required this.user});

  @override
  ConsumerState<NewPickupRequestPage> createState() => _NewPickupRequestPageState();
}

class _NewPickupRequestPageState extends ConsumerState<NewPickupRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _fabricTypeController = TextEditingController();
  final _weightController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isGettingLocation = false;
  FabricType _selectedFabricType = FabricType.cotton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Pickup Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fabric Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<FabricType>(
                        value: _selectedFabricType,
                        decoration: const InputDecoration(
                          labelText: 'Fabric Type',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: FabricType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFabricType = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select fabric type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fabricTypeController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Fabric Description',
                          hintText: 'Describe the fabric condition, color, etc.',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter fabric description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Estimated Weight (kg)',
                          prefixIcon: Icon(Icons.scale),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter estimated weight';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Address',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Complete Address',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pickup address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isGettingLocation ? null : _getCurrentLocation,
                        icon: _isGettingLocation 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(_isGettingLocation ? 'Getting Location...' : 'Use Current Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Notes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Special Instructions (Optional)',
                          hintText: 'Any specific instructions for pickup...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Pickup Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    print('📍 [LOCATION] Starting getCurrentLocation...');
    
    if (mounted) {
      setState(() => _isGettingLocation = true);
    }
    
    try {
      print('📍 [LOCATION] Requesting location permission...');
      // Get current position
      final position = await LocationService.getCurrentLocation();
      
      print('📍 [LOCATION] Position result: $position');
      
      if (position != null && mounted) {
        print('📍 [LOCATION] Position obtained: ${position.latitude}, ${position.longitude}');
        
        // Convert coordinates to address
        print('📍 [LOCATION] Converting coordinates to address...');
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        print('📍 [LOCATION] Address result: $address');
        
        if (address != null && mounted) {
          setState(() {
            _addressController.text = address;
            _notesController.text = 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          });
          
          print('📍 [LOCATION] Address set successfully: $address');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current location set successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('📍 [LOCATION] Could not get address for coordinates');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not get address for current location'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        print('📍 [LOCATION] Position is null or widget not mounted');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied or location unavailable'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('📍 [LOCATION] Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting current location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print('📍 [LOCATION] Finishing getCurrentLocation...');
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _submitRequest() async {
    print('📦 [PICKUP] _submitRequest called');
    print('📦 [PICKUP] Widget user ID: ${widget.user.id}');
    print('📦 [PICKUP] Widget user name: ${widget.user.name}');
    
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        print('📦 [PICKUP] Starting pickup request creation...');
        
        // For now, use placeholder image URLs since StorageService is not available
        final imageUrls = _selectedImages.map((file) => 'placeholder_url_${file.path}').toList();
        
        // Create pickup request with the complex model
        final request = PickupRequestModel(
          id: const Uuid().v4(),
          tailorId: widget.user.id,
          customerName: widget.user.name,
          customerPhone: widget.user.phone,
          customerEmail: widget.user.email,
          fabricType: _selectedFabricType,
          fabricDescription: _fabricTypeController.text.trim(),
          estimatedWeight: double.parse(_weightController.text),
          pickupAddress: _addressController.text.trim(),
          status: PickupStatus.pending,
          estimatedValue: 0.0, // Will be calculated based on weight
          photos: imageUrls,
          notes: _notesController.text.trim(),
          createdAt: DateTime.now(),
        );
        
        print('📦 [PICKUP] Created request model: ${request.id}');
        print('📦 [PICKUP] Tailor ID: ${request.tailorId}');
        print('📦 [PICKUP] Customer: ${request.customerName}');
        print('📦 [PICKUP] Address: ${request.pickupAddress}');
        
        // Use the repository to create the request
        final repository = ref.read(tailorRepositoryProvider);
        final requestId = await repository.createPickupRequest(request);
        
        print('📦 [PICKUP] ✅ Request saved to Firestore with ID: $requestId');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('📦 [PICKUP] ❌ Error creating pickup request: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating pickup request: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _fabricTypeController.dispose();
    _weightController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
