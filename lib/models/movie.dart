class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String mediaType;
  final String originalLanguage;
  final String releaseDate;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final bool adult;
  final bool video;
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.mediaType,
    required this.originalLanguage,
    required this.releaseDate,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.adult,
    required this.video,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      mediaType: json['media_type'] ?? '',
      originalLanguage: json['original_language'] ?? '',
      releaseDate: json['release_date'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      adult: json['adult'] ?? false,
      video: json['video'] ?? false,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }
}

class MovieResponse {
  final int page;
  final List<Movie> results;

  MovieResponse({
    required this.page,
    required this.results,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      page: json['page'] ?? 1,
      results: (json['results'] as List? ?? [])
          .map((item) => Movie.fromJson(item))
          .toList(),
    );
  }
}