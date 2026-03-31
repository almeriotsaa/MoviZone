import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';

import '../models/cast.dart';
import '../models/genre.dart';
import '../services/movie_service.dart';

class DetailPage extends StatefulWidget {
  final int movieId;
  final String userId;

  const DetailPage({super.key, required this.movieId, required this.userId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final MovieService api = MovieService();

  Future<Movie?>? _detailMovie;
  Future<List<Genre>?>? _genres;
  Future<String?>? _trailer;
  Future<List<Cast>?>? _cast;

  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _detailMovie = api.getMovieById(widget.movieId);
    _genres = api.getGenres();
    _trailer = api.getMovieTrailer(widget.movieId).then((videoId) {
      if (videoId != null) {
        // Controller dibuat sekali di sini, bukan di dalam build
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
      return videoId;
    });
    _cast = api.getMovieCast(widget.movieId);
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    try {
      final url = Uri.parse(
        "http://192.168.1.14/MOVIZONE_API/favorites/add_favorite.php",
      );

      final response = await http.post(url, body: {
        "user_id": widget.userId,
        "movie_id": widget.movieId.toString(),
      });

      final data = json.decode(response.body);

      if (!mounted) return;

      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil ditambah ke Watchlist! ❤️")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server: ${data['message']}")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _toggleFavorite,
        child: const Icon(Icons.favorite, color: Colors.white),
      ),
      body: FutureBuilder<Movie?>(
        future: _detailMovie,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text('Error', style: TextStyle(color: Colors.white)),
            );
          }

          final movie = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero: Trailer atau Backdrop ──
                _buildHeroSection(movie),

                // ── Title, Release Date, Rating ──
                _buildInfoSection(movie),

                // ── Overview ──
                _buildOverviewSection(movie),

                _buildCastSection(),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // HERO: Trailer jika ada, fallback ke Backdrop
  // ─────────────────────────────────────────
  Widget _buildHeroSection(Movie movie) {
    return FutureBuilder<String?>(
      future: _trailer,
      builder: (context, snapshot) {
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final bool hasTrailer = snapshot.data != null && _youtubeController != null;

        return Stack(
          children: [
            // ── Konten utama: loading / trailer / backdrop ──
            if (isLoading)
              Container(
                height: 260,
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (hasTrailer)
            // Ada trailer → tampilkan YouTube player
              YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                ),
                builder: (context, player) => player,
              )
            else
            // Tidak ada trailer → fallback ke backdrop image
              Image.network(
                'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                ),
              ),

            // ── Gradient overlay (hanya saat backdrop / loading, agar genre chips terbaca) ──
            if (!hasTrailer)
              Container(
                height: 260,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),

            // ── Genre chips (hanya tampil saat tidak ada trailer) ──
            if (!isLoading && !hasTrailer)
              Positioned(
                bottom: 12,
                left: 16,
                right: 0,
                child: SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: movie.genres.length,
                    itemBuilder: (context, index) {
                      final genre = movie.genres[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          genre.name,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // ── Tombol back (selalu tampil) ──
            Positioned(
              top: 40,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // TITLE + RELEASE DATE + RATING
  // ─────────────────────────────────────────
  Widget _buildInfoSection(Movie movie) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Release Date: ${movie.releaseDate}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),

          // Genre chips di bawah rating (saat trailer tampil, chips pindah ke sini)
          const SizedBox(height: 12),
          FutureBuilder<String?>(
            future: _trailer,
            builder: (context, snapshot) {
              final bool hasTrailer = snapshot.data != null;
              if (!hasTrailer) return const SizedBox.shrink();

              // Trailer ada → tampilkan genre chips di bawah info
              return SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movie.genres.length,
                  itemBuilder: (context, index) {
                    final genre = movie.genres[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        genre.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // OVERVIEW
  // ─────────────────────────────────────────
  Widget _buildOverviewSection(Movie movie) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    return FutureBuilder<List<Cast>?>(
      future: _cast,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final castList = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cast",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: castList.length,
                  itemBuilder: (context, index) {
                    final cast = castList[index];

                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FOTO ACTOR
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: cast.profilePath.isNotEmpty
                                ? Image.network(
                              "https://image.tmdb.org/t/p/w200${cast.profilePath}",
                              height: 110,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              height: 110,
                              width: 100,
                              color: Colors.grey[800],
                              child: const Icon(Icons.person, color: Colors.white54),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // NAMA ACTOR
                          Text(
                            cast.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),

                          // CHARACTER
                          Text(
                            cast.character,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}