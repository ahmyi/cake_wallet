import 'package:cake_wallet/src/widgets/scollable_with_bottom_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:cake_wallet/palette.dart';
import 'package:cake_wallet/src/widgets/primary_button.dart';
import 'package:cake_wallet/src/screens/exchange_trade/widgets/copy_button.dart';
import 'package:cake_wallet/src/screens/receive/qr_image.dart';
import 'package:cake_wallet/src/screens/base_page.dart';
import 'package:cake_wallet/src/screens/exchange_trade/widgets/timer_widget.dart';
import 'package:cake_wallet/src/stores/exchange_trade/exchange_trade_store.dart';
import 'package:cake_wallet/src/stores/send/send_store.dart';
import 'package:cake_wallet/src/stores/send/sending_state.dart';
import 'package:cake_wallet/src/stores/wallet/wallet_store.dart';

class ExchangeTradePage extends BasePage {
  String get title => 'Exchange';

  @override
  Widget body(BuildContext context) => ExchangeTradeForm();
}

class ExchangeTradeForm extends StatefulWidget {
  @override
  createState() => ExchangeTradeState();
}

class ExchangeTradeState extends State<ExchangeTradeForm> {
  static const fetchingLabel = 'Fetching';
  String get title => 'Exchange';

  bool _effectsInstalled = false;

  @override
  Widget build(BuildContext context) {
    final tradeStore = Provider.of<ExchangeTradeStore>(context);
    final sendStore = Provider.of<SendStore>(context);
    final walletStore = Provider.of<WalletStore>(context);

    _setEffects(context);

    return ScrollableWithBottomSection(
      contentPadding: EdgeInsets.only(left: 20, right: 20, top: 20),
      content: Observer(builder: (_) {
        final trade = tradeStore.trade;
        final walletName = walletStore.name;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'ID: ',
                            style: TextStyle(
                                height: 2,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Theme.of(context).primaryTextTheme.button.color),
                          ),
                          Text(
                            '${trade.id ?? fetchingLabel}',
                            style: TextStyle(
                                fontSize: 14.0,
                                height: 2,
                                color: Theme.of(context).primaryTextTheme.subtitle.color),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Amount: ',
                            style: TextStyle(
                                height: 2,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Theme.of(context).primaryTextTheme.button.color),
                          ),
                          Text(
                            '${trade.amount ?? fetchingLabel}',
                            style: TextStyle(
                                fontSize: 14.0,
                                height: 2,
                                color: Theme.of(context).primaryTextTheme.subtitle.color),
                          )
                        ],
                      ),
                      trade.extraId != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Payment ID: ',
                                  style: TextStyle(
                                      height: 2,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      color: Theme.of(context).primaryTextTheme.button.color),
                                ),
                                Text(
                                  '${trade.extraId ?? fetchingLabel}',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      height: 2,
                                      color: Theme.of(context).primaryTextTheme.subtitle.color),
                                )
                              ],
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Status: ',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryTextTheme.button.color,
                                height: 2),
                          ),
                          Text(
                            '${trade.state ?? fetchingLabel}',
                            style: TextStyle(
                                fontSize: 14.0,
                                height: 2,
                                color: Theme.of(context).primaryTextTheme.subtitle.color),
                          )
                        ],
                      ),
                      trade.expiredAt != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Offer expires in: ',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Theme.of(context).primaryTextTheme.button.color),
                                ),
                                TimerWidget(trade.expiredAt,
                                    color: Theme.of(context).primaryTextTheme.subtitle.color)
                              ],
                            )
                          : Container(),
                    ],
                  ),
                  SizedBox(width: 10),
                  Container(
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 125),
                      child: QrImage(
                          data: trade.inputAddress ?? fetchingLabel,
                          backgroundColor: Colors.white))
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: Text(
                'This trade is powered by ${trade.provider != null ? trade.provider.title : fetchingLabel}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryTextTheme.headline.color),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Center(
                child: Text(
                  trade.inputAddress ?? fetchingLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0, color: Palette.lightViolet),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 50.0, right: 50.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                      child: Container(
                    padding: EdgeInsets.only(right: 5.0),
                    child: CopyButton(
                      onPressed: () => Clipboard.setData(
                          ClipboardData(text: trade.inputAddress)),
                      text: 'Copy Address',
                      color: Theme.of(context).accentTextTheme.button.backgroundColor,
                      borderColor: Theme.of(context).accentTextTheme.button.decorationColor,
                    ),
                  )),
                  Flexible(
                      child: Container(
                    padding: EdgeInsets.only(left: 5.0),
                    child: CopyButton(
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: trade.id)),
                      text: 'Copy ID',
                      color: Theme.of(context).accentTextTheme.button.backgroundColor,
                      borderColor: Theme.of(context).accentTextTheme.button.decorationColor,
                    ),
                  ))
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                tradeStore.isSendable
                    ? 'By pressing confirm, you will be sending ${trade.amount ?? fetchingLabel} ${trade.from} from '
                        'your wallet called $walletName to the address shown above.'
                        'Or you can send from your external wallet to the above address/QR code.'
                        '\n\n'
                        'Please press confirm to continue or go back to change the amounts.'
                        '\n\n'
                    : 'Please send ${trade.amount ?? fetchingLabel} ${trade.from} to the address shown above.\n\n',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 13.0,
                    color: Theme.of(context).primaryTextTheme.title.color),
              ),
            ),
            Text(
              '*Please copy or write down your ID shown above.',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context).accentTextTheme.title.color),
            )
          ],
        );
      }),
      bottomSection: Container(
        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: PrimaryButton(
          onPressed: () => sendStore.createTransaction(
              address: tradeStore.trade.inputAddress,
              amount: tradeStore.trade.amount),
          text: 'Confirm',
          color: Theme.of(context).primaryTextTheme.button.backgroundColor,
          borderColor: Theme.of(context).primaryTextTheme.button.decorationColor,
        ),
      ),
    );
  }

  void _setEffects(BuildContext context) {
    if (_effectsInstalled) {
      return;
    }

    final sendStore = Provider.of<SendStore>(context);

    reaction((_) => sendStore.state, (state) {
      if (state is SendingFailed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text(state.error),
                  actions: <Widget>[
                    FlatButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.of(context).pop())
                  ],
                );
              });
        });
      }

      if (state is TransactionCreatedSuccessfully) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirm sending'),
                  content: Text(
                      'Commit transaction\nAmount: ${sendStore.pendingTransaction.amount}\nFee: ${sendStore.pendingTransaction.fee}'),
                  actions: <Widget>[
                    FlatButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          sendStore.commitTransaction();
                        }),
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                );
              });
        });
      }

      if (state is TransactionCommitted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Sending'),
                  content: Text('Transaction sent!'),
                  actions: <Widget>[
                    FlatButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.of(context).pop())
                  ],
                );
              });
        });
      }
    });

    _effectsInstalled = true;
  }
}
