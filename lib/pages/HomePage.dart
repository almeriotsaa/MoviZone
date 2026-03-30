import 'package:flutter/material.dart';
import 'package:movie_app/models/genre.dart';
import 'package:movie_app/pages/DetailPage.dart';
import 'package:movie_app/pages/MovieSwiper.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MovieService api = MovieService();
  Future<List<Movie>?>? _trendingMoviesFuture;
  Future<List<Movie>?>? _popularMovies;
  Future<List<Movie>?>? _topMovies;
  Future<List<Movie>?>? _upcomingMovies;
  Future<List<Genre>?>? _genres;

  String selectedGenre = 'All';
  int? selectedGenreId;

  @override
  void initState() {
    super.initState();
    _trendingMoviesFuture = api.getTrendingMovies();
    _popularMovies = api.getPopularMovies();
    _topMovies = api.getTopRatedMovies();
    _upcomingMovies = api.getUpcomingMovies();
    _genres = api.getGenres();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome,', style: TextStyle(color: Colors.white, fontSize: 14),),
            const Text('Frank Ocean', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
          ],
        ),
        actions: [
          const CircleAvatar(
            backgroundImage: NetworkImage(
                'https://upload.wikimedia.org/wikipedia/commons/e/e3/Frank_Ocean_2022_Blonded.jpg'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Movie>?>(
                future: _trendingMoviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return MovieSwiper(
                      movies: snapshot.data!, // Kasih data movies
                      userId: widget.userId,  // Kasih userId
                    );
                  }
                  return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                },
              ),

              const SizedBox(height: 20),
              // ... Bagian Categories tetap sama ...
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Categories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                  Text('See all', style: TextStyle(color: Colors.white, fontSize: 14),),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: FutureBuilder<List<Genre>?>(
                  future: _genres,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
                    final genres = snapshot.data ?? [];
                    final allGenres = [{'id': null, 'name': 'All'}, ...genres.map((g) => {'id': g.id, 'name': g.name})];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: allGenres.length,
                      itemBuilder: (context, index) {
                        final genre = allGenres[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGenre = genre['name'] as String;
                              selectedGenreId = genre['id'] as int?;
                            });
                          },
                          child: _categoryItem(genre['name'] as String, isSelected: selectedGenre == genre['name']),
                        );
                      },
                    );
                  },
                ),
              ),

              // --- FIX 2: List Movie menggunakan Helper agar bersih ---
              _buildSectionTitle('Trending Movies'),
              _buildMovieRow(_trendingMoviesFuture),

              _buildSectionTitle('Popular Movies'),
              _buildMovieRow(_popularMovies),

              _buildSectionTitle('Top Rated Movies'),
              _buildMovieRow(_topMovies),

              _buildSectionTitle('Upcoming Movies'),
              _buildMovieRow(_upcomingMovies),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS AGAR TIDAK REPOT ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMovieRow(Future<List<Movie>?>? future) {
    return FutureBuilder<List<Movie>?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("No Movies", style: TextStyle(color: Colors.white));

        final movies = snapshot.data!;
        final filteredMovies = selectedGenreId == null
            ? movies
            : movies.where((m) => m.genreIds.contains(selectedGenreId)).toList();

        return SizedBox(
          height: 260, // Tinggi ditambah sedikit agar teks tidak overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredMovies.length,
            itemBuilder: (context, index) => _buildMovieCard(context, filteredMovies[index], widget.userId),
          ),
        );
      },
    );
  }

  // FIX 3: DetailPage Navigator sekarang benar
  Widget _buildMovieCard(BuildContext context, Movie movie, String userId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPage(
                  movieId: movie.id,
                  userId: widget.userId, // KIRIM userId KE DETAIL
                )
            )
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                height: 180, width: 150, fit: BoxFit.cover,
                errorBuilder: (context, e, s) => Container(height: 180, width: 150, color: Colors.grey[900]),
              ),
            ),
            const SizedBox(height: 8),
            Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _categoryItem(String title, {bool isSelected = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFF2979FF) : const Color(0xff1E1E2C),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Center(
      child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w500)),
    ),
  );
}