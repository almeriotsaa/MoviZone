import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http; // Tambahkan ini
import 'dart:convert'; // Tambahkan ini

import '../models/genre.dart';
import '../services/movie_service.dart';

class DetailPage extends StatefulWidget {
  final int movieId;
  // Tambahkan userId di sini agar bisa kirim ke database
  // Untuk sementara kita default "1", nanti sesuaikan dengan sistem loginmu
  final String userId = "1";

  const DetailPage({super.key, required this.movieId});

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

  // --- FUNGSI ADD TO FAVORITE ---
  Future<void> _toggleFavorite() async {
    try {
      // Pastikan URL benar
      var url = Uri.parse("http://172.20.10.6/MOVIZONE_API/favorites/add_favorite.php");

      // Kirim data POST
      var response = await http.post(url, body: {
        "user_id": "2", // PASTIKAN ID INI ADA DI TABEL USERS (misal: 2)
        "movie_id": widget.movieId.toString(), // ID Film dari TMDB
      });

      print("Response dari PHP: ${response.body}"); // Cek di console Android Studio

      final data = json.decode(response.body);

      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil ditambah ke Watchlist! ❤️")),
        );
      } else {
        // Ini akan memunculkan pesan "isi semua field" jika PHP gagal baca data
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
      // --- MENAMBAHKAN TOMBOL FAVORITE (FAB) ---
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

            return SingleChildScrollView( // Tambahkan ScrollView agar tidak overflow
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Poster
                      Image.network(
                        'https://image.tmdb.org/t/p/w500${data.posterPath}',
                        height: 500,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Overlay Gradient (Optional biar teks keliatan)
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
                      // Genres List
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
                                      color: Colors.redAccent.withOpacity(0.7), // Ganti dikit biar kontras
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
                      // Back Button
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
                            onPressed: () => Navigator.pop(context),
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