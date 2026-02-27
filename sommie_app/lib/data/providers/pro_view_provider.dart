import 'package:flutter/material.dart';

enum ProView {
  dashboard,
  profile,
  editProfile,
  chat,
  cellar,
  cellarAdd,
  cellarPreview,
  cellarConfirm,
  benefits,
  game,
  wineStores,
  restaurantPocket,
}

class ProViewProvider extends ChangeNotifier {
  ProView _currentView = ProView.dashboard;

  ProView get currentView => _currentView;

  void setView(ProView view) {
    if (_currentView != view) {
      _currentView = view;
      notifyListeners();
    }
  }

  void goBack() {
    setView(ProView.dashboard);
  }
}
