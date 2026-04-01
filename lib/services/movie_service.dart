import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app/models/movie.dart';

import '../models/cast.dart';
import '../models/genre.dart';

class MovieService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '9c767287f2aabaed60bacc5777428501';

  Future<List<Movie>?> getTrendingMovies() async {
    List<Movie>? movies;
    var url = Uri.parse("$_baseUrl/trending/movie/day?api_key=$_apiKey");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'] as List;
      movies = results.map<Movie>((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      return null;
    }
  }

  Future<Movie?> getMovieById(int movieId) async {
    var url = Uri.parse("$_baseUrl/movie/$movieId?api_key=$_apiKey");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return Movie.fromJson(data);
    } else {
      return null;
    }
  }

  static Future<List<Movie>?> searchMovies(String query) async {
    List<Movie>? movies;
    var url = Uri.parse("$_baseUrl/search/movie?api_key=$_apiKey&query=$query");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'] as List;
      movies = results.map<Movie>((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      return null;
    }
  }

  static Future<List<Movie>?> getNowPlayingMovies() async {
    List<Movie>? movies;
    var url = Uri.parse("$_baseUrl/movie/now_playing?api_key=$_apiKey");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'] as List;
      movies = results.map<Movie>((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      return null;
    }
  }

  Future<List<Movie>?> getPopularMovies() async {
    List<Movie>? movies;
    var url = Uri.parse("$_baseUrl/movie/popular?api_key=$_apiKey");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'] as List;
      movies = results.map<Movie>((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      return null;
    }
  }

  Future<List<Movie>?> getTopRatedMovies() async {
    List<Movie>? movies;
    var url = Uri.parse("$_baseUrl/movie/top_rated?api_key=$_apiKey");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'] as List;
      movies = results.map<Movie>((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      return null;
    }
  }

  Future<List<Movie>?> getUpcomingMovies() async {
    List<Movie>? movies;
    var url = Uri.parse("$_baseUrl/movie/upcoming?api_key=$_apiKey");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'] as List;
      movies = results.map<Movie>((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      return null;
    }
  }

  static Future<List<Movie>?> getMoviesByGenre(int genreId) async {
    List<Movie>? movies;
    var url = Uri.parse("$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'] as List;
      movies = results.map<Movie>((json) => Movie.fromJson(json)).toList();
      return movies;
    } else {
      return null;
    }
  }
  Future<List<Genre>?> getGenres() async {
    List<Genre>? genres;
    var url = Uri.parse("$_baseUrl/genre/movie/list?api_key=$_apiKey");

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['genres'] as List;
      genres = results.map<Genre>((json) => Genre.fromJson(json)).toList();
      return genres;
    } else {
      return null;
    }
  }

  Future<String?> getMovieTrailer(int movieId) async {
    var url = Uri.parse("$_baseUrl/movie/$movieId/videos?api_key=$_apiKey");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var results = data['results'] as List;

      for (var video in results) {
        if (video['type'] == 'Trailer' && video['site'] == 'YouTube') {
          return video['key'];
        }
      }
    }

    return null;
  }

  Future<List<Cast>?> getMovieCast(int movieId) async {
    try {
      final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$_apiKey');
      final response = await http.get(url);

      print('--- CAST API RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('cast')) {
          print('Jumlah cast: ${data['cast'].length}');

          List<Cast> castList = (data['cast'] as List)
              .map((json) => Cast.fromJson(json))
              .take(10)
              .toList();

          print('Cast pertama: ${castList.isNotEmpty ? castList[0].name : 'Tidak ada cast'}');
          return castList;
        } else {
          print('Key "cast" tidak ditemukan dalam response');
          return [];
        }
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception di getMovieCast: $e');
      return [];
    }
  }
}