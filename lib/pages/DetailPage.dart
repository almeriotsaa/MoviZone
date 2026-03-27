import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';

import '../models/genre.dart';
import '../services/movie_service.dart';

class DetailPage extends StatefulWidget {
  final int movieId;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _detailMovie,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error');
          } else {
            final data = snapshot.data!;

            return Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 500,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    Image.network(
                      'https://image.tmdb.org/t/p/w500${data.posterPath}',
                      height: 500,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                            if (!genreSnapshot.hasData) {
                              return const SizedBox();
                            }

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
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    genre.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white,),
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
                      Text(data.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Release Date: ${data.releaseDate}', style: const TextStyle(fontSize: 14, color: Colors.white),),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellow, size: 16,),
                              SizedBox(width: 4,),
                              Text(data.voteAverage.toStringAsFixed(1), style: const TextStyle(fontSize: 14, color: Colors.white),),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),
                      SizedBox(height: 8,),
                      Text(data.overview, style: const TextStyle(fontSize: 16, color: Colors.white), textAlign: TextAlign.justify),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      )
    );
  }
}
