import 'package:flutter/cupertino.dart';

import './models/transaction.dart';
import './widgets/chart.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        errorColor: Colors.red.shade400,
        fontFamily: 'Quicksand',
        appBarTheme: const AppBarTheme(
          toolbarTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransaction = [];
  bool _showChart = false;

  List<Transaction> get _recentTransaction {
    return _userTransaction.where((element) {
      return element.date.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      ));
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
    );

    setState(() {
      _userTransaction.add(newTx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransaction.removeWhere((element) => element.id == id);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: ctx,
        isScrollControlled: true,
        builder: (_) {
          return SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: GestureDetector(
              onTap: () {},
              child: NewTransaction(txAdd: _addNewTransaction),
              behavior: HitTestBehavior.opaque,
            ),
          ));
        });

    // showModalBottomSheet(
    //   backgroundColor: Colors.transparent,
    //   context: ctx,
    //   builder: (_) {
    //     return GestureDetector(
    //       onTap: () {},
    //       child: NewTransaction(txAdd: _addNewTransaction),
    //       behavior: HitTestBehavior.opaque,
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    final myMediaQuery = MediaQuery.of(context);

    final isLandScape = myMediaQuery.orientation == Orientation.landscape;

    final dynamic appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text('Personal Expenses'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: const Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: const Text('Personal Expenses'),
            actions: [
              IconButton(
                onPressed: () {
                  _startAddNewTransaction(context);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          );

    final txListWidget = SizedBox(
      height: (myMediaQuery.size.height -
              appBar.preferredSize.height -
              myMediaQuery.padding.top) *
          0.7,
      child: TransactionList(
          transaction: _userTransaction, deleteTx: _deleteTransaction),
    );

    final pageBody = SafeArea(
        child: SingleChildScrollView(
      child: Column(
        children: [
          if (isLandScape)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Show Chart',
                ),
                Switch.adaptive(
                    value: _showChart,
                    onChanged: (val) {
                      setState(() {
                        _showChart = val;
                      });
                    }),
              ],
            ),
          if (!isLandScape)
            SizedBox(
              height: (myMediaQuery.size.height -
                      appBar.preferredSize.height -
                      myMediaQuery.padding.top) *
                  0.3,
              child: Chart(_recentTransaction),
            ),
          if (!isLandScape) txListWidget,
          if (isLandScape)
            _showChart
                ? SizedBox(
                    height: (myMediaQuery.size.height -
                            appBar.preferredSize.height -
                            myMediaQuery.padding.top) *
                        0.7,
                    child: Chart(_recentTransaction),
                  )
                : txListWidget
        ],
      ),
    ));

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            backgroundColor: const Color.fromRGBO(220, 220, 220, 1),
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isAndroid
                ? FloatingActionButton(
                    backgroundColor: Colors.amber,
                    onPressed: () {
                      _startAddNewTransaction(context);
                    },
                    child: const Icon(Icons.add),
                  )
                : Container(),
          );
  }
}
