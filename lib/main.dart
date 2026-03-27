import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:movie_app/pages/HomePage.dart';
import 'package:movie_app/pages/ExplorePage.dart';
import 'package:movie_app/pages/WatchlistPage.dart';
import 'package:movie_app/pages/ProfilePage.dart';
import 'package:movie_app/pages/SplashScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomePage(),
      const ExplorePage(),
      WatchlistPage(userId: "2"),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex == 0) {
          return true;
        } else {
          setState(() {
            currentIndex = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff0F0F1A),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          color: const Color(0xff1E1E2C),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: GNav(
            key: ValueKey(currentIndex),
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: Colors.blue.withOpacity(0.3),
            color: Colors.white54,
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                text: 'Home',
              ),
              GButton(
                icon: Icons.explore,
                text: 'Explore',
              ),
              GButton(
                icon: Icons.bookmark_outline,
                text: 'Watchlist',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
              ),
            ],
            selectedIndex: currentIndex,
            onTabChange: (index) {
              debugPrint('Tab changed to: $index');
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}