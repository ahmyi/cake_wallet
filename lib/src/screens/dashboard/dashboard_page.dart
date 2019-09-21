import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cake_wallet/routes.dart';
import 'package:cake_wallet/src/domain/common/transaction_info.dart';
import 'package:cake_wallet/src/domain/common/transaction_direction.dart';
import 'package:cake_wallet/src/widgets/primary_button.dart';
import 'package:cake_wallet/src/domain/common/sync_status.dart';
import 'package:cake_wallet/src/domain/services/wallet_service.dart';
import 'package:cake_wallet/src/stores/balance/balance_store.dart';
import 'package:cake_wallet/src/stores/sync/sync_store.dart';
import 'package:cake_wallet/src/stores/transaction_list/transaction_list_store.dart';
import 'package:cake_wallet/src/screens/base_page.dart';
import 'package:cake_wallet/src/screens/dashboard/date_section_item.dart';

class DashboardPage extends BasePage {
  static final transactionDateFormat = DateFormat("dd.MM.yyyy, HH:mm");
  static final dateSectionDateFormat = DateFormat("d MMM");
  static final nowDate = DateTime.now();
  final WalletService walletService;

  String get title => 'Wallet';

  DashboardPage({@required this.walletService});

  static List<Object> formatTransactionsList(
      List<TransactionInfo> transactions) {
    var formattedList = List<Object>();
    DateTime lastDate;
    transactions.sort((a, b) => b.date.compareTo(a.date));

    for (int i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final txDateUtc = transaction.date.toUtc();
      final txDate = DateTime(txDateUtc.year, txDateUtc.month, txDateUtc.day);

      if (lastDate == null) {
        lastDate = txDate;
        formattedList.add(DateSectionItem(transaction.date));
        formattedList.add(transaction);
        continue;
      }

      if (lastDate.compareTo(txDate) == 0) {
        formattedList.add(transaction);
        continue;
      }

      lastDate = txDate;
      formattedList.add(DateSectionItem(transaction.date));
      formattedList.add(transaction);
    }

    return formattedList;
  }

  void presentWalletMenu(BuildContext bodyContext) {
    showDialog(
        context: bodyContext,
        builder: (context) {
          return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: const Text('Reconnect'), onPressed: () => null),
                CupertinoActionSheetAction(
                    child: const Text('Accounts'), onPressed: () => null),
                CupertinoActionSheetAction(
                    child: const Text('Wallets'),
                    onPressed: () => Navigator.of(context)
                        .popAndPushNamed(Routes.walletList)),
                CupertinoActionSheetAction(
                    child: const Text('Show seed'),
                    onPressed: () {
                      Navigator.of(bodyContext)
                          .popAndPushNamed(Routes.auth, arguments: [
                        (auth) {
                          Navigator.of(bodyContext)
                              .popAndPushNamed(Routes.seed);
                        }
                      ]);
                    }),
                CupertinoActionSheetAction(
                    child: const Text('Show keys'), onPressed: () => null),
                CupertinoActionSheetAction(
                    child: const Text('Address book'), onPressed: () => null),
              ],
              cancelButton: CupertinoActionSheetAction(
                  child: const Text('Cancel'),
                  isDefaultAction: true,
                  onPressed: () => Navigator.of(context).pop()),
            )
          ]);
        });
  }

  @override
  Widget leading(BuildContext context) => SizedBox(
      width: 30,
      child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () => presentWalletMenu(context),
          child: Image.asset('assets/images/more.png',
              color: Colors.black, width: 30)));

  @override
  Widget body(BuildContext context) {
    final balanceStore = Provider.of<BalanceStore>(context);
    final transactionListStore = Provider.of<TransactionListStore>(context);
    final syncStore = Provider.of<SyncStore>(context);

    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
      return <Widget>[
        SliverAppBar(
          expandedHeight: 363.0,
          floating: false,
          pinned: true,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: EdgeInsets.only(bottom: 20),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(132, 141, 198, 0.05),
                    blurRadius: 10,
                    offset: Offset(
                      0,
                      12,
                    ),
                  )
                ]),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 54),
                        child: Column(
                          children: <Widget>[
                            Text('XMR Full Balance',
                                style: TextStyle(
                                    color: Color.fromRGBO(138, 80, 255, 1),
                                    fontSize: 16)),
                            Observer(
                                builder: (_) => Text(balanceStore.fullBalance,
                                    style: TextStyle(
                                        color: Colors.black87, fontSize: 42))),
                            Padding(
                              padding: EdgeInsets.only(top: 7),
                              child: Observer(builder: (_) {
                                return Text(
                                    '${balanceStore.fiatFullBalance} USD',
                                    style: TextStyle(
                                        color: Color.fromRGBO(155, 172, 197, 1),
                                        fontSize: 16));
                              }),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 45),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(226, 235, 238, 0.4),
                                  borderRadius: BorderRadius.circular(5)),
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: SizedBox(
                                  width: 125,
                                  child: Observer(builder: (_) {
                                    if (syncStore.status is SyncingSyncStatus) {
                                      return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Image.asset(
                                              'assets/images/refresh_icon.png',
                                              width: 10,
                                              height: 10,
                                            ),
                                            Text(
                                                'BLOCKS REMAINING ${syncStore.status.toString()}',
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Color.fromRGBO(
                                                        155, 172, 197, 1)))
                                          ]);
                                    }

                                    var text = '';

                                    if (syncStore.status is SyncedSyncStatus) {
                                      text = 'SYNCRONIZED';
                                    }

                                    if (syncStore.status
                                        is NotConnectedSyncStatus) {
                                      text = 'NOT CONNECTED';
                                    }

                                    if (syncStore.status is FailedSyncStatus) {
                                      text = 'FAILED CONNECT TO THE NODE';
                                    }

                                    if (syncStore.status
                                        is StartingSyncStatus) {
                                      text = 'STARTINT SYNC';
                                    }

                                    return Center(
                                      child: Text(text,
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Color.fromRGBO(
                                                  155, 172, 197, 1))),
                                    );
                                  })),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30, right: 30, top: 40),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: PrimaryButton(
                                    text: 'Send',
                                    onPressed: () => Navigator.of(context,
                                            rootNavigator: true)
                                        .pushNamed(Routes.send),
                                    color: Color.fromRGBO(227, 212, 255, 0.7),
                                    borderColor:
                                        Color.fromRGBO(209, 194, 243, 1),
                                  )),
                                  SizedBox(width: 10),
                                  Expanded(
                                      child: PrimaryButton(
                                    text: 'Receive',
                                    onPressed: () => Navigator.of(context,
                                            rootNavigator: true)
                                        .pushNamed(Routes.receive),
                                    color: Color.fromRGBO(151, 226, 255, 0.5),
                                    borderColor:
                                        Color.fromRGBO(121, 201, 233, 0.9),
                                  ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ];
    }, body: Observer(builder: (_) {
      var items = formatTransactionsList(transactionListStore.transactions);

      return ListView.builder(
          padding: EdgeInsets.only(left: 25, top: 10, right: 25, bottom: 15),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            if (item is DateSectionItem) {
              final diffDays = item.date.difference(nowDate).inDays;

              // final txDateUtc = item.date.toUtc();
              // final txDate = DateTime(txDateUtc.year, txDateUtc.month, txDateUtc.day);

              var title = "";

              // var r = nowDate.compareTo(txDate);

              // print('Test $r');

              if (diffDays == 0) {
                title = "Today";
              } else if (diffDays == -1) {
                title = "Yesterday";
              } else if (diffDays > -7 && diffDays < 0) {
                final dateFormat = DateFormat("EEEE");
                title = dateFormat.format(item.date);
              } else {
                title = dateSectionDateFormat.format(item.date);
              }

              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Center(
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(155, 172, 197, 1)))),
              );
            }

            if (item is TransactionInfo) {
              return InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(Routes.transactionDetails, arguments: item);
                },
                child: Container(
                  padding: EdgeInsets.only(top: 14, bottom: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromRGBO(218, 228, 243, 0.4),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: Row(children: <Widget>[
                    Image.asset(item.direction == TransactionDirection.incoming
                        ? 'assets/images/transaction_incoming.png'
                        : 'assets/images/transaction_outgoing.png'),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    item.direction ==
                                            TransactionDirection.incoming
                                        ? 'Received'
                                        : 'Sent',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                Text(item.amount(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromRGBO(84, 92, 139, 1)))
                              ]),
                          SizedBox(height: 6),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(transactionDateFormat.format(item.date),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color:
                                            Color.fromRGBO(103, 107, 141, 1))),
                                Text(item.fiatAmount(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            Color.fromRGBO(103, 107, 141, 1)))
                              ]),
                        ],
                      ),
                    ))
                  ]),
                ),
              );
            }

            return Container();
          });
    }));
  }
}
