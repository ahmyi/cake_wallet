import 'package:cake_wallet/routes.dart';
import 'package:cake_wallet/src/domain/exchange/exchange_provider_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cake_wallet/palette.dart';
import 'package:cake_wallet/src/stores/trade_history/trade_history_store.dart';
import 'package:cake_wallet/src/screens/base_page.dart';

class TradeHistoryPage extends BasePage {
  String get title => 'Trade history';
  bool get isModalBackButton => true;

  @override
  Widget body(BuildContext context) {
    final tradeHistoryStore = Provider.of<TradeHistoryStore>(context);

    return Observer(
      builder: (_) => ListView.separated(
        separatorBuilder: (_, __) => Divider(
          color: Theme.of(context).dividerTheme.color,
          height: 1.0,
        ),
        itemCount: tradeHistoryStore.tradeList == null
            ? 0
            : tradeHistoryStore.tradeList.length,
        itemBuilder: (BuildContext context, int index) {
          final trade = tradeHistoryStore.tradeList[index];
          final date = DateFormat("dd-MM-yyyy, H:m").format(trade.createdAt);
          final provider = trade.provider;
          final poweredTitle = provider.title;
          final imageSrc = _getPoweredImage(provider);

          return InkWell(
            onTap: () => Navigator.of(context)
                .pushNamed(Routes.tradeDetails, arguments: trade),
            child: Container(
              child: Column(
                children: <Widget>[
                  index == 0
                      ? Divider(
                          color: Theme.of(context).dividerTheme.color,
                          height: 1.0,
                        )
                      : Offstage(),
                  ListTile(
                      leading: imageSrc,
                      title: Text(
                        '$poweredTitle',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context).primaryTextTheme.button.color),
                      ),
                      trailing: Text(
                        date,
                        style: TextStyle(
                            fontSize: 16.0, color: Palette.wildDarkBlue),
                      )),
                  index == tradeHistoryStore.tradeList.length - 1
                      ? Divider(
                          color: Theme.of(context).dividerTheme.color,
                          height: 1.0,
                        )
                      : Offstage(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Image _getPoweredImage(ExchangeProviderDescription provider) {
    Image image;
    switch (provider) {
      case ExchangeProviderDescription.xmrto:
        image = Image.asset('assets/images/xmr_btc.png');
        break;
      case ExchangeProviderDescription.changeNow:
        image = Image.asset('assets/images/change_now.png');
        break;
      default:
        image = null;
    }
    return image;
  }
}
