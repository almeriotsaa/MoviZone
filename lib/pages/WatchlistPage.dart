import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie.dart';
import '../services/movie_service.dart'; // Pastikan import service-mu benar

class WatchlistPage extends StatefulWidget {
  final String userId;

  const WatchlistPage({super.key, required this.userId});

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  // 1. Pastikan nama variabel konsisten (tanpa garis bawah agar sama dengan build)
  List<Movie> favoriteMovies = [];
  bool isLoading = true;

  // 2. Definisikan MovieService agar bisa dipakai
  final MovieService apiService = MovieService();

  @override
  void initState() {
    super.initState();
    _fetchWatchlist(); // Panggil fungsi saat aplikasi dibuka
  }

  Future<void> _fetchWatchlist() async {
    if (!mounted) return;
    setState(() => isLoading = true); // Update: Hapus garis bawah

    try {
      // Sesuaikan IP iPhone kamu lagi jika berubah
      final response = await http.get(
          Uri.parse("http://172.20.10.6/MOVIZONE_API/favorites/get_favorites.php?user_id=2")
      ).timeout(const Duration(seconds: 10));

      print("Data Mentah dari MySQL: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> movieIds = json.decode(response.body);
        List<Movie> tempMovies = [];

        for (var id in movieIds) {
          // 3. Konversi ID dan panggil service
          int cleanId = int.parse(id.toString().trim());
          final movieDetail = await apiService.getMovieById(cleanId); // Gunakan apiService

          if (movieDetail != null) {
            tempMovies.add(movieDetail);
          }
        }

        if (mounted) {
          setState(() {
            favoriteMovies = tempMovies; // Update: Hapus garis bawah
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error Detail: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F1A),
      appBar: AppBar(
        title: const Text("MoviZone Watchlist", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xff1E1E2C),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchWatchlist, // Tombol refresh manual
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : favoriteMovies.isEmpty
          ? const Center(child: Text("Belum ada film favorit nih.", style: TextStyle(color: Colors.white54)))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: favoriteMovies.length,
        itemBuilder: (context, index) {
          final movie = favoriteMovies[index];
          return Card(
            color: const Color(0xff1E1E2C),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                  fit: BoxFit.cover,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, color: Colors.white),
                ),
              ),
              title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text("Rating: ⭐ ${movie.voteAverage.toString()}", style: const TextStyle(color: Colors.white70)),
            ),
          );
        },
      ),
    );
  }
}