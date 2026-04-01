import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/database_service.dart';
import '../services/movie_service.dart';
import '../main.dart';
// import 'package:movie_app/app_theme.dart';

class WatchlistPage extends StatefulWidget {
  final String userId;
  const WatchlistPage({super.key, required this.userId});

  @override
  WatchlistPageState createState() => WatchlistPageState();
}

class WatchlistPageState extends State<WatchlistPage>
    with RouteAware, SingleTickerProviderStateMixin {
  List<Movie> favoriteMovies = [];
  bool isLoading = true;
  final MovieService apiService = MovieService();
  final DatabaseService _dbService = DatabaseService();

  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    fetchWatchlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => fetchWatchlist();

  Future<void> fetchWatchlist() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final movieIds = await _dbService.getFavorites(widget.userId);
      final tempMovies = await Future.wait(
        movieIds.map((id) async {
          int cleanId = int.parse(id.toString().trim());
          return await apiService.getMovieById(cleanId);
        }),
      );
      if (mounted) {
        setState(() {
          favoriteMovies = tempMovies.whereType<Movie>().toList();
          isLoading = false;
        });
        _animCtrl.forward(from: 0);
      }
    } catch (e) {
      debugPrint('Watchlist error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteFromDatabase(int movieId) async {
    await _dbService.deleteFavorite(userId: widget.userId, movieId: movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchWatchlist,
                color: AppTheme.accentBlue,
                backgroundColor: AppTheme.bgCard,
                child: isLoading
                    ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accentBlue))
                    : favoriteMovies.isEmpty
                    ? _buildEmptyState()
                    : _buildMovieList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.bgDeep,
        border: Border(
          bottom: BorderSide(
              color: AppTheme.textMuted.withOpacity(0.15), width: 1),
        ),
      ),
      child: Row(
        children: [
          Column(
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
                    'Favorite Movies',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Text(
                  isLoading
                      ? 'Loading...'
                      : '${favoriteMovies.length} saved movie${favoriteMovies.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: fetchWatchlist,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.bgChip,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.textMuted.withOpacity(0.2), width: 1),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: AppTheme.accentBlue, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.textMuted.withOpacity(0.15), width: 1),
                ),
                child: const Icon(Icons.bookmark_add_outlined,
                    color: AppTheme.textMuted, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your watchlist is empty',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Save movies from Explore or\nthe movie detail page',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMovieList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: favoriteMovies.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animCtrl,
          builder: (_, child) {
            final delay = (index * 0.08).clamp(0.0, 0.8);
            final t = (((_animCtrl.value - delay) / (1.0 - delay))
                .clamp(0.0, 1.0));
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - t)),
                child: child,
              ),
            );
          },
          child: _buildMovieCard(favoriteMovies[index], index),
        );
      },
    );
  }

  Widget _buildMovieCard(Movie movie, int index) {
    return Dismissible(
      key: Key(movie.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 26),
            SizedBox(height: 4),
            Text('Remove',
                style: TextStyle(color: Colors.redAccent, fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (direction) {
        final title = movie.title;
        _deleteFromDatabase(movie.id);
        setState(() => favoriteMovies.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title removed from Watchlist'),
            backgroundColor: AppTheme.bgSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
              color: AppTheme.textMuted.withOpacity(0.12), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                  width: 60,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60, height: 85,
                    color: AppTheme.bgChip,
                    child: const Icon(Icons.broken_image,
                        color: AppTheme.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppTheme.accentAmber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                              color: AppTheme.accentAmber,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Saved',
                              style: TextStyle(
                                  color: AppTheme.accentBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 20),
            ],
          ),
        ),
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
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xE6000000)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
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