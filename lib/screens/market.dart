import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:kryptokafe/screens/openeachcoinhistory.dart';
import 'package:kryptokafe/utils/apiclient.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;


import 'login_signup/login.dart';

class Market extends StatefulWidget {
  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> {
  var utils = Utils(), apiClient = ApiClient();
  bool internetStatus = true, shimmerStatus = true, autoLoading = true;
  Connectivity connectivity = Connectivity();
  List assetsDataList = List(),
      oldAssetsList = List(),
      actualAssetsDataList = List(),
      searchList = List();
  int initialCount = 0, dataCount = 2000;
  int attempts = 1;
  var preeferences = KryptoSharedPreferences();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    connectivity.checkConnectivity().then(onInternetStatus);
    connectivity.onConnectivityChanged.listen(onInternetStatus);
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && autoLoading) getAllData();
    });
    getAllData();
  }

  onInternetStatus(value) {
    if (value == ConnectivityResult.mobile ||
        value == ConnectivityResult.wifi) {
      setState(() {
        internetStatus = true;
      });
    } else {
      setState(() {
        internetStatus = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  getAllData() async {
    var uri = Uri.https(apiClient.getBaseUrl(), StringConstants.assetsAPI, {
      'limit': dataCount.toString(),
      'offset': initialCount.toString(),
    });
    var response = await http.get(uri);
    if (response.statusCode == HttpStatus.ok) {
      var responseData = json.decode(response.body);
      if (mounted) {
        setState(() {
          actualAssetsDataList = responseData['data'] as List;
          if (attempts == 1) {
            oldAssetsList = actualAssetsDataList;
            for (int i = 0; i < oldAssetsList.length; i++) {
              oldAssetsList[i]["isOpened"] = false;
            }
          }
          assetsDataList = actualAssetsDataList;
          shimmerStatus = false;
          attempts += 1;
        });
      }
    }
  }

  searchCoins(value) {
    try {
      if (value.isNotEmpty) {
        setState(() {
          autoLoading = false;
          assetsDataList = actualAssetsDataList.where((element) {
            return (element['name']
                    .toString()
                    .toLowerCase()
                    .contains(value.toString().toLowerCase()) ||
                element['symbol']
                    .toString()
                    .toLowerCase()
                    .contains(value.toString().toLowerCase()));
          }).toList();
        });
        //sprint(assetsDataList.toString());
      } else if (value.isEmpty) {
        setState(() {
          autoLoading = true;
          assetsDataList = actualAssetsDataList;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  showMoreData(eachCoinData) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(eachCoinData["name"].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.height / 50.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            )),
                        Text("(" + eachCoinData["symbol"].toString() + ")",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.height / 55.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            ))
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      utils.getDate(DateTime.now().toString(), false, "date"),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 55.0,
                        fontFamily: StringConstants.oxygenFontnameString,
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Price : ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.height / 55.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            )),
                        Text(
                            utils.moneyFormatterWithOutCompact(
                                eachCoinData["priceUsd"].toString(),
                                eachCoinData["symbol"].toString()),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.height / 55.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            ))
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Text("Vwap : ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.height / 55.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            )),
                        eachCoinData['vwap24Hr'] != null
                            ? Text(
                                utils.moneyFormatterWithOutCompact(
                                    eachCoinData["vwap24Hr"].toString(),
                                    eachCoinData["symbol"].toString()),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.height / 55.0,
                                  fontFamily:
                                      StringConstants.oxygenFontnameString,
                                ))
                            : Text("")
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("AVG : ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.height / 55.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            )),
                        Text(
                            utils.moneyFormatterWithSymbolWithCompact(
                                eachCoinData["marketCapUsd"].toString(),
                                eachCoinData["symbol"].toString()),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.height / 60.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            ))
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Text("CNG : ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.height / 55.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            )),
                        Text(
                            utils.moneyFormatterWithOutSymbol(
                                    eachCoinData["changePercent24Hr"]
                                        .toString(),
                                    eachCoinData["symbol"].toString()) +
                                "%",
                            style: TextStyle(
                              color: double.parse(
                                          eachCoinData["changePercent24Hr"] ??
                                              "0.0") >
                                      0
                                  ? Colors.green
                                  : Colors.red,
                              fontSize:
                                  MediaQuery.of(context).size.height / 60.0,
                              fontFamily: StringConstants.oxygenFontnameString,
                            ))
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  _timer.cancel();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OpenEachCoinHistory(eachCoinData['id'],eachCoinData['symbol'])));
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    child: Text(
                      "More Details",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: MediaQuery.of(context).size.height / 55.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    var mediaqueryWidth = MediaQuery.of(context).size.width;
    var hwSize = mediaqueryHeight + mediaqueryWidth;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "Krypto Kafe".toUpperCase(),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 40.0,
              color: Colors.black,
              fontFamily: StringConstants.oxygenFontnameString,
            ),
          ),
        ),
        body: shimmerStatus
            ? ListView.builder(
                itemCount: 10,
                itemBuilder: (context, i) {
                  return Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[100],
                      highlightColor: Colors.grey[200],
                      enabled: true,
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.black,
                              minRadius: hwSize / 40.0,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                height: mediaqueryHeight / 15.0,
                                // width: mediaqueryWidth / 4.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : assetsDataList.length <= 0 && autoLoading
                ? utils.noDataFound(context)
                : Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25.0)),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search Coins",
                            hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600),
                            icon: Icon(
                              Icons.search,
                              color: Colors.black45,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                          onChanged: searchCoins,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.location_city,
                                    color: Colors.black,
                                  ),
                                  Text("Company Name",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                55.0,
                                        fontFamily: StringConstants
                                            .oxygenFontnameString,
                                      )),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.black,
                                  ),
                                  Text("Price",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                55.0,
                                        fontFamily: StringConstants
                                            .oxygenFontnameString,
                                      )),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.timeline,
                                    color: Colors.black,
                                  ),
                                  Text("Market Cap",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                55.0,
                                        fontFamily: StringConstants
                                            .oxygenFontnameString,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      assetsDataList.length > 0
                          ? Expanded(
                              child: ListView.builder(
                                  itemCount: assetsDataList.length + 1,
                                  itemBuilder: (context, i) {
                                    return (i < assetsDataList.length)
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            padding: EdgeInsets.all(10.0),
                                            margin: EdgeInsets.all(5.0),
                                            child: Column(
                                              children: <Widget>[
                                                InkWell(
                                                  onTap: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    setState(() {
                                                      if (oldAssetsList[i]
                                                          ["isOpened"]) {
                                                        oldAssetsList[i]
                                                                ["isOpened"] =
                                                            !oldAssetsList[i]
                                                                ["isOpened"];
                                                      } else {
                                                        for (int i = 0;
                                                            i <
                                                                oldAssetsList
                                                                    .length;
                                                            i++) {
                                                          oldAssetsList[i]
                                                                  ["isOpened"] =
                                                              false;
                                                        }
                                                        oldAssetsList[i]
                                                                ["isOpened"] =
                                                            !oldAssetsList[i]
                                                                ["isOpened"];
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                      CachedNetworkImage(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            10.0,
                                                        placeholder:
                                                            (context, url) {
                                                          return utils
                                                              .progressIndicator();
                                                        },
                                                        errorWidget: (context,
                                                            url, error) {
                                                          return Image.network(
                                                              "https://coincap.io/static/logo_mark.png");
                                                        },
                                                        imageUrl: apiClient
                                                            .getAssetIconURL(
                                                                assetsDataList[
                                                                            i][
                                                                        "symbol"]
                                                                    .toString()),
                                                      ),
                                                      SizedBox(width: 15.0),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                                assetsDataList[
                                                                            i]
                                                                        ["name"]
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      50.0,
                                                                  fontFamily:
                                                                      StringConstants
                                                                          .oxygenFontnameString,
                                                                )),
                                                            Text(
                                                                assetsDataList[
                                                                            i][
                                                                        "symbol"]
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      55.0,
                                                                  fontFamily:
                                                                      StringConstants
                                                                          .oxygenFontnameString,
                                                                ))
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            utils.moneyFormatter(
                                                                assetsDataList[i][
                                                                        "priceUsd"]
                                                                    .toString(),
                                                                assetsDataList[i]
                                                                        [
                                                                        "symbol"]
                                                                    .toString()),
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .height /
                                                                        60.0,
                                                                fontFamily:
                                                                    StringConstants
                                                                        .oxygenFontnameString,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                                utils.moneyFormatterWithSymbolWithCompact(
                                                                    assetsDataList[i]
                                                                            [
                                                                            "marketCapUsd"]
                                                                        .toString(),
                                                                    assetsDataList[i]
                                                                            [
                                                                            "symbol"]
                                                                        .toString()),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      60.0,
                                                                  fontFamily:
                                                                      StringConstants
                                                                          .oxygenFontnameString,
                                                                )),
                                                            Text(
                                                                utils.moneyFormatterWithOutSymbol(
                                                                        assetsDataList[i]["changePercent24Hr"]
                                                                            .toString(),
                                                                        assetsDataList[i]["symbol"]
                                                                            .toString()) +
                                                                    "%",
                                                                style:
                                                                    TextStyle(
                                                                  color: double.parse(assetsDataList[i]["changePercent24Hr"] ??
                                                                              "0.0") >
                                                                          0
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      60.0,
                                                                  fontFamily:
                                                                      StringConstants
                                                                          .oxygenFontnameString,
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                oldAssetsList[i]["isOpened"]
                                                    ? showMoreData(
                                                        assetsDataList[i])
                                                    : Container()
                                              ],
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              initialCount == 0
                                                  ? Container()
                                                  : FlatButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          shimmerStatus = true;
                                                          initialCount -= 20;
                                                        });
                                                        if (internetStatus)
                                                          getAllData();
                                                        else
                                                          utils.displayToast(
                                                              StringConstants
                                                                  .NO_INTERNET,
                                                              context,
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER);
                                                      },
                                                      child: Text("Prev"),
                                                    ),
                                              FlatButton(
                                                onPressed: () {
                                                  setState(() {
                                                    shimmerStatus = true;
                                                    initialCount += 20;
                                                  });
                                                  if (internetStatus)
                                                    getAllData();
                                                  else
                                                    utils.displayToast(
                                                        StringConstants
                                                            .NO_INTERNET,
                                                        context,
                                                        gravity: ToastGravity
                                                            .CENTER);
                                                },
                                                child: Text("View More"),
                                              ),
                                            ],
                                          );
                                  }),
                            )
                          : Expanded(
                              child: Center(child: Text("No results found"))),
                    ],
                  ),
      ),
    );
  }
}
