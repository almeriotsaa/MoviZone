import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';

import '../models/cast.dart';
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

  Movie? _movie;
  List<Cast>? _cast;

  bool _isLoading = true;
  bool _isCastLoading = true;

  YoutubePlayerController? _youtubeController;
  bool _hasTrailer = false;
  bool _playerError = false; // ← flag error player

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final movie = await api.getMovieById(widget.movieId);
      final cast = await api.getMovieCast(widget.movieId);
      final videoId = await api.getMovieTrailer(widget.movieId);

      if (videoId != null && videoId.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: false,
            forceHD: false,
          ),
        );

        // ← Listener untuk detect error playback
        _youtubeController!.addListener(() {
          if (_youtubeController!.value.hasError && !_playerError) {
            if (mounted) {
              setState(() {
                _playerError = true;
              });
            }
          }
        });

        _hasTrailer = true;
      }

      if (mounted) {
        setState(() {
          _movie = movie;
          _cast = cast;
          _isLoading = false;
          _isCastLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCastLoading = false;
        });
      }
    }
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
          const SnackBar(
            content: Text("Berhasil ditambah ke Watchlist! ❤️"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server: ${data['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menambahkan ke watchlist"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder( // ← Wrap dengan YoutubePlayerBuilder
      player: YoutubePlayer(
        controller: _youtubeController ?? YoutubePlayerController(initialVideoId: ''),
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.redAccent,
        onReady: () {
          debugPrint("Player ready");
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            onPressed: _toggleFavorite,
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _movie == null
              ? const Center(
            child: Text('Error loading movie',
                style: TextStyle(color: Colors.white)),
          )
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(_movie!, player), // ← pass player
                _buildInfoSection(_movie!),
                _buildOverviewSection(_movie!),
                _buildCastSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(Movie movie, Widget player) {
    return Stack(
      children: [
        // ← Tampilkan player hanya jika ada trailer DAN tidak error
        if (_hasTrailer && !_playerError)
          SizedBox(
            height: 260,
            width: double.infinity,
            child: player,
          )
        else
        // ← Fallback ke backdrop image
          Stack(
            children: [
              Image.network(
                'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: Colors.grey[900],
                  child: const Icon(Icons.movie, color: Colors.white24, size: 64),
                ),
              ),
              // ← Info bahwa trailer tidak tersedia
              if (_playerError)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, color: Colors.white54, size: 14),
                          SizedBox(width: 6),
                          Text(
                            "Trailer tidak tersedia untuk diputar",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

        // Gradient overlay (hanya saat tidak ada player aktif)
        if (!_hasTrailer || _playerError)
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

        // Back button
        Positioned(
          top: 28,
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
  }

  // _buildInfoSection, _buildOverviewSection, _buildCastSection
  // → SAMA PERSIS seperti kode asli kamu, tidak perlu diubah
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
          const SizedBox(height: 12),
          SizedBox(
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
        ],
      ),
    );
  }

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
            movie.overview.isNotEmpty ? movie.overview : "No overview available",
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
    if (_isCastLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_cast == null || _cast!.isEmpty) {
      return const SizedBox();
    }

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
              itemCount: _cast!.length,
              itemBuilder: (context, index) {
                final cast = _cast![index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: cast.profilePath.isNotEmpty
                            ? Image.network(
                          "https://image.tmdb.org/t/p/w200${cast.profilePath}",
                          height: 110,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 110,
                            width: 100,
                            color: Colors.grey[800],
                            child: const Icon(Icons.person,
                                color: Colors.white54),
                          ),
                        )
                            : Container(
                          height: 110,
                          width: 100,
                          color: Colors.grey[800],
                          child: const Icon(Icons.person,
                              color: Colors.white54),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cast.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        cast.character,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
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
  }
}