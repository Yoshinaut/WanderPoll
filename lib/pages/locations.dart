import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wonder_poll/Model/location.dart';
import 'package:wonder_poll/Repositories/location_repo.dart';
import 'package:wonder_poll/pages/locationforms.dart';

class Locations extends StatefulWidget {
  const Locations({super.key});

  @override
  State<Locations> createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  bool _isLoading = true;
  List<Location> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    final data = await LocationRepo.getLocation();
    setState(() {
      _locations = data;
      _isLoading = false;
    });
  }

  void _showLocationFormDialog({Location? location}) async {
    final title = location == null ? "Add Location" : 'Edit Location';
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF222429),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 600,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: 20,
                  ),
                        ),
                        const SizedBox(height: 16),
                        LocationForms(location: location),
                      ],
                    ),
                  ),
                ),
              ),
    );
      },
    );

    if (result == true) {
      await _loadLocations();
    }
  }

  // Feature: Prompts a visual overlay dialog before destroying records
  Future<bool> _showDeleteConfirmationDialog(String locationName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF222429),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Location',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "$locationName"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // Changed: Intercepts workflow to request deletion approval first
  void _deleteLocation(Location location) async {
    if (location.id == null) return;
    
    final confirmed = await _showDeleteConfirmationDialog(location.name);
    if (!confirmed) return;

    await LocationRepo.deleteLocation(location.id!);
    await _loadLocations();
  }

  ImageProvider _buildImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return const AssetImage('');
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }
    return FileImage(File(imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222429),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              : _locations.isEmpty
                  ? const Center(
                      child: Text(
                        "No locations available.\nTap '+' to create one.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _locations.length,
                      itemBuilder: (context, index) {
                        final location = _locations[index];
                        final hasValidImage = location.imagePath != null && location.imagePath!.isNotEmpty;

                        return Card(
                          color: const Color(0xFF1A1C20),
                          surfaceTintColor: Colors.transparent,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _showLocationFormDialog(location: location),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Changed: 90x90 Custom Rectangular Image Container
                                  SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: hasValidImage
                                          ? Image(
                                              image: _buildImageProvider(location.imagePath),
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: Colors.redAccent,
                                              alignment: Alignment.center,
                                              child: Text(
                                                location.name.isNotEmpty ? location.name[0].toUpperCase() : '?',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  
                                  // Text Area Expansion Block
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 2),
                                        Text(
                                          location.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          location.address,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Right Action Button
                                  IconButton(
                                    alignment: Alignment.topRight,
                                    onPressed: () => _deleteLocation(location),
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.redAccent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFAD2A2A),
        foregroundColor: Colors.white,
        onPressed: () => _showLocationFormDialog(),child: const Icon(Icons.add),
        ),
      );
    }
}
