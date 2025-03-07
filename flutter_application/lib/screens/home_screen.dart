import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart'; // Добавяне за анимации

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 0;
  double _riskLevel = 1;
  String _bitcoinPrice = 'Натисни за обновяване или изчакай...';
  String _investmentSuggestion = 'Въведи данни за предложение';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchBitcoinPrice();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchBitcoinPrice();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchBitcoinPrice() async {
    try {
      setState(() {
        _bitcoinPrice = 'Зареждане...';
      });
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd'),
      );
      print('Статус код: ${response.statusCode}');
      print('Отговор от API: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final price = data['bitcoin']['usd'].toString();
        setState(() {
          _bitcoinPrice = '\$$price';
        });
        print('Нова цена: $_bitcoinPrice');
      } else {
        setState(() {
          _bitcoinPrice = 'Грешка при зареждане: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _bitcoinPrice = 'Грешка: $e';
      });
      print('Изключение: $e');
    }
  }

  void _generateSuggestion() {
    if (_budget > 0 && _bitcoinPrice.startsWith('\$')) {
      double price = double.parse(_bitcoinPrice.replaceAll('\$', ''));
      double btcAmount = _budget / price;
      String riskText = _riskLevel == 1 ? 'нисък' : _riskLevel == 2 ? 'среден' : 'висок';
      setState(() {
        _investmentSuggestion = 'Препоръка: Купи $btcAmount BTC за $_budget лв при $riskText риск';
      });
    } else {
      setState(() {
        _investmentSuggestion = 'Въведи валиден бюджет и обнови цената!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2526), // Черен фон
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3A44), // Тъмносив AppBar
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
            // Заглавие с анимация
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
            // Карта за цената
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
                      'Текуща цена на Биткойн:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bitcoinPrice,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF0B90B), // Жълт акцент
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0B90B), // Жълт бутон
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _fetchBitcoinPrice,
                      child: const Text('Обнови цената'),
                    ),
                  ],
                ),
              ),
            ),
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
              'Пример: Купи 10 акции на фирма X за 100 лв',
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
