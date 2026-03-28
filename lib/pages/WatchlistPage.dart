import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie.dart';
import '../services/movie_service.dart';

class WatchlistPage extends StatefulWidget {
  final String userId;

  const WatchlistPage({super.key, required this.userId});

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  List<Movie> favoriteMovies = [];
  bool isLoading = true;
  final MovieService apiService = MovieService();

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  // --- FUNGSI AMBIL DATA ---
  Future<void> _fetchWatchlist() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(
          Uri.parse("http://192.168.1.17/MOVIZONE_API/favorites/get_favorites.php?user_id=${widget.userId}")
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> movieIds = json.decode(response.body);
        List<Movie> tempMovies = [];

        for (var id in movieIds) {
          int cleanId = int.parse(id.toString().trim());
          final movieDetail = await apiService.getMovieById(cleanId);

          if (movieDetail != null) {
            tempMovies.add(movieDetail);
          }
        }

        if (mounted) {
          setState(() {
            favoriteMovies = tempMovies;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error Detail: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- FUNGSI HAPUS (API) ---
  Future<void> _deleteFromDatabase(int movieId) async {
    try {
      await http.post(
        Uri.parse("http://192.168.1.17/MOVIZONE_API/favorites/delete_favorite.php"),
        body: {
          "user_id": "widget.userId",
          "movie_id": movieId.toString(),
        },
      );
    } catch (e) {
      print("Gagal hapus di server: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F1A),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("MoviZone Watchlist",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xff1E1E2C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchWatchlist,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : favoriteMovies.isEmpty
          ? const Center(child: Text("Belum ada film favorit nih.",
          style: TextStyle(color: Colors.white54)))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: favoriteMovies.length,
        itemBuilder: (context, index) {
          final movie = favoriteMovies[index];

          // --- 1. GUNAKAN DISMISSIBLE UNTUK SWIPE ---
          return Dismissible(
            key: Key(movie.id.toString()), // Key unik wajib ada
            direction: DismissDirection.endToStart, // Swipe dari kanan ke kiri

            // Efek visual saat digeser (Background Merah)
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 25),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                  Text("Hapus", style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
            ),

            // Aksi saat swipe selesai
            onDismissed: (direction) {
              final String title = movie.title;
              _deleteFromDatabase(movie.id); // Hapus di MySQL
              setState(() {
                favoriteMovies.removeAt(index); // Hapus di UI
              });

              // Notifikasi sukses
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$title dihapus dari Watchlist"),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },

            child: Card(
              color: const Color(0xff1E1E2C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                    fit: BoxFit.cover,
                    width: 60,
                  ),
                ),
                title: Text(movie.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text("⭐ ${movie.voteAverage.toString()}",
                    style: const TextStyle(color: Colors.amber)),

                // --- 2. INDIKATOR VISUAL (Agar user tahu bisa di-swipe) ---
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios, color: Colors.white24, size: 14),
                    SizedBox(height: 4),
                    Text("Swipe", style: TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}