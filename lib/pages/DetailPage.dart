import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  MovieService api = MovieService();
  Future<Movie?>? _detailMovie;
  Future<List<Genre>?>? _genres;

  @override
  void initState() {
    _detailMovie = api.getMovieById(widget.movieId);
    _genres = api.getGenres();
    super.initState();
  }

  Future<void> _toggleFavorite() async {
    try {
      var url = Uri.parse("http://192.168.1.14/MOVIZONE_API/favorites/add_favorite.php");

      var response = await http.post(url, body: {
        "user_id": widget.userId,
        "movie_id": widget.movieId.toString(),
      });

      print("Response dari PHP: ${response.body}");

      final data = json.decode(response.body);

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
      print("Error: $e");
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
      body: FutureBuilder(
        future: _detailMovie,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error', style: TextStyle(color: Colors.white)));
          } else {
            final data = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.network(
                        'https://image.tmdb.org/t/p/w500${data.posterPath}',
                        height: 500,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 500,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 0,
                        child: SizedBox(
                          height: 40,
                          child: FutureBuilder<List<Genre>?>(
                            future: _genres,
                            builder: (context, genreSnapshot) {
                              final movieGenres = data.genres;
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: movieGenres.length,
                                itemBuilder: (context, index) {
                                  final genre = movieGenres[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlueAccent.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      genre.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 20,
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
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Release Date: ${data.releaseDate}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.yellow, size: 16),
                                const SizedBox(width: 4),
                                Text(data.voteAverage.toStringAsFixed(1), style: const TextStyle(fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(data.overview, style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5), textAlign: TextAlign.justify),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}