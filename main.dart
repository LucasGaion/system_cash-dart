import 'package:flutter/material.dart';
import 'login.dart'; // Importando a tela de login
import 'add_transaction.dart'; // Importando a tela de adicionar transação
import 'transaction_list.dart'; // Importando a lista de transações
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<FlSpot> _incomeSpots = [];
  List<FlSpot> _expenseSpots = [];

  Future<void> _fetchTransactions() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/transactions'));
    if (response.statusCode == 200) {
      setState(() {
        _transactions = json.decode(response.body);
        _calculateTotals();
        _prepareChartData();
      });
    } else {
      print('Erro ao carregar transações: ${response.statusCode}');
    }
  }

  void _calculateTotals() {
    _totalIncome = 0.0;
    _totalExpense = 0.0;

    for (var transaction in _transactions) {
      if (transaction['type'] == 'receita') {
        _totalIncome += transaction['amount'];
      } else if (transaction['type'] == 'despesa') {
        _totalExpense += transaction['amount'];
      }
    }
  }

  void _prepareChartData() {
    _incomeSpots = [];
    _expenseSpots = [];
    Map<int, double> incomeDayTotal = {};
    Map<int, double> expenseDayTotal = {};

    for (var transaction in _transactions) {
      DateTime date = DateTime.parse(transaction['date']);
      int dayOfMonth = date.day;

      if (transaction['type'] == 'receita') {
        incomeDayTotal[dayOfMonth] = (incomeDayTotal[dayOfMonth] ?? 0) + transaction['amount'];
      } else if (transaction['type'] == 'despesa') {
        expenseDayTotal[dayOfMonth] = (expenseDayTotal[dayOfMonth] ?? 0) + transaction['amount'];
      }
    }

    for (int i = 1; i <= 31; i++) {
      _incomeSpots.add(FlSpot(i.toDouble(), incomeDayTotal[i] ?? 0));
      _expenseSpots.add(FlSpot(i.toDouble(), expenseDayTotal[i] ?? 0));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal, // Alterado para verde
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monetization_on, color: Colors.white), // Ícone branco
            SizedBox(width: 8),
            Text(
              'Controle Financeiro',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // Texto branco
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _transactions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não há transações cadastradas.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Clique no botão "+" para cadastrar sua renda e gastos.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Receita',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$${_totalIncome.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 24, color: Colors.green),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Despesa',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$${_totalExpense.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 24, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString());
                              },
                              interval: 1, // Ajuste o intervalo conforme necessário
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        minX: 1,
                        maxX: 31,
                        minY: 0,
                        maxY: [_totalIncome, _totalExpense].reduce((a, b) => a > b ? a : b) + 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _incomeSpots,
                            isCurved: true,
                            color: Colors.green,
                            belowBarData: BarAreaData(show: false),
                          ),
                          LineChartBarData(
                            spots: _expenseSpots,
                            isCurved: true,
                            color: Colors.red,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TransactionList(transactions: _transactions),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          ).then((_) => _fetchTransactions());
        },
        child: Icon(Icons.add, color: Colors.white), // Ícone "+" em branco
        backgroundColor: Colors.teal, // Fundo do botão em teal
      ),
    );
  }
}