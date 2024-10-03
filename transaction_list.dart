import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  final List transactions;

  const TransactionList({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Espaçamento entre os cards e bordas
          elevation: 5, // Sombra do card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Borda arredondada
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Espaçamento interno
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaço entre os itens
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinhamento à esquerda
                    children: [
                      Text(
                        transaction['description'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        transaction['date'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Alinhamento à direita
                  children: [
                    Text(
                      transaction['amount'].toStringAsFixed(2), // Formatar para duas casas decimais
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: transaction['type'] == 'receita' ? Colors.green : Colors.red, // Cores baseadas no tipo
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction['type'] == 'receita' ? 'Receita' : 'Despesa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}