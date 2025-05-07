import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCoin = 'bitcoin';
  String _selectedPeriod = '1';
  List<FlSpot> _chartData = [];
  bool _isLoading = false;
  final List<String> _coins = ['bitcoin', 'ethereum', 'binancecoin', 'cardano'];
  final Map<String, String> _coinNames = {
    'bitcoin': 'Bitcoin',
    'ethereum': 'Ethereum',
    'binancecoin': 'Binance Coin',
    'cardano': 'Cardano',
  };

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
  }

  Future<void> _fetchMarketData() async {
    try {
      setState(() {
        _isLoading = true;
        _chartData = [];
      });
      String days = _selectedPeriod == '1' ? '1' : '7';
      final response = await http.get(
        Uri.parse(
            'https://api.coingecko.com/api/v3/coins/$_selectedCoin/market_chart?vs_currency=usd&days=$days'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = data['prices'] as List<dynamic>;
        setState(() {
          _chartData = prices.asMap().entries.map((entry) {
            final timestamp = entry.value[0] / 1000; // Конвертиране от милисекунди в секунди
            final price = entry.value[1] as num;
            return FlSpot(timestamp.toDouble(), price.toDouble());
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Грешка при зареждане: ${response.statusCode}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2526),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3A44),
        title: const Text(
          'Следи Пазара',
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
            : Column(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Избери валута и период',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButton<String>(
                            value: _selectedCoin,
                            onChanged: (value) {
                              setState(() {
                                _selectedCoin = value!;
                                _fetchMarketData();
                              });
                            },
                            items: _coins.map((coin) {
                              return DropdownMenuItem<String>(
                                value: coin,
                                child: Text(
                                  _coinNames[coin]!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            style: const TextStyle(color: Colors.white),
                            dropdownColor: const Color(0xFF2F3A44),
                            iconEnabledColor: const Color(0xFFF0B90B),
                          ),
                          const SizedBox(height: 10),
                          DropdownButton<String>(
                            value: _selectedPeriod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPeriod = value!;
                                _fetchMarketData();
                              });
                            },
                            items: ['1', '7'].map((period) {
                              return DropdownMenuItem<String>(
                                value: period,
                                child: Text(
                                  'Последни $period дни',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            style: const TextStyle(color: Colors.white),
                            dropdownColor: const Color(0xFF2F3A44),
                            iconEnabledColor: const Color(0xFFF0B90B),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      color: const Color(0xFF2F3A44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _chartData.isEmpty
                            ? const Center(
                                child: Text(
                                  'Няма данни. Избери валута и период!',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: true),
                                  titlesData: const FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  minX: _chartData.first.x,
                                  maxX: _chartData.last.x,
                                  minY: _chartData.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) * 0.95,
                                  maxY: _chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.05,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _chartData,
                                      isCurved: true,
                                      color: const Color(0xFFF0B90B),
                                      barWidth: 2,
                                      dotData: const FlDotData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}