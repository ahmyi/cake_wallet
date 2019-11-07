import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cake_wallet/router.dart';
import 'package:cake_wallet/src/domain/exchange/trade_history.dart';
import 'package:cake_wallet/src/domain/services/user_service.dart';
import 'package:cake_wallet/src/domain/services/wallet_list_service.dart';
import 'package:cake_wallet/src/domain/common/node_list.dart';
import 'package:cake_wallet/src/domain/services/wallet_service.dart';
import 'package:cake_wallet/src/domain/common/crypto_currency.dart';
import 'package:cake_wallet/src/domain/exchange/changenow/changenow_exchange_provider.dart';
import 'package:cake_wallet/src/domain/exchange/xmrto/xmrto_exchange_provider.dart';
import 'package:cake_wallet/src/screens/exchange/exchange_page.dart';
import 'package:cake_wallet/src/screens/dashboard/dashboard_page.dart';
import 'package:cake_wallet/src/screens/settings/settings.dart';
import 'package:cake_wallet/src/stores/exchange/exchange_store.dart';
import 'package:cake_wallet/src/stores/balance/balance_store.dart';
import 'package:cake_wallet/src/stores/sync/sync_store.dart';
import 'package:cake_wallet/src/stores/transaction_list/transaction_list_store.dart';
import 'package:cake_wallet/src/stores/wallet/wallet_store.dart';
import 'package:cake_wallet/src/stores/node_list/node_list_store.dart';
import 'package:cake_wallet/src/stores/settings/settings_store.dart';
import 'package:cake_wallet/theme_changer.dart';
import 'package:cake_wallet/themes.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<Database>(context);
    final sharedPreferences = Provider.of<SharedPreferences>(context);
    final userService = Provider.of<UserService>(context);
    final walletService = Provider.of<WalletService>(context);
    final walletListService = Provider.of<WalletListService>(context);

    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    bool _isDarkTheme;

    if (_themeChanger.getTheme() == Themes.darkTheme)
      _isDarkTheme = true;
    else
      _isDarkTheme = false;

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: _isDarkTheme ? Colors.black : Colors.white,
        // border: null,
        activeColor: Color.fromRGBO(121, 201, 233, 1),
        inactiveColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/wallet_icon.png',
                color: Colors.grey, height: 20),
            activeIcon: Image.asset('assets/images/wallet_icon.png',
                color: Color.fromRGBO(121, 201, 233, 1), height: 20),
            title: const Text('Wallet'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/exchange_icon.png',
                color: Colors.grey, height: 20),
            activeIcon: Image.asset('assets/images/exchange_icon.png',
                color: Color.fromRGBO(121, 201, 233, 1), height: 20),
            title: const Text('Exchange'),
          ),
          // BottomNavigationBarItem(
          //   icon: Image.asset('assets/images/settings_icon.png',
          //       color: Colors.grey, height: 20),
          //   activeIcon: Image.asset('assets/images/settings_icon.png',
          //       color: Color.fromRGBO(121, 201, 233, 1), height: 20),
          //   title: const Text('Settings'),
          // ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
                onGenerateRoute: (settings) => Router.generateRoute(
                    sharedPreferences,
                    walletListService,
                    walletService,
                    userService,
                    db,
                    settings),
                builder: (context) => MultiProvider(providers: [
                      ProxyProvider<SettingsStore, TransactionListStore>(
                        builder: (_, settingsStore, __) => TransactionListStore(
                            walletService: walletService,
                            settingsStore: settingsStore),
                      ),
                      ProxyProvider<SettingsStore, BalanceStore>(
                        builder: (_, settingsStore, __) => BalanceStore(
                            walletService: walletService,
                            settingsStore: settingsStore),
                      ),
                      ProxyProvider<SettingsStore, WalletStore>(
                          builder: (_, settingsStore, __) => WalletStore(
                              walletService: walletService,
                              settingsStore: settingsStore)),
                      Provider(
                        builder: (context) =>
                            SyncStore(walletService: walletService),
                      ),
                    ], child: DashboardPage()));
          case 1:
            return MultiProvider(providers: [
              Provider(builder: (_) {
                final xmrtoprovider = XMRTOExchangeProvider();

                return ExchangeStore(
                    initialProvider: xmrtoprovider,
                    initialDepositCurrency: CryptoCurrency.xmr,
                    initialReceiveCurrency: CryptoCurrency.btc,
                    tradeHistory: TradeHistory(db: db),
                    providerList: [xmrtoprovider, ChangeNowExchangeProvider()]);
              }),
              ProxyProvider<SettingsStore, WalletStore>(
                  builder: (_, settingsStore, __) => WalletStore(
                      walletService: walletService,
                      settingsStore: settingsStore)),
            ], child: ExchangePage());
          case 2:
            return CupertinoTabView(
                onGenerateRoute: (settings) => Router.generateRoute(
                    sharedPreferences,
                    walletListService,
                    walletService,
                    userService,
                    db,
                    settings),
                builder: (context) => Provider(
                    builder: (_) => NodeListStore(nodeList: NodeList(db: db)),
                    child: SettingsPage()));
        }

        return null;
      },
    );
  }
}
