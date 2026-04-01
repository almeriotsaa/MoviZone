import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/database_service.dart';
import '../services/movie_service.dart';
import '../services/auth_service.dart';
import 'LoginPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String  userId          = '';
  String  email           = '';
  String  username        = '';
  String? profileImageUrl;

  bool isLoading     = true;
  bool isSaving      = false;
  bool isLoadingFavs = true;

  List<Movie> favoriteMovies = [];

  final MovieService _movieService = MovieService();
  final AuthService  _authService  = AuthService();
  final DatabaseService _dbService = DatabaseService();

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  static const Color _bgPrimary   = Color(0xff0D0D1A);
  static const Color _bgCard      = Color(0xff1A1A2E);
  static const Color _bgHeader    = Color(0xff12122A);
  static const Color _accentBlue  = Color(0xff2979FF);
  static const Color _accentLight = Color(0xff82b1ff);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadAll();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await _loadUserFromPrefs();
    await Future.wait([_fetchProfile(), _fetchFavorites()]);
    _animCtrl.forward(from: 0);
  }

  Future<void> _loadUserFromPrefs() async {
    final data = await _authService.getLoginData();
    if (data != null && mounted) {
      setState(() {
        userId = data['userId'] ?? '';
        email  = data['email']  ?? '';
      });
    }
  }

  Future<void> _fetchProfile() async {
    if (userId.isEmpty) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final data = await _dbService.getUserProfile2(userId);

      if (data['status'] == 'success' && mounted) {
        setState(() {
          username        = data['username'] ?? '';
          email           = data['email'] ?? email;
          profileImageUrl = data['profile_image'];
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_username', username);
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchFavorites() async {
    if (userId.isEmpty) {
      if (mounted) setState(() => isLoadingFavs = false);
      return;
    }

    try {
      final ids = await _dbService.getFavorites2(userId);

      final movies = await Future.wait(ids.map((id) async {
        int cleanId = int.parse(id.toString().trim());
        return await _movieService.getMovieById(cleanId);
      }));

      if (mounted) {
        setState(() =>
        favoriteMovies = movies.whereType<Movie>().toList());
      }
    } catch (e) {
      debugPrint('Fetch favorites error: $e');
    } finally {
      if (mounted) setState(() => isLoadingFavs = false);
    }
  }

  void _showEditProfileSheet() {
    final usernameCtrl = TextEditingController(text: username);
    File? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => AnimatedPadding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          duration: const Duration(milliseconds: 150),
          child: Container(
            decoration: const BoxDecoration(
              color: _bgCard,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                const Text('Edit Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                          maxWidth: 600,
                        );
                        if (picked != null) {
                          setSheet(() => pickedImage = File(picked.path));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            _accentBlue,
                            _accentLight,
                          ]),
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: _bgPrimary,
                          backgroundImage: pickedImage != null
                              ? FileImage(pickedImage!) as ImageProvider
                              : (profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : null),
                          child: (pickedImage == null &&
                              profileImageUrl == null)
                              ? Text(
                            _displayName.isNotEmpty
                                ? _displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                            maxWidth: 600,
                          );
                          if (picked != null) {
                            setSheet(
                                    () => pickedImage = File(picked.path));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: _accentBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (profileImageUrl != null && pickedImage == null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDeletePhoto();
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 16),
                    label: const Text('Remove profile photo',
                        style: TextStyle(
                            color: Colors.redAccent, fontSize: 13)),
                  )
                else
                  const SizedBox(height: 4),

                const SizedBox(height: 8),

                TextField(
                  controller: usernameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.person_outline,
                        color: Colors.white38),
                    filled: true,
                    fillColor: _bgPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: _accentBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                      Navigator.pop(ctx);
                      await _saveProfile(
                        newUsername: usernameCtrl.text.trim(),
                        imageFile: pickedImage,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeletePhoto() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Profile Photo',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
            'Your profile photo will be permanently deleted.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deletePhoto();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto() async {
    setState(() => isSaving = true);

    try {
      final data = await _dbService.deleteProfileImage(userId);

      if (data['status'] == 'success' && mounted) {
        setState(() => profileImageUrl = null);
        _showSnackBar('Profile photo removed successfully', isError: false);
      } else {
        _showSnackBar(data['message'] ?? 'Failed to remove photo');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _saveProfile({
    required String newUsername,
    File? imageFile,
  }) async {
    if (newUsername.isEmpty && imageFile == null) return;

    setState(() => isSaving = true);

    try {
      final data = await _dbService.updateProfile(
        userId: userId,
        username: newUsername,
        imageFile: imageFile,
      );

      if (data['status'] == 'success' && mounted) {
        setState(() {
          username        = data['username'] ?? newUsername;
          profileImageUrl = data['profile_image'] ?? profileImageUrl;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_username', username);

        _showSnackBar('Profile updated successfully ✅', isError: false);
      } else {
        _showSnackBar(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : _accentBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  String get _displayName =>
      username.isNotEmpty ? username : email.split('@').first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPrimary,
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(color: _accentBlue))
          : FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              _buildProfileHeader(),

              _buildFavoritesHeader(),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadAll,
                  color: _accentBlue,
                  child: _buildScrollableGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0e1240), _bgPrimary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [_accentBlue, _accentLight]),
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: _bgCard,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? Text(
                    _displayName.isNotEmpty
                        ? _displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                      : null,
                ),
              ),
              if (isSaving)
                const Positioned(
                  bottom: 0, right: 0,
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _accentBlue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _displayName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(email,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderBtn(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: _showEditProfileSheet,
                isPrimary: true,
              ),
              const SizedBox(width: 12),
              _buildHeaderBtn(
                icon: Icons.logout_rounded,
                label: 'Logout',
                onTap: _confirmLogout,
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesHeader() {
    return Container(
      color: _bgPrimary,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          const Icon(Icons.favorite_rounded, color: _accentBlue, size: 20),
          const SizedBox(width: 8),
          const Text('Favorite Movies',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          if (!isLoadingFavs)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _accentBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${favoriteMovies.length} movies',
                  style: const TextStyle(
                      color: _accentBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollableGrid() {
    if (isLoadingFavs) {
      return const Center(
        child: CircularProgressIndicator(color: _accentBlue),
      );
    }
    if (favoriteMovies.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildEmptyState(
            icon: Icons.movie_filter_outlined,
            text: 'No favorite movies yet',
            sub: 'Add movies from the Explore or Movie Detail page',
          ),
        ],
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: favoriteMovies.length,
      itemBuilder: (_, index) => _buildMovieTile(favoriteMovies[index]),
    );
  }

  Widget _buildHeaderBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? _accentBlue
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white24, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String text,
    required String sub,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.white.withOpacity(0.12)),
            const SizedBox(height: 12),
            Text(text,
                style:
                const TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 4),
            Text(sub,
                style: const TextStyle(
                    color: Colors.white24, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieTile(Movie movie) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://image.tmdb.org/t/p/w300${movie.posterPath}',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: _bgCard,
              child: const Icon(Icons.broken_image,
                  color: Colors.white24, size: 32),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 6, right: 6, bottom: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.2),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.amber, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}