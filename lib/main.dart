import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:movie_app/pages/HomePage.dart';
import 'package:movie_app/pages/ExplorePage.dart';
import 'package:movie_app/pages/WatchlistPage.dart';
import 'package:movie_app/pages/ProfilePage.dart';
import 'package:movie_app/pages/SplashScreen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

final GlobalKey<WatchlistPageState> watchlistKey = GlobalKey<WatchlistPageState>();

class MainPage extends StatefulWidget {
  final String userId;
  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  List<Widget> get _pages => [
    HomePage(userId: widget.userId),
    ExplorePage(userId: widget.userId),
    WatchlistPage(key: watchlistKey, userId: widget.userId),
    const ProfilePage(),
  ];

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
          children: _pages,
        ),
        bottomNavigationBar: Container(
          color: const Color(0xff1E1E2C),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: const Color(0xFF2979FF),
            color: Colors.white54,
            tabs: const [
              GButton(icon: Icons.home_outlined, text: 'Home'),
              GButton(icon: Icons.explore, text: 'Explore'),
              GButton(icon: Icons.bookmark_outline, text: 'Favorites'),
              GButton(icon: Icons.person_outline, text: 'Profile'),
            ],
            selectedIndex: currentIndex,
            onTabChange: (index) {
              setState(() {
                currentIndex = index;
              });

              if (index == 2) {
                watchlistKey.currentState?.fetchWatchlist();
              }
            },
          ),
        ),
      ),
    );
  }
}