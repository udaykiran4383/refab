import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../data/models/pickup_request_model.dart';
import '../data/repositories/tailor_repository.dart';
import '../providers/tailor_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/location_service.dart';

class PickupRequestPage extends ConsumerStatefulWidget {
  const PickupRequestPage({super.key});

  @override
  ConsumerState<PickupRequestPage> createState() => _PickupRequestPageState();
}

class _PickupRequestPageState extends ConsumerState<PickupRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _fabricTypeController = TextEditingController();
  final _weightController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isGettingLocation = false;
  FabricType _selectedFabricType = FabricType.cotton;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

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
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fabricTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Fabric Description',
                          hintText: 'e.g., Old cotton shirts, Denim jeans, etc.',
                          prefixIcon: Icon(Icons.description),
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
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes (Optional)',
                          hintText: 'Any special instructions or additional information',
                          prefixIcon: Icon(Icons.note),
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
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : () => _submitRequest(user?.id),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Pickup Request'),
              ),
              
              const SizedBox(height: 24),
              
              // Show previous requests
              _buildPreviousRequests(user?.id),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousRequests(String? userId) {
    if (userId == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Previous Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<PickupRequestModel>>(
              stream: ref.read(tailorRepositoryProvider).getPickupRequests(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No previous requests');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final request = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(request.fabricDescription),
                        subtitle: Text('${request.estimatedWeight}kg - ${request.pickupAddress}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: request.status == PickupStatus.completed 
                                ? Colors.green 
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            request.status.toString().split('.').last,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
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

  Future<void> _submitRequest(String? userId) async {
    print('🔥 [PICKUP_REQUEST] _submitRequest called with userId: $userId');
    
    if (userId == null) {
      print('🔥 [PICKUP_REQUEST] ❌ userId is null, returning');
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // For now, use placeholder image URLs since StorageService is not available
        final imageUrls = _selectedImages.map((file) => 'placeholder_url_${file.path}').toList();
        
        // Get current user for customer details
        final user = ref.read(authStateProvider).value;
        if (user == null) throw Exception('User not found');
        
        print('🔥 [PICKUP_REQUEST] Current user: ${user.id} - ${user.name}');
        print('🔥 [PICKUP_REQUEST] Creating request with tailorId: $userId');
        
        // Create pickup request with the complex model
        final request = PickupRequestModel(
          id: const Uuid().v4(),
          tailorId: userId,
          customerName: user.name,
          customerPhone: user.phone,
          customerEmail: user.email,
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
        
        print('🔥 [PICKUP_REQUEST] Request created: ${request.id}');
        print('🔥 [PICKUP_REQUEST] Request tailorId: ${request.tailorId}');
        print('🔥 [PICKUP_REQUEST] Request customer: ${request.customerName}');
        
        // Use the provider to create the request
        await ref.read(tailorProvider.notifier).createPickupRequest(request);
        
        print('🔥 [PICKUP_REQUEST] ✅ Request created successfully');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear form
          _fabricTypeController.clear();
          _weightController.clear();
          _addressController.clear();
          _notesController.clear();
          setState(() => _selectedImages.clear());
        }
      } catch (e) {
        print('🔥 [PICKUP_REQUEST] ❌ Error creating request: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
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
