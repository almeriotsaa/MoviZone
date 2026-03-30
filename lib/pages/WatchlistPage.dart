import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../main.dart';

class WatchlistPage extends StatefulWidget {
  final String userId;
  const WatchlistPage({super.key, required this.userId});

  @override
  WatchlistPageState createState() => WatchlistPageState();
}

class WatchlistPageState extends State<WatchlistPage> with RouteAware {
  List<Movie> favoriteMovies = [];
  bool isLoading = true;
  final MovieService apiService = MovieService();

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  void didPopNext() {
    debugPrint("Kembali ke Watchlist, merefresh data secara otomatis...");
    fetchWatchlist();
  }

  Future<void> fetchWatchlist() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(
          Uri.parse("http://192.168.1.14/MOVIZONE_API/favorites/get_favorites.php?user_id=${widget.userId}")
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> movieIds = json.decode(response.body);

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
        }
      }
    } catch (e) {
      debugPrint("Error Detail: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteFromDatabase(int movieId) async {
    try {
      await http.post(
        Uri.parse("http://192.168.1.14/MOVIZONE_API/favorites/delete_favorite.php"),
        body: {
          "user_id": widget.userId,
          "movie_id": movieId.toString(),
        },
      );
    } catch (e) {
      debugPrint("Gagal hapus di server: $e");
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
            onPressed: fetchWatchlist,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchWatchlist,
        color: Colors.blue,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : favoriteMovies.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            const Center(
              child: Text(
                "Belum ada film favorit nih.",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: favoriteMovies.length,
          itemBuilder: (context, index) {
            final movie = favoriteMovies[index];
            return _buildMovieCard(movie, index);
          },
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, int index) {
    return Dismissible(
      key: Key(movie.id.toString()),
      direction: DismissDirection.endToStart,
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
      onDismissed: (direction) {
        final String title = movie.title;
        _deleteFromDatabase(movie.id);
        setState(() {
          favoriteMovies.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title dihapus dari Watchlist")),
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
              errorBuilder: (_, __, ___) => Container(width: 60, color: Colors.grey),
            ),
          ),
          title: Text(movie.title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text("⭐ ${movie.voteAverage.toString()}",
              style: const TextStyle(color: Colors.amber)),
          trailing: const Icon(Icons.arrow_back_ios, color: Colors.white24, size: 14),
        ),
      ),
    );
  }
}