import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wonder_poll/Model/location.dart';
import 'package:wonder_poll/Repositories/location_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocationForms extends StatefulWidget {
  const LocationForms({super.key, this.location});

  final Location? location;

  @override
  State<LocationForms> createState() => _LocationFormsState();
}

class _LocationFormsState extends State<LocationForms> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Using controllers prevents text loss and makes value extraction safer
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;

  File? _image;
  bool _imageWasRemoved = false; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _addressController = TextEditingController(text: widget.location?.address ?? '');
    _descriptionController = TextEditingController(text: widget.location?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? get _existingImagePath => widget.location?.imagePath;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _imageWasRemoved = false; 
      });
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _imageWasRemoved = true; 
    });
  }

  Future<String> _saveImageToAppDir(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/location_images');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = p.join(imageDir.path, fileName);
    final newImage = await imageFile.copy(newPath);

    return newImage.path;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    String? finalImagePath;
    if (_image != null) {
      finalImagePath = await _saveImageToAppDir(_image!);
    } else if (_imageWasRemoved) {
      finalImagePath = null; 
    } else {
      finalImagePath = _existingImagePath; 
    }
      
    final location = Location(
      id: widget.location?.id, 
      name: _nameController.text.trim(), 
      address: _addressController.text.trim(), 
      description: _descriptionController.text.trim(),
      imagePath: finalImagePath, 
    );

    if (widget.location == null) {
      await LocationRepo.addLocation(location);
    } else {
      await LocationRepo.updateLocation(location);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // Helper widget to gracefully handle image rendering files safely
  Widget _buildImagePreview() {
    if (_image != null) {
      return Image.file(_image!, fit: BoxFit.cover, width: double.infinity);
    }
    
    if (!_imageWasRemoved && _existingImagePath != null && _existingImagePath!.isNotEmpty) {
      final file = File(_existingImagePath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, width: double.infinity);
      }
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, color: Colors.white54, size: 40),
          SizedBox(height: 8),
          Text("Tap to select an image", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
@override
Widget build(BuildContext context) {
  // Check if an image is actively loaded to show the delete overlay icon
  final hasImage = _image != null || (!_imageWasRemoved && _existingImagePath != null && _existingImagePath!.isNotEmpty);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF222429),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Form(
      key: _formKey,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Wrap the input fields in a Flexible SingleChildScrollView
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    // Description Field (This grows with new lines)
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      minLines: 1,
                      maxLines: null, // Allows dynamic expansion
                      validator: (v) => v != null && v.length > 500 
                          ? 'Must be 500 characters or less' 
                          : null,
                    ),
                    
                    const SizedBox(height: 16),

                    // Image Preview & Picker
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: _buildImagePreview(),
                            ),
                          ),
                        ),

                        if (hasImage)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // 2. Keep Action Buttons outside the scrollview so they stay pinned to the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ), 
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
  }
}