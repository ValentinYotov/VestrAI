import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
      appBar: AppBar(
        title: Text('VestrAI'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo.jpg', // Указваме правилния файл
              height: 40, // Регулиране на височината на логото
              fit: BoxFit.contain, // Осигурява правилно мащабиране
              errorBuilder: (context, error, stackTrace) {
                // Този callback ще се изпълни, ако логото не се зареди
                print('Грешка при зареждане на логото: $error');
                return Icon(Icons.error); // Показва икона за грешка, ако логото не се зареди
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добре дошъл в VestrAI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Твоят личен инвестиционен помощник',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Text(
              'Текуща цена на Биткойн: $_bitcoinPrice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchBitcoinPrice,
              child: Text('Обнови цената'),
            ),
            SizedBox(height: 20),
            Text('Колко искаш да инвестираш? (лв)'),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _budget = double.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Въведи сума',
              ),
            ),
            SizedBox(height: 20),
            Text('Ниво на риск:'),
            Slider(
              value: _riskLevel,
              min: 1,
              max: 3,
              divisions: 2,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateSuggestion,
              child: Text('Покажи ми предложения'),
            ),
            SizedBox(height: 10),
            Text(
              _investmentSuggestion,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            Text(
              'Пример: Купи 10 акции на фирма X за 100 лв',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}