import 'package:expense_planner/models/transaction.dart';
import 'package:expense_planner/widgets/transaction_item.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transaction;
  final Function deleteTx;

  const TransactionList(
      {required this.transaction, required this.deleteTx, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return transaction.isEmpty
        ? LayoutBuilder(builder: (ctx, constrains) {
            return Column(
              children: [
                const Text('No transactions added yet'),
                SizedBox(
                  height: constrains.maxHeight * 0.09,
                ),
                SizedBox(
                  height: constrains.maxHeight * 0.6,
                  child: Image.asset('assets/images/waiting.png'),
                ),
              ],
            );
          })
        : ListView(
            children: transaction
                .map(
                  (tx) => TransactionItem(
                    key: ValueKey(tx.id),
                    transaction: tx,
                    deleteTx: deleteTx,
                  ),
                )
                .toList(),
          );
  }
}
