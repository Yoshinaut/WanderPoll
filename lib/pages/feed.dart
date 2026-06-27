import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wonder_poll/Model/location.dart';
import 'package:wonder_poll/Repositories/location_repo.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<Location> _allLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  // Fetch the data from your LocationRepo
  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    try {
      // Direct call to your repo file assuming it has a getAllLocations or similar method
      final locations = await LocationRepo.getLocation(); 
      setState(() {
        _allLocations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading locations: $e");
    }
  }

  void _showLocationDetailsDialog(Location location) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: const Color(0xFF222429),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.75, // Keeps it bound to 75% of screen
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Featured Image Header
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                clipBehavior: Clip.antiAlias,
                child: location.imagePath != null && File(location.imagePath!).existsSync()
                    ? Image.file(File(location.imagePath!), fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 50),
                      ),
              ),

              // 2. Scrollable Info Area
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.address,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Colors.white10),
                      ),
                      const Text(
                        "Description",
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        location.description.isNotEmpty 
                            ? location.description 
                            : "No description provided for this location.",
                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Action Buttons
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222429),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1C20),
        title: const Text('Explore Locations', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          // 1. Top Search Button using Flutter's built-in SearchAnchor
          SearchAnchor(
            viewBackgroundColor: const Color(0xFF1A1C20),
            builder: (BuildContext context, SearchController controller) {
              return IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => controller.openView(),
              );
            },
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              final keyword = controller.text.toLowerCase();
              
              // Filter locations based on search keyword
              final filtered = _allLocations.where((loc) {
                return loc.name.toLowerCase().contains(keyword) || 
                       loc.address.toLowerCase().contains(keyword);
              }).toList();

              return filtered.map((location) {
                return ListTile(
                  leading: _buildLeadingAvatar(location.imagePath),
                  title: Text(location.name),
                  subtitle: Text(location.address),
                  onTap: () {
                    controller.closeView(location.name);
                    // Handle what happens when a user clicks a search item (e.g., Navigate to details)
                  },
                );
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _allLocations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadLocations,
                  color: Colors.redAccent,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gallery",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 2. Scrollable Gallery Grid
                        GridView.builder(
                          shrinkWrap: true, // Let GridView conform to its children size
                          physics: const NeverScrollableScrollPhysics(), // Let SingleChildScrollView handle scrolling
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 items per row
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8, // Adjust ratio to fit elements nicely
                          ),
                          itemCount: _allLocations.length,
                          itemBuilder: (context, index) {
                            final location = _allLocations[index];
                            return _buildGalleryCard(location);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
// Card Widget inside the Gallery Grid
Widget _buildGalleryCard(Location location) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF2A2D34),
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      // 1. Wrap the card content with InkWell to handle taps with a ripple effect
      onTap: () => _showLocationDetailsDialog(location),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image segment
          Expanded(
            child: location.imagePath != null && File(location.imagePath!).existsSync()
                ? Image.file(File(location.imagePath!), fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.image_not_supported, color: Colors.white30),
                  ),
          ),
          // Details segment
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  location.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  location.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildLeadingAvatar(String? imagePath) {
    if (imagePath != null && File(imagePath).existsSync()) {
      return CircleAvatar(backgroundImage: FileImage(File(imagePath)));
    }
    return const CircleAvatar(child: Icon(Icons.location_on));
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No locations found.\nTap the add button to insert one!",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}