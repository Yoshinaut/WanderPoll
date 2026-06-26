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
  String _address = "";
  String _description = "";
  final _formKey = GlobalKey<FormState>();
  File? _image;
  bool _imageWasRemoved = false; // Tracks if the user intentionally cleared the photo
  String _name = "";
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = widget.location?.name ?? '';
    _address = widget.location?.address ?? '';
    _description = widget.location?.description ?? '';
  }

  String? get _existingImagePath => widget.location?.imagePath;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _imageWasRemoved = false; // Reset because they picked a new one
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
  _formKey.currentState!.save();

  // Updated logic: Determine what path to send to the SQLite DB
  String? finalImagePath;
  if (_image != null) {
    finalImagePath = await _saveImageToAppDir(_image!);
  } else if (_imageWasRemoved) {
    finalImagePath = null; // User explicitly tapped the delete icon overlay
  } else {
    finalImagePath = _existingImagePath; // Keep original if they didn't touch it
  }
    
  final location = Location(
    id: widget.location?.id, 
    name: _name, 
    address: _address, 
    description: _description,
    imagePath: finalImagePath, // Safely records the modification choice
  );

  if (widget.location == null) {
    await LocationRepo.addLocation(location);
  } else {
    await LocationRepo.updateLocation(location);
  }

  if (!mounted) return;
  Navigator.of(context).pop(true);
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222429),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              
              // Name Field
              TextFormField(
                initialValue: _name,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                onSaved: (v) => _name = v?.trim() ?? '',
              ),

              // Address Field
              TextFormField(
                initialValue: _address,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                onSaved: (v) => _address = v?.trim() ?? '',
              ),

              // Description Field
              TextFormField(
                initialValue: _description,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                minLines: 1,
                maxLines: null,
                validator: (v) => v != null && v.length > 500 
                    ? 'Must be 500 characters or less' 
                    : null,
                onSaved: (v) => _description = v?.trim() ?? '',
              ),
              
              const SizedBox(height: 8),

              // Image Selector Preview Target
              // Fixed layout crash: Moved out of Row into the main Column
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900], // Darkened to match your sleek theme
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : _existingImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(File(_existingImagePath!), fit: BoxFit.cover),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, color: Colors.white54),
                                  SizedBox(height: 4),
                                  Text(
                                    "Tap to select image",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
              
              // Show the delete/clear button overlay ONLY if an image exists
              if (_image != null || _existingImagePath != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removeImage, // Calls the method we will create next
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54, // Semi-transparent dark circular backing
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
      ),

              const SizedBox(height: 12),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ), 
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
