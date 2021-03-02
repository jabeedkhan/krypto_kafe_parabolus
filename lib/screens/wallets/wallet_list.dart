import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:kryptokafe/model/new_wallet.dart';
import 'package:kryptokafe/screens/wallets/wallet_overview_detail.dart';
import 'package:kryptokafe/utils/apiclient.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class WalletList extends StatefulWidget {
  @override
  _WalletListState createState() => _WalletListState();
}

class _WalletListState extends State<WalletList> {
  String walletId;
  var preferences = KryptoSharedPreferences(), amount, balance = "0.0";
  NewWallet walletData;
  bool showShimmer = true, searchView = false;
  ApiClient apiClient = ApiClient();
  int itemCount, balanceIndexCount;
  List balanceList = [], coinName = [];
  Icon appbarIcon;
  Widget appTitle;
  TextField searchBarTextField;
  List<CoinDetails> coinDetails = [];

  @override
  void initState() {
    super.initState();
    _inititalize();
  }

  _inititalize() async {
    appbarIcon = Icon(Icons.search, color: Colors.black87);
    appTitle = Text("Wallet", style: TextStyle(color: Colors.black));
    searchBarTextField = TextField(
      autofocus: true,
      keyboardType: TextInputType.text,
      // inputFormatters: [FilteringTextInputFormatter.allow(r"^[a-zA-Z]")],
      onChanged: updateSearch,
    );

    walletData =
        NewWallet.fromJson(await preferences.read(StringConstants.WALLET_DATA));

    coinDetails = walletData.coinDetailList;
    setState(() {
      walletId = walletData.id;
      showShimmer = false;
    });
  }

  searchBar() {
    if (appbarIcon.icon == Icons.search) {
      setState(() {
        appbarIcon = Icon(
          Icons.close,
          color: Colors.black87,
        );

        appTitle = searchBarTextField;
      });
    } else if (appbarIcon.icon == Icons.close) {
      setState(() {
        coinDetails = walletData.coinDetailList;

        appbarIcon = Icon(
          Icons.search,
          color: Colors.black87,
        );

        appTitle = Text(
          "Wallet",
          style: TextStyle(color: Colors.black),
        );
      });
    }
  }

  updateSearch(String value) {
    coinDetails = [];
    if (value.isNotEmpty) {
      // coinData.retainWhere((element) =>
      //     element.coinName.toLowerCase().contains(value.toLowerCase()));
      setState(() {
        walletData.coinDetailList.forEach((element) {
          if (element.coinName.toLowerCase().contains(value.toLowerCase()) &&
              !coinDetails.contains(element)) {
            coinDetails.add(element);
          }
        });
      });
    } else if (value.isEmpty) {
      setState(() {
        coinDetails = walletData.coinDetailList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    var mediaqueryWidth = MediaQuery.of(context).size.width;
    var hwSize = mediaqueryHeight + mediaqueryWidth;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
                    .animate(animation),
                child: child,
              );
            },
            duration: Duration(milliseconds: 170),
            child: appTitle,
          ),
          actions: [
            IconButton(
              icon: appbarIcon,
              onPressed: () {
                searchBar();
              },
            )
          ],
        ),
        body: showShimmer
            ? ListView.builder(
                itemCount: 5,
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: Shimmer.fromColors(
                      baseColor: Colors.grey[100],
                      highlightColor: Colors.grey[200],
                      enabled: true,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        //   minRadius: hwSize / 40.0,
                      ),
                    ),
                    title: Shimmer.fromColors(
                      baseColor: Colors.grey[100],
                      highlightColor: Colors.grey[200],
                      enabled: true,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(hwSize / 30.0)),
                        height: 15.0,
                        // width:10.0,
                      ),
                    ),
                    subtitle: Shimmer.fromColors(
                      baseColor: Colors.grey[100],
                      highlightColor: Colors.grey[200],
                      enabled: true,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(hwSize / 30.0)),
                        height: 15.0,
                        width: 10.0,
                      ),
                    ),
                  );
                },
              )
            : coinDetails.length == 0
                ? Center(child: Text("No results found"))
                : ListView.builder(
                    itemCount: coinDetails.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CachedNetworkImage(
                          width: 40.0,
                          imageUrl: apiClient
                              .getAssetIconURL(coinDetails[index].coinSymbol),
                          errorWidget: (context, url, error) {
                            return Image.network(
                                "https://coincap.io/static/logo_mark.png");
                          },
                        ),
                        title: Text(
                          coinDetails[index].coinName,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(coinDetails[index].balance.toString()),
                        trailing: Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => WalletOverviewDetail(
                                        coinDetails,
                                        index,
                                      ))).whenComplete(() => _inititalize());
                        },
                      );
                    },
                  ));
  }
}
