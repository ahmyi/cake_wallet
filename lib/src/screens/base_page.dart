import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cake_wallet/src/widgets/nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:cake_wallet/themes.dart';
import 'package:cake_wallet/theme_changer.dart';
import 'package:cake_wallet/palette.dart';

abstract class BasePage extends StatelessWidget {
  String get title => null;
  bool get isModalBackButton => false;

  Color get backgroundColor => Colors.white;

  final _backArrowImage = Image.asset('assets/images/back_arrow.png');
  final _backArrowImageDarkTheme = Image.asset('assets/images/back_arrow_dark_theme.png');
  final _closeButtonImage = Image.asset('assets/images/close_button.png');
  final _closeButtonImageDarkTheme = Image.asset('assets/images/close_button_dark_theme.png');

  Widget leading(BuildContext context) {
    if (ModalRoute.of(context).isFirst) {
      return null;
    }

    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    Image _closeButton, _backButton;

    if (_themeChanger.getTheme() == Themes.darkTheme){
      _backButton = _backArrowImageDarkTheme;
      _closeButton = _closeButtonImageDarkTheme;
    } else {
      _backButton = _backArrowImage;
      _closeButton = _closeButtonImage;
    }

    return SizedBox(
      height: 37,
      width: isModalBackButton ? 37 : 10,
      child: ButtonTheme(
        minWidth: double.minPositive,
        child: FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            padding: EdgeInsets.all(0),
            onPressed: () => Navigator.of(context).pop(),
            child: isModalBackButton ? _closeButton : _backButton),
      ),
    );
  }

  Widget middle(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    bool _isDarkTheme;

    if (_themeChanger.getTheme() == Themes.darkTheme) _isDarkTheme = true;
    else _isDarkTheme = false;

    return title == null
        ? null
        : Text(
      title,
      style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: _isDarkTheme ? PaletteDark.darkThemeTitle : Colors.black
      ),
    );
  }

  Widget trailing(BuildContext context) => null;

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    bool _isDarkTheme;

    if (_themeChanger.getTheme() == Themes.darkTheme) _isDarkTheme = true;
    else _isDarkTheme = false;

    return Scaffold(
        backgroundColor: _isDarkTheme ? Theme.of(context).backgroundColor
            : backgroundColor,
        resizeToAvoidBottomPadding: false,
        appBar: NavBar(
            leading: leading(context),
            middle: middle(context),
            trailing: trailing(context),
            backgroundColor: _isDarkTheme ? Theme.of(context).backgroundColor
                : backgroundColor),
        body: SafeArea(child: body(context)));
  }
}
