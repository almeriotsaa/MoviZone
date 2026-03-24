import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:movie_app/pages/HomePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;


  late AnimationController _titleController;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;


  late AnimationController _taglineController;
  late Animation<double> _taglineOpacity;


  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();


    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);


    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );


    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );


    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );


    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );


    _startAnimations();
  }

  void _startAnimations() async {

    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();


    await Future.delayed(const Duration(milliseconds: 600));
    _titleController.forward();


    await Future.delayed(const Duration(milliseconds: 400));
    _taglineController.forward();


    await Future.delayed(const Duration(milliseconds: 200));
    _loadingController.forward();


    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _taglineController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),


          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlueAccent.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlueAccent.withOpacity(0.03),
              ),
            ),
          ),


          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E1E2C),
                          Color(0xFF0D1B2A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.lightBlueAccent.withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.lightBlueAccent.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.movie_filter_rounded,
                      color: Colors.lightBlueAccent,
                      size: 52,
                    ),
                  ),
                ),

                const SizedBox(height: 28),


                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Movi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Z',
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: 'One',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),


                FadeTransition(
                  opacity: _taglineOpacity,
                  child: const Text(
                    'Your Ultimate Movie Universe',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),

                const SizedBox(height: 60),


                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 180,
                          height: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _loadingController.value,
                              backgroundColor:
                              const Color(0xFF1E1E2C),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.lightBlueAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: _loadingController.value,
                          child: const Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineOpacity,
              child: const Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}