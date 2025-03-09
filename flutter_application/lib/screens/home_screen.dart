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
  bool _isLongTerm = false; // Ново: Инвестиционен хоризонт (true = дългосрочен, false = краткосрочен)
  String _investmentSuggestion = 'Въведи данни за предложение';
  Map<String, double> _assetPrices = {}; // Съхранява цените на активите
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchAssetPrices();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchAssetPrices();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchAssetPrices() async {
    try {
      setState(() {
        _assetPrices = {};
      });
      final response = await http.get(
        Uri.parse(
            'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,binancecoin,cardano&vs_currencies=usd'),
      );
      print('Статус код: ${response.statusCode}');
      print('Отговор от API: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _assetPrices = {
            'Bitcoin': data['bitcoin']['usd'].toDouble(),
            'Ethereum': data['ethereum']['usd'].toDouble(),
            'Binance Coin': data['binancecoin']['usd'].toDouble(),
            'Cardano': data['cardano']['usd'].toDouble(),
          };
        });
        print('Цени на активите: $_assetPrices');
      } else {
        setState(() {
          _investmentSuggestion = 'Грешка при зареждане на данни: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _investmentSuggestion = 'Грешка: $e';
      });
      print('Изключение: $e');
    }
  }

  void _generateSuggestion() {
    if (_budget <= 0) {
      setState(() {
        _investmentSuggestion = 'Моля, въведи валиден бюджет!';
      });
      return;
    }

    if (_assetPrices.isEmpty) {
      setState(() {
        _investmentSuggestion = 'Моля, изчакай зареждането на данни!';
      });
      return;
    }

    // Прост алгоритъм за избор на актив
    String selectedAsset = 'Bitcoin';
    double volatilityScore = 0; // Колкото по-висок, толкова по-волатилен

    if (_riskLevel == 1) {
      // Нисък риск: Предпочитаме по-стабилни активи
      if (_isLongTerm) {
        selectedAsset = 'Binance Coin'; // Пример: BNB за дългосрочен нисък риск
        volatilityScore = 0.2;
      } else {
        selectedAsset = 'Cardano'; // Пример: Cardano за краткосрочен нисък риск
        volatilityScore = 0.3;
      }
    } else if (_riskLevel == 2) {
      // Среден риск
      if (_isLongTerm) {
        selectedAsset = 'Ethereum'; // Пример: Ethereum за дългосрочен среден риск
        volatilityScore = 0.5;
      } else {
        selectedAsset = 'Binance Coin'; // Пример: BNB за краткосрочен среден риск
        volatilityScore = 0.4;
      }
    } else {
      // Висок риск: Предпочитаме волатилни активи
      if (_isLongTerm) {
        selectedAsset = 'Bitcoin'; // Пример: Bitcoin за дългосрочен висок риск
        volatilityScore = 0.7;
      } else {
        selectedAsset = 'Ethereum'; // Пример: Ethereum за краткосрочен висок риск
        volatilityScore = 0.6;
      }
    }

    // Изчисляваме количеството на актива
    double assetPrice = _assetPrices[selectedAsset]!;
    double amount = _budget / assetPrice;

    String riskText = _riskLevel == 1 ? 'нисък' : _riskLevel == 2 ? 'среден' : 'висок';
    String horizonText = _isLongTerm ? 'дългосрочен' : 'краткосрочен';

    setState(() {
      _investmentSuggestion =
          'Препоръчваме да инвестираш в $selectedAsset: $amount единици за $_budget лв при $riskText риск за $horizonText хоризонт';
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
            // Бюджет
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
            // Ниво на риск
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
            // Инвестиционен хоризонт
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
            // Бутон за предложения
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
            // Показване на предложението
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
        ),
      ),
    );
  }
}