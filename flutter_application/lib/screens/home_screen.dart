import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 0;
  double _riskLevel = 1;
  bool _isLongTerm = false;
  String _investmentSuggestion = 'Въведи данни за предложение';
  Map<String, Map<String, dynamic>> _assetData = {};
  bool _isLoading = false;
  late Timer _timer;
  final double _exchangeRate = 1.80; // 1 USD = 1.80 BGN

  @override
  void initState() {
    super.initState();
    _fetchAssetData();
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      _fetchAssetData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchAssetData() async {
    try {
      setState(() {
        _isLoading = true;
        _assetData = {};
      });
      final response = await http.get(
        Uri.parse(
            'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin,ethereum,binancecoin,cardano&order=market_cap_desc&per_page=4&page=1&sparkline=false&price_change_percentage=24h,7d'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _assetData = {
            for (var item in data)
              item['name']: {
                'price': (item['current_price'] as num?)?.toDouble() ?? 0.0,
                'priceChange24h': (item['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
                'priceChange7d': (item['price_change_percentage_7d'] as num?)?.toDouble() ?? 0.0,
                'marketCap': (item['market_cap'] as num?)?.toDouble() ?? 0.0,
              }
          };
        });
      } else {
        setState(() {
          _investmentSuggestion = 'Грешка при зареждане на данни: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _investmentSuggestion = 'Грешка: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateSuggestion() {
    if (_budget <= 0) {
      setState(() {
        _investmentSuggestion = 'Моля, въведи валиден бюджет!';
      });
      return;
    }

    if (_assetData.isEmpty) {
      setState(() {
        _investmentSuggestion = 'Моля, изчакай зареждането на данни!';
      });
      return;
    }

    double budgetInUsd = _budget / _exchangeRate;

    List<Map<String, dynamic>> scoredAssets = _assetData.entries.map((entry) {
      String assetName = entry.key;
      double price = entry.value['price'];
      double priceChange24h = entry.value['priceChange24h'];
      double priceChange7d = entry.value['priceChange7d'];
      double marketCap = entry.value['marketCap'];

      // Тенденция: Средна оценка от последните 24 часа и 7 дни
      double trendScore = ((priceChange24h + priceChange7d) / 2) / 100; // Нормализираме (0-1)
      // Стабилност: По-висока пазарна капитализация = по-нисък риск
      double stabilityScore = (marketCap / 1000000000000).clamp(0.0, 1.0); // Нормализиране
      // Рисков фактор
      double riskFactor = _riskLevel == 1 ? 0.3 : _riskLevel == 2 ? 0.6 : 1.0;
      // Хоризонтен фактор
      double horizonFactor = _isLongTerm ? 0.7 : 0.3;
      // Обща оценка: 50% тенденция, 30% стабилност, 20% риск/хоризонт
      double score = (0.5 * trendScore) + (0.3 * (1 - stabilityScore)) + (0.2 * (riskFactor + horizonFactor));

      return {
        'name': assetName,
        'score': score,
        'price': price,
        'trend24h': priceChange24h,
        'trend7d': priceChange7d,
      };
    }).toList();

    scoredAssets.sort((a, b) => b['score'].compareTo(a['score']));
    var bestAsset = scoredAssets.first;

    double amount = budgetInUsd / bestAsset['price'];
    String formattedAmount = amount.toStringAsFixed(4);

    String riskText = _riskLevel == 1 ? 'нисък' : _riskLevel == 2 ? 'среден' : 'висок';
    String horizonText = _isLongTerm ? 'дългосрочен' : 'краткосрочен';

    setState(() {
      _investmentSuggestion =
          'Препоръчваме ${bestAsset['name']} (${bestAsset['trend24h'].toStringAsFixed(2)}% за 24ч, ${bestAsset['trend7d'].toStringAsFixed(2)}% за 7д): $formattedAmount единици за $_budget лв (≈${budgetInUsd.toStringAsFixed(2)} USD) при $riskText риск за $horizonText хоризонт. Причина: Позитивна тенденция и балансиран риск.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2526),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3A44),
        title: const Text(
          'VestrAI',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAssetData,
            tooltip: 'Опресни данни',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo.jpg',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('Грешка при зареждане на логото: $error');
                return const Icon(Icons.error, color: Colors.white);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добре дошъл в VestrAI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 8),
            const Text(
              'Твоят личен инвестиционен помощник',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF0B90B),
                ),
              ),
            if (!_isLoading) ...[
              Card(
                color: const Color(0xFF2F3A44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Колко искаш да инвестираш? (лв)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _budget = double.tryParse(value) ?? 0;
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
                          hintText: 'Въведи сума',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: const Color(0xFF2F3A44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ниво на риск:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: _riskLevel,
                        min: 1,
                        max: 3,
                        divisions: 2,
                        activeColor: _riskLevel == 1
                            ? Colors.green
                            : _riskLevel == 2
                                ? Colors.orange
                                : const Color(0xFFF0B90B),
                        inactiveColor: Colors.grey,
                        label: _riskLevel == 1
                            ? 'Нисък'
                            : _riskLevel == 2
                                ? 'Среден'
                                : 'Висок',
                        onChanged: (value) {
                          setState(() {
                            _riskLevel = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: const Color(0xFF2F3A44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Инвестиционен хоризонт:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ChoiceChip(
                            label: const Text('Краткосрочен'),
                            selected: !_isLongTerm,
                            onSelected: (selected) {
                              setState(() {
                                _isLongTerm = false;
                              });
                            },
                            selectedColor: const Color(0xFFF0B90B),
                            backgroundColor: const Color(0xFF1C2526),
                            labelStyle: TextStyle(
                              color: !_isLongTerm ? Colors.black : Colors.white,
                            ),
                          ),
                          ChoiceChip(
                            label: const Text('Дългосрочен'),
                            selected: _isLongTerm,
                            onSelected: (selected) {
                              setState(() {
                                _isLongTerm = true;
                              });
                            },
                            selectedColor: const Color(0xFFF0B90B),
                            backgroundColor: const Color(0xFF1C2526),
                            labelStyle: TextStyle(
                              color: _isLongTerm ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0B90B),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _generateSuggestion,
                child: const Text(
                  'Покажи ми предложения',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              if (_investmentSuggestion != 'Въведи данни за предложение')
                Card(
                  color: const Color(0xFF2F3A44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _investmentSuggestion,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Пример: Препоръчваме да инвестираш в Bitcoin: 0.01 единици за 1000 лв',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}