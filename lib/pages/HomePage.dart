import 'package:flutter/material.dart';
import 'package:movie_app/pages/MovieSwiper.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MovieService api = MovieService();
  Future<List<Movie>?>? _trendingMoviesFuture;
  Future<List<Movie>?>? _popularMovies;
  Future<List<Movie>?>? _topMovies;
  Future<List<Movie>?>? _upcomingMovies;

  @override
  void initState() {
    super.initState();
    _trendingMoviesFuture = api.getTrendingMovies();
    _popularMovies = api.getPopularMovies();
    _topMovies = api.getTopRatedMovies();
    _upcomingMovies = api.getUpcomingMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://avatars.githubusercontent.com/u/110792644?v=4'),
                      ),
                      SizedBox(width: 16,),
                      Column(
                        children: [
                          const Text('Hello 👋,', style: TextStyle(color: Colors.white, fontSize: 14),),
                          const Text('Sharlen', style: TextStyle(color: Colors.white, fontSize: 18),),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 24,),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu, color: Colors.white, size: 24,),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20,),
              MovieSwiper(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                  Text('See all', style: TextStyle(color: Colors.white, fontSize: 14),),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.lightBlueAccent
                      ),
                      child: const Center(
                        child: Text(
                          "All",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    _categoryItem("Action"),
                    _categoryItem("Comedy"),
                    _categoryItem("Drama"),
                    _categoryItem("Romance"),
                  ],
                ),
              ),
              // trending movies, categories, etc. can be added here
              SizedBox(height: 20,),
              Text('Trending Movies', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              FutureBuilder<List<Movie>?>(
                future: _trendingMoviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final movies = snapshot.data;
                  if (movies == null || movies.isEmpty) {
                    return const Center(
                      child: Text(
                        'No movies found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return _buildMovieCard(movie);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 20,),
              Text('Popular Movies', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              FutureBuilder<List<Movie>?>(
                future: _popularMovies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final movies = snapshot.data;
                  if (movies == null || movies.isEmpty) {
                    return const Center(
                      child: Text(
                        'No movies found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return _buildMovieCard(movie);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 20,),
              Text('Top Rated Movies', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              FutureBuilder<List<Movie>?>(
                future: _topMovies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final movies = snapshot.data;
                  if (movies == null || movies.isEmpty) {
                    return const Center(
                      child: Text(
                        'No movies found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return _buildMovieCard(movie);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 20,),
              Text('Upcoming Movies', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              FutureBuilder<List<Movie>?>(
                future: _upcomingMovies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final movies = snapshot.data;
                  if (movies == null || movies.isEmpty) {
                    return const Center(
                      child: Text(
                        'No movies found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return _buildMovieCard(movie);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _categoryItem(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: const Color(0xff1E1E2C),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget _buildMovieCard(Movie movie) {
  return Container(
    width: 150,
    margin: const EdgeInsets.only(right: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            height: 180,
            width: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                width: 150,
                color: Colors.grey[900],
                child: const Icon(Icons.broken_image, color: Colors.white54),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    ),
  );
}
