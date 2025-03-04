import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 0;
  double _riskLevel = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VestrAI'),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Покажи предложения за $_budget лв, риск: ${_riskLevel.round()}')),
                );
              },
              child: Text('Покажи ми предложения'),
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