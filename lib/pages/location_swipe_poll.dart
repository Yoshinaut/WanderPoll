import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:wonder_poll/Model/location.dart';
import 'package:wonder_poll/Repositories/location_repo.dart';

class LocationSwipePoll extends StatefulWidget {
  const LocationSwipePoll({super.key});

  @override
  State<LocationSwipePoll> createState() => _LocationSwipePollState();
}

class _LocationSwipePollState extends State<LocationSwipePoll> {
  final CardSwiperController _swiperController = CardSwiperController();
  List<Location> _locations = [];
  bool _isLoading = true;

  // Track results: Map<LocationId or Name, IsYesVote>
  final Map<String, bool> _pollResults = {};
  bool _isPollFinished = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      // Assuming your LocationRepo has a getAllLocations method
      final data = await LocationRepo.getLocation(); 
      setState(() {
        _locations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations: $e')),
      );
    }
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final location = _locations[previousIndex];
    final key = location.id?.toString() ?? location.name;

    if (direction == CardSwiperDirection.right) {
      _pollResults[key] = true; // Swiped Right = YES
    } else if (direction == CardSwiperDirection.left) {
      _pollResults[key] = false; // Swiped Left = NO
    }
    return true;
  }

  void _onEnd() {
    setState(() {
      _isPollFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1B1F),
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    if (_locations.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1B1F),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text("No locations found to poll!", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1B1F),
      appBar: AppBar(
        title: const Text('Voting', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF222429),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _isPollFinished ? _buildResultsView() : _buildSwiperView(),
      ),
    );
  }

  // --- UI Layout 1: The Swiper Deck ---
  Widget _buildSwiperView() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "Swipe Right for YES, Left for NO",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
        Expanded(
          child: CardSwiper(
            controller: _swiperController,
            cardsCount: _locations.length,
            onSwipe: _onSwipe,
            onEnd: _onEnd,
            allowedSwipeDirection: const AllowedSwipeDirection.only(left: true, right: true),
            numberOfCardsDisplayed: _locations.length > 1 ? 2 : 1,
            backCardOffset: const Offset(0, -20),
            padding: const EdgeInsets.all(24.0),
            cardBuilder: (context, index, percentX, percentY) {
              final loc = _locations[index];
              return _buildSwipeCard(loc);
            },
          ),
        ),
        // Bottom control action buttons for tactile clicking alternative
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                iconSize: 32,
                icon: const Icon(Icons.close, color: Colors.redAccent),
                onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
              ),
              const SizedBox(width: 40),
              IconButton.filled(
                iconSize: 32,
                icon: const Icon(Icons.favorite, color: Colors.greenAccent),
                onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSwipeCard(Location location) {
    final imagePath = location.imagePath;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222429),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 64),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (location.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      location.description,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Layout 2: The Final Results Panel ---
  Widget _buildResultsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              "Poll Summary",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final loc = _locations[index];
                final key = loc.id?.toString() ?? loc.name;
                final voteYes = _pollResults[key] ?? false;

                return Card(
                  color: const Color(0xFF222429),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: loc.imagePath != null && File(loc.imagePath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(File(loc.imagePath!), width: 50, height: 50, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.place, color: Colors.white38),
                    title: Text(loc.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(loc.address, style: const TextStyle(color: Colors.white54), maxLines: 1),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: voteYes ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: voteYes ? Colors.green : Colors.redAccent),
                      ),
                      child: Text(
                        voteYes ? "YES" : "NO",
                        style: TextStyle(color: voteYes ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Finish", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}