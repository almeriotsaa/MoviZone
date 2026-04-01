import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/movie_service.dart';
import 'DetailPage.dart';

// Import AppTheme from HomePage.dart or a shared app_theme.dart
// import 'package:movie_app/app_theme.dart';

class ExplorePage extends StatefulWidget {
  final String userId;
  const ExplorePage({super.key, required this.userId});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  MovieService api = MovieService();
  Future<List<Movie>?>? _trendingMovies;
  Future<List<Movie>?>? _searchResults;

  List<String> _recentSearches = [];
  bool _isSearching = false;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _trendingMovies = api.getTrendingMovies();

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) _recentSearches = _recentSearches.sublist(0, 5);
    });
  }

  void _clearRecentSearches() => setState(() => _recentSearches.clear());

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() { _isSearching = false; _searchResults = null; });
      return;
    }
    setState(() { _isSearching = true; _searchResults = MovieService.searchMovies(query); });
    _addToRecentSearches(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() { _isSearching = false; _searchResults = null; });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              if (!_isSearching && _recentSearches.isNotEmpty) _buildRecentSearches(),
              Expanded(
                child: _isSearching
                    ? _buildSearchResults()
                    : _buildTrendingGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Discover',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'Find your next favourite film 🎬',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.bgChip,
          borderRadius: BorderRadius.circular(AppTheme.radiusChip),
          border: Border.all(
            color: _searchFocusNode.hasFocus
                ? AppTheme.accentBlue.withOpacity(0.6)
                : AppTheme.textMuted.withOpacity(0.25),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: AppTheme.accentBlue, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search movies, genres...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: _performSearch,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: _clearSearch,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: _clearRecentSearches,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final search = _recentSearches[index];
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgChip,
                      borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                      border: Border.all(
                          color: AppTheme.textMuted.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history_rounded,
                            color: AppTheme.textMuted, size: 14),
                        const SizedBox(width: 6),
                        Text(search,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            children: [
              const Text('Trending', style: AppTheme.sectionTitle),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('🔥 Hot',
                    style: TextStyle(color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Movie>?>(
            future: _trendingMovies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentBlue));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                    icon: Icons.movie_creation_outlined,
                    label: 'Failed to load movies');
              }
              return _buildMovieGrid(snapshot.data!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Movie>?>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentBlue));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildEmptyState(
              icon: Icons.error_outline_rounded, label: 'Search failed');
        }
        final movies = snapshot.data!;
        if (movies.isEmpty) {
          return _buildEmptyState(
              icon: Icons.search_off_rounded, label: 'No movies found');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Results ',
                        style: TextStyle(color: AppTheme.textPrimary,
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    TextSpan(
                        text: '(${movies.length})',
                        style: const TextStyle(color: AppTheme.accentBlue,
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildMovieGrid(movies)),
          ],
        );
      },
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) => _buildMovieGridItem(movies[index]),
    );
  }

  Widget _buildMovieGridItem(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailPage(movieId: movie.id, userId: widget.userId)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
              color: AppTheme.textMuted.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusCard)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.bgChip,
                        child: const Icon(Icons.broken_image,
                            color: AppTheme.textMuted, size: 28),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                            gradient: AppTheme.cardOverlay),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
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
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      movie.releaseDate,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String label}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 52, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

// Paste AppTheme here or import from shared file
class AppTheme {
  static const Color bgDeep    = Color(0xff08080F);
  static const Color bgCard    = Color(0xff12121E);
  static const Color bgChip    = Color(0xff1C1C2E);
  static const Color bgSurface = Color(0xff1A1A2A);
  static const Color accentBlue  = Color(0xff3D8EFF);
  static const Color accentLight = Color(0xff85B4FF);
  static const Color accentAmber = Color(0xffFFB830);
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xffA0A0B8);
  static const Color textMuted     = Color(0xff5A5A7A);
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
  static const double radiusCard  = 16.0;
  static const double radiusChip  = 30.0;
  static const double radiusSmall = 8.0;
  static const TextStyle sectionTitle = TextStyle(
    color: textPrimary, fontSize: 18,
    fontWeight: FontWeight.w700, letterSpacing: 0.2,
  );
  static const TextStyle sectionSubtitle = TextStyle(
    color: accentBlue, fontSize: 13, fontWeight: FontWeight.w500,
  );
}