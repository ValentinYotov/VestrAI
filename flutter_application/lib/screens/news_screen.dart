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
  String _filterKeyword = '';

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
            'https://newsapi.org/v2/everything?q=cryptocurrency&apiKey=YOUR_API_KEY_HERE&language=en&pageSize=10'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _articles = data['articles'];
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

  List<dynamic> _getFilteredArticles() {
    if (_filterKeyword.isEmpty) return _articles;
    return _articles.where((article) {
      final title = article['title']?.toString().toLowerCase() ?? '';
      final description = article['description']?.toString().toLowerCase() ?? '';
      return title.contains(_filterKeyword.toLowerCase()) ||
          description.contains(_filterKeyword.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _getFilteredArticles();

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF2F3A44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _filterKeyword = value;
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1C2526),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Филтрирай по ключова дума (напр. btc)',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _fetchNews,
                      child: const Text('Опресни'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF0B90B),
                ),
              ),
            if (!_isLoading && filteredArticles.isEmpty)
              const Center(
                child: Text(
                  'Няма филтрирани новини. Опитай отново!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (!_isLoading && filteredArticles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    final title = article['title'] ?? 'Без заглавие';
                    final description = article['description'] ?? 'Няма описание';
                    final url = article['url'] ?? '';
                    final imageUrl = article['urlToImage'] ?? '';

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
                        subtitle: Text(
                          description,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }
}