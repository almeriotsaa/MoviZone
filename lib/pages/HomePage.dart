import 'package:flutter/material.dart';
import 'package:movie_app/models/genre.dart';
import 'package:movie_app/pages/DetailPage.dart';
import 'package:movie_app/pages/MovieSwiper.dart';
import '../models/movie.dart';
import '../services/database_service.dart';
import '../services/movie_service.dart';

// ─────────────────────────────────────────
//  SHARED DESIGN TOKENS  (copy to app_theme.dart)
// ─────────────────────────────────────────
class AppTheme {
  // Background palette
  static const Color bgDeep    = Color(0xff08080F);
  static const Color bgCard    = Color(0xff12121E);
  static const Color bgChip    = Color(0xff1C1C2E);
  static const Color bgSurface = Color(0xff1A1A2A);

  // Accent
  static const Color accentBlue  = Color(0xff3D8EFF);
  static const Color accentLight = Color(0xff85B4FF);
  static const Color accentAmber = Color(0xffFFB830);

  // Text
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xffA0A0B8);
  static const Color textMuted     = Color(0xff5A5A7A);

  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentBlue, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xE6000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.45, 1.0],
  );

  // Shared border radius
  static const double radiusCard  = 16.0;
  static const double radiusChip  = 30.0;
  static const double radiusSmall = 8.0;

  // Shared text styles
  static const TextStyle sectionTitle = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle sectionSubtitle = TextStyle(
    color: accentBlue,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MovieService api = MovieService();
  List<Movie>? _trendingMovies;
  List<Movie>? _popularMovies;
  List<Movie>? _topMovies;
  List<Movie>? _upcomingMovies;
  List<Genre>? _genres;

  final DatabaseService _dbService = DatabaseService();

  bool _isLoading = true;
  String selectedGenre   = 'All';
  int?   selectedGenreId;

  String  _username        = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadAllData();
  }

  Future<void> _fetchUserProfile() async {
    if (widget.userId.isEmpty) return;
    try {
      final data = await _dbService.getUserProfile(widget.userId);
      if (data['status'] == 'success' && mounted) {
        setState(() {
          _username        = data['username'] ?? '';
          _profileImageUrl = data['profile_image'];
        });
      }
    } catch (e) {
      debugPrint('Fetch user profile error: $e');
    }
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      api.getTrendingMovies().then((v) => _trendingMovies = v),
      api.getPopularMovies().then((v)  => _popularMovies  = v),
      api.getTopRatedMovies().then((v) => _topMovies      = v),
      api.getUpcomingMovies().then((v) => _upcomingMovies = v),
      api.getGenres().then((v)         => _genres         = v),
    ]);
    setState(() => _isLoading = false);
  }

  String get _displayName => _username.isNotEmpty ? _username : 'User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      // appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: AppTheme.accentBlue))
          : RefreshIndicator(
        onRefresh: _loadAllData,
        color: AppTheme.accentBlue,
        backgroundColor: AppTheme.bgCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInlineHeader(),
              if (_trendingMovies != null && _trendingMovies!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MovieSwiper(
                    movies: _trendingMovies!,
                    userId: widget.userId,
                  ),
                ),

              const SizedBox(height: 24),
              _buildCategorySection(),
              _buildMovieSection('Trending Now',      _trendingMovies),
              _buildMovieSection('Popular',           _popularMovies),
              _buildMovieSection('Top Rated',         _topMovies),
              _buildMovieSection('Coming Soon',       _upcomingMovies),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    _displayName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _profileImageUrl == null
                          ? AppTheme.accentGradient
                          : null,
                      color: _profileImageUrl != null ? AppTheme.bgCard : null,
                      border: Border.all(
                        color: AppTheme.accentBlue.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.transparent,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? Text(
                        _displayName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xff1DBF73),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.bgDeep, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.bgDeep,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _displayName,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _profileImageUrl == null
                ? AppTheme.accentGradient
                : null,
            color: _profileImageUrl != null ? AppTheme.bgCard : null,
            border: Border.all(color: AppTheme.accentBlue.withOpacity(0.4), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            backgroundImage: _profileImageUrl != null
                ? NetworkImage(_profileImageUrl!)
                : null,
            child: _profileImageUrl == null
                ? Text(
              _displayName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Categories', style: AppTheme.sectionTitle),
              Text('See all', style: AppTheme.sectionSubtitle),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 38, child: _buildCategoryList()),
      ],
    );
  }

  Widget _buildCategoryList() {
    if (_genres == null) return const SizedBox();

    final allGenres = [
      {'id': null, 'name': 'All'},
      ..._genres!.map((g) => {'id': g.id, 'name': g.name}),
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: allGenres.length,
      itemBuilder: (context, index) {
        final genre = allGenres[index];
        final isSelected = selectedGenre == genre['name'];
        return GestureDetector(
          onTap: () => setState(() {
            selectedGenre   = genre['name'] as String;
            selectedGenreId = genre['id']   as int?;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.accentGradient : null,
              color: isSelected ? null : AppTheme.bgChip,
              borderRadius: BorderRadius.circular(AppTheme.radiusChip),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppTheme.textMuted.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                genre['name'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovieSection(String title, List<Movie>? movies) {
    final filtered = _filterMovies(movies);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTheme.sectionTitle),
              if (filtered != null && filtered.isNotEmpty)
                const Text('View all', style: AppTheme.sectionSubtitle),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildMovieRow(filtered),
      ],
    );
  }

  List<Movie>? _filterMovies(List<Movie>? movies) {
    if (movies == null) return null;
    if (selectedGenreId == null) return movies;
    return movies.where((m) => m.genreIds.contains(selectedGenreId)).toList();
  }

  Widget _buildMovieRow(List<Movie>? movies) {
    if (movies == null || movies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Text(
            selectedGenreId != null
                ? 'No movies in this category'
                : 'No movies available',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) => _buildMovieCard(movies[index]),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPage(movieId: movie.id, userId: widget.userId),
        ),
      ),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.bgCard,
                        child: const Icon(Icons.broken_image,
                            color: AppTheme.textMuted, size: 28),
                      ),
                    ),
                    // gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: AppTheme.cardOverlay,
                        ),
                      ),
                    ),
                    // Rating badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius:
                          BorderRadius.circular(AppTheme.radiusSmall),
                          border: Border.all(
                              color: AppTheme.accentAmber.withOpacity(0.4),
                              width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppTheme.accentAmber, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}