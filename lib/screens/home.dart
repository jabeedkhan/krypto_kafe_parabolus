import 'package:kryptokafe/screens/market.dart';
import 'package:kryptokafe/screens/profile/profile_overview.dart';
import 'package:kryptokafe/screens/wallets/wallet_fragment_container.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  final widgetOptions = [
    Market(),
    WalletFragmentContainer(),
    ProfileOverview()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: widgetOptions.elementAt(selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Coins"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: selectedIndex,
        fixedColor: Colors.blue[700],
        showUnselectedLabels: false,
        unselectedItemColor: Colors.grey[400],
        onTap: onItemTapped,
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
