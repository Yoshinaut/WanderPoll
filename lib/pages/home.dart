import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:wonder_poll/pages/location_swipe_poll.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wonder_poll/pages/chat.dart';
import 'package:wonder_poll/pages/locations.dart';
import 'package:wonder_poll/pages/feed.dart';
import 'package:wonder_poll/pages/profile.dart';
import 'package:wonder_poll/pages/About.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List <Widget> _pages = const[
  Profile(),
  Messaging(),
  Feed(),
  Locations(),
  About()
  ];

  final List<String> _titles = [
  "Profile",
  "Messages",
  "Wander-Poll",
  "Locations",
  "Settings"
  ];

  AppBar appBar() {
    return AppBar(
      toolbarHeight: 50,
      title: Text(_titles[_currentIndex],
      style: GoogleFonts.getFont('Poppins',
      fontSize: 18, 
      fontWeight: FontWeight.bold,
      color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor:Color(0xFFad2a2a),
      leading: Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:Color(0xFFad2a2a),
          borderRadius: BorderRadius.circular(10)
        ),
        child: SvgPicture.asset('assets/svg/compass-svgrepo-com.svg'),
      ),

      actions: [
        Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:Color(0xFFad2a2a),
          borderRadius: BorderRadius.circular(10)
        ),
        child: SvgPicture.asset('assets/svg/map-svgrepo-com.svg'),
      ),
      ],
    );
  }

  NavigationBar navBar() {
    return NavigationBar(

    height: 60,
    backgroundColor: Color(0xFFad2a2a),

    onDestinationSelected: (value) {
      setState(() {
          _currentIndex = value;
        }); 
      },
    selectedIndex: _currentIndex,

    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    labelTextStyle:WidgetStatePropertyAll(
        const TextStyle(fontSize: 16)),

    destinations: [
      NavigationDestination(icon: Icon(Icons.account_circle_rounded), label: "Profile"),
      NavigationDestination(icon: Icon(Icons.message), label: "Chat"),
      NavigationDestination(icon: Icon(Icons.home), label: "Home"),
      NavigationDestination(icon: Icon(Icons.map), label: "Locations"),
      NavigationDestination(icon: Icon(Icons.info), label: "About"),
    ],);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222429),
      appBar: appBar(),
      bottomNavigationBar: navBar(),

      floatingActionButton: 
      (_currentIndex == 3 || _currentIndex == 1) ? null:
      SpeedDial(

        spacing: 10,
        spaceBetweenChildren: 6,

        overlayColor: Colors.black,
        overlayOpacity: 0.4,

        backgroundColor: Color(0xFFad2a2a),
        foregroundColor: Colors.white,
        
        animatedIcon: AnimatedIcons.add_event,

        children: [
          SpeedDialChild(
            child: Icon(Icons.poll),
            backgroundColor: Colors.red,
            label: 'New Poll',
            onTap: () {
              Navigator.of(context).push(
              MaterialPageRoute(
              builder: (context) => const LocationSwipePoll(),
          ),
        );
      },
    ),

          SpeedDialChild(
            child: Icon(Icons.place),
            backgroundColor: Colors.red,
            label: 'Edit Locations',
            onTap: (){
              setState(() {
                _currentIndex = 2;
              });
            }),
    
          SpeedDialChild(
            child: Icon(Icons.chat),
            backgroundColor: Colors.red,
            label: 'New Message',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar( 
                content: Text('Feature not yet available'),
                duration: Duration(seconds: 2), // How long it stays on screen
              ));
            })
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

  );
  }
}
