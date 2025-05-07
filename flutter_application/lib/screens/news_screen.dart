import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _articles = [];
  bool _isLoading = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _timer = Timer.periodic(Duration(minutes: 15), (timer) {
      _fetchNews();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(
        Uri.parse(
            'https://newsapi.org/v2/everything?q=cryptocurrency&apiKey=c1c38275e0ed46cc8fc2cbb78ddbcc17&language=en&pageSize=10&sortBy=publishedAt'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _articles = (data['articles'] as List)
              .where((article) => article['publishedAt'] != null)
              .toList()
            ..sort((a, b) {
              DateTime dateA = DateTime.parse(a['publishedAt']);
              DateTime dateB = DateTime.parse(b['publishedAt']);
              return dateB.compareTo(dateA); // Сортиране в намаляващ ред (най-новите първо)
            });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Грешка при зареждане на новини: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не можах да отворя връзката')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2526),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3A44),
        title: const Text(
          'Крипто Новини',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF0B90B),
                ),
              )
            : _articles.isEmpty
                ? const Center(
                    child: Text(
                      'Няма новини. Опитай отново по-късно!',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _articles.length,
                    itemBuilder: (context, index) {
                      final article = _articles[index];
                      final title = article['title'] ?? 'Без заглавие';
                      final description = article['description'] ?? 'Няма описание';
                      final url = article['url'] ?? '';
                      final imageUrl = article['urlToImage'] ?? '';
                      final publishedAt = article['publishedAt'] != null
                          ? DateTime.parse(article['publishedAt']).toLocal().toString().split('.')[0]
                          : 'Без дата';

                      return Card(
                        color: const Color(0xFF2F3A44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error, color: Colors.white),
                                )
                              : const Icon(Icons.image_not_supported, color: Colors.grey),
                          title: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Публикувана: $publishedAt',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new, color: Color(0xFFF0B90B)),
                            onPressed: () => _launchURL(url),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideX();
                    },
                  ),
      ),
    );
  }
}