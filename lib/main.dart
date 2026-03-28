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
  // Sekarang MainPage WAJIB menerima userId dari LoginPage
  final String userId;
  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  // Menggunakan Getter agar userId selalu sinkron
  List<Widget> get _pages => [
    // Tambahkan userId: widget.userId di semua halaman ini
    HomePage(userId: widget.userId),
    ExplorePage(userId: widget.userId),
    WatchlistPage(userId: widget.userId),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // initState dikosongkan dari inisialisasi list pages lama yang bikin error
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
          children: _pages, // Memanggil getter _pages
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