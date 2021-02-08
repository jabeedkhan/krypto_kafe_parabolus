import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:kryptokafe/utils/chart_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:kryptokafe/customwidgets/nointernetconnection.dart';
import 'package:kryptokafe/utils/apiclient.dart';
import 'package:kryptokafe/utils/enums.dart';
import 'package:kryptokafe/utils/stringocnstants.dart';
import 'package:kryptokafe/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/enums/mode.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kryptokafe/utils/krypto_sharedperferences.dart';
import 'package:kryptokafe/model/wyre_currencies.dart';
import 'package:kryptokafe/customwidgets/primary_button.dart';
import 'package:kryptokafe/model/user_data.dart';
import 'package:kryptokafe/model/new_wallet.dart';
import 'home.dart';
import 'package:kryptokafe/utils/assets.dart';
import 'package:kryptokafe/screens/wallets/transfer_wallet.dart';

class OpenEachCoinHistory extends StatefulWidget {
  final coinId;
  final coinSymbol;
  OpenEachCoinHistory(this.coinId, this.coinSymbol);
  @override
  _OpenEachCoinHistoryState createState() => _OpenEachCoinHistoryState();
}

class _OpenEachCoinHistoryState extends State<OpenEachCoinHistory> {
  var utils = Utils(), apiClient = ApiClient();
  bool internetStatus = true,
      shimmerStatus = true,
      firstTimeCompleted = false,
      loadingChart = true,
      showBuyButton = false;
  Connectivity connectivity = Connectivity();
  Map coindData = {};
  List historyList = List(), actualHistoryList = List();
  LineChartController controller;
  var maxValue = 0.0,
      minValue = 0.0,
      highValue = 0.0,
      lowValue = 0.0,
      startPeriod,
      endPeriod,
      chartInterval;
  var chartData;
  int attempts = 1, index;
  var presentTime = DateTime.now();
  TimePeriod timePeriod = TimePeriod.oneHour;
  Timer _timer;
  KryptoSharedPreferences pref = KryptoSharedPreferences();
  WyreCurrencies currency;
  UserData userData;
  NewWallet wallet;

  @override
  void initState() {
    super.initState();
    connectivity.checkConnectivity().then(onInternetStatus);
    connectivity.onConnectivityChanged.listen(onInternetStatus);
    _initialize();
  }

  _initialize() async {
    userData = UserData.fromJson(await pref.read(StringConstants.USER_DATA));
    wallet = NewWallet.fromJson(await pref.read(StringConstants.WALLET_DATA));
    calculateTimeInterval();
    getCoinData();
    getHistoryData();
    currency = WyreCurrencies.fromJson(await pref.read("Currency")) ?? null;
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      calculateTimeInterval();
      getCoinData();
      getHistoryData();
    });
  }

  calculateTimeInterval() {
    switch (timePeriod) {
      case TimePeriod.oneHour:
        startPeriod = presentTime
            .subtract(Duration(hours: 1))
            .toUtc()
            .millisecondsSinceEpoch;
        chartInterval = "m5";

        break;

      case TimePeriod.oneDay:
        startPeriod = presentTime
            .subtract(Duration(hours: 24))
            .toUtc()
            .millisecondsSinceEpoch;
        chartInterval = "m15";
        break;

      case TimePeriod.oneWeek:
        startPeriod = presentTime
            .subtract(Duration(days: 7))
            .toUtc()
            .millisecondsSinceEpoch;
        chartInterval = "h2";
        break;
      case TimePeriod.oneMonth:
        startPeriod = presentTime
            .subtract(Duration(days: 30))
            .toUtc()
            .millisecondsSinceEpoch;
        chartInterval = "h6";
        break;
      case TimePeriod.sixMonth:
        startPeriod = presentTime
            .subtract(Duration(days: 120))
            .toUtc()
            .millisecondsSinceEpoch;
        chartInterval = "d1";
        break;
      case TimePeriod.oneYear:
        startPeriod = presentTime
            .subtract(Duration(days: 365))
            .toUtc()
            .millisecondsSinceEpoch;
        chartInterval = "d1";
        break;
      default:
    }
    endPeriod = presentTime.toUtc().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  onInternetStatus(value) {
    if (value == ConnectivityResult.mobile ||
        value == ConnectivityResult.wifi) {
      if (mounted)
        setState(() {
          internetStatus = true;
        });
    } else {
      if (mounted)
        setState(() {
          internetStatus = false;
        });
    }
  }

  getCoinData() async {
    var uri = Uri.https(apiClient.getBaseUrl(),
        StringConstants.assetsAPI + widget.coinId.toString());
    var response = await http.get(uri);
    if (response.statusCode == HttpStatus.ok) {
      var responseData = json.decode(response.body);
      if (mounted) {
        setState(() {
          coindData = responseData['data'];
          historyList = actualHistoryList;
        });
      }
    }
  }

  getHistoryData() async {
    var uri = Uri.https(apiClient.getBaseUrl(),
        StringConstants.assetsAPI + widget.coinId.toString() + "/history", {
      "interval": chartInterval,
      "start": startPeriod.toString(),
      "end": endPeriod.toString()
    });
    var response = await http.get(uri);
    if (response.statusCode == HttpStatus.ok) {
      var responseData = json.decode(response.body);
      if (mounted && responseData['data'] != [])
        setState(() {
          actualHistoryList = responseData['data'] as List;
          highValue = maxValue = double.parse(actualHistoryList[0]['priceUsd']);
          lowValue = minValue = double.parse(actualHistoryList[0]['priceUsd']);

          for (int i = 0; i < actualHistoryList.length; i++) {
            if (double.parse(actualHistoryList[i]['priceUsd']) > maxValue) {
              highValue =
                  maxValue = double.parse(actualHistoryList[i]['priceUsd']);
            }
            if (double.parse(actualHistoryList[i]['priceUsd']) < minValue) {
              lowValue =
                  minValue = double.parse(actualHistoryList[i]['priceUsd']);
            }
          }
          //   if (currency != null) {
          isCoinAvailable();
          shimmerStatus = false;
          //  } else {
          //    getSupportedCurrencies();
          //  }

          var avgVal = maxValue - minValue;
          avgVal = avgVal * 0.05;
          minValue -= avgVal;
          maxValue += avgVal;
        });

      _initController();
      _initLineData();
    }
  }

  isCoinAvailable() {
    Assets().cryptoCurrencies.forEach((key, value) {
      if (key.toUpperCase() == widget.coinSymbol.toUpperCase()) {
        setState(() {
          showBuyButton = true;
        });
      }
    });
    index = wallet.coinDetailList
        .indexWhere((element) => element.coinSymbol == widget.coinSymbol);
    // currency.currency.forEach((element) {
    //   if (element == widget.coinSymbol) {
    //     setState(() {
    //       showBuyButton = true;
    //     });
    //   }
    // });
  }

  getSupportedCurrencies() async {
    var dataToBeStored;
    try {
      var response = await http.get("https://api.sendwyre.com/v3/pairs?pretty");
      if (response.statusCode == 200) {
        Map jsonData = json.decode(response.body);
        jsonData['supportedExchangePairs'].forEach((key, value) {
          if (key == "USD") {
            dataToBeStored = value.toList();
          }
        });
        pref.save("Currency",
            currency = WyreCurrencies.fromJson({"USD": dataToBeStored}));
        await isCoinAvailable();
        setState(() {
          shimmerStatus = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _initController() {
    ChartMarkers marker =
        ChartMarkers(backColor: Colors.lightBlue, textColor: Colors.white);

    controller = LineChartController(
      axisLeftSettingFunction: (axisLeft, controller) {
        axisLeft
          ..drawLimitLineBehindData = false
          ..drawAxisLine = false
          ..drawGridLines = true
          ..gridColor = Colors.black12
          ..setLabelCount2(6, true)
          ..setGranularity(
              1) //todo granularity should be 4-5 points btwn minVal and maxVal
          ..setAxisMaximum(maxValue)
          ..setAxisMinimum(minValue);
      },
      axisRightSettingFunction: (axisRight, controller) {
        axisRight
          ..enabled = (false)
          ..drawGridLines = false;
      },
      legendSettingFunction: (legend, controller) {
        legend.shape = (LegendForm.LINE);
        legend.enabled = false;
      },
      xAxisSettingFunction: (xAxis, controller) {
        xAxis
          // ..setValueFormatter(IndexaxisvalueFormatter("Day"))
          ..axisLineWidth = 0.0
          ..axisLineColor = Colors.black
          ..drawGridLines = false
          ..drawAxisLine = false
          ..drawGridLinesBehindData = true
          ..drawLimitLineBehindData = false
          ..granularityEnabled = true
          ..setGranularity(4)
          ..setValueFormatter(XAxisValueFormatter(timePeriod));
      },
      marker: marker,
      drawMarkers: true,
      gridBackColor: Colors.white,
      drawGridBackground: false,
      backgroundColor: Colors.white,
      dragXEnabled: true,
      dragYEnabled: true,
      scaleXEnabled: true,
      scaleYEnabled: false,
      pinchZoomEnabled: false,
      highlightPerDragEnabled: true,
    );
  }

  _initLineData() async {
    List<Entry> values = List();

    for (int i = 0; i < actualHistoryList.length; i++) {
      values.add(Entry(
        x: (actualHistoryList[i]['time']).toDouble(),
        y: double.parse(actualHistoryList[i]['priceUsd']),
      ));
    }

    LineDataSet set1;

    set1 = LineDataSet(values, "DataSet 1");
    set1
      ..setColor1(Color(0xFF23F693))
      ..setDrawIcons(false)
      ..setValueTextSize(9)
      ..setDrawFilled(false);

    List<ILineDataSet> dataSets = List();
    dataSets.add(set1);

    controller.data = LineData.fromList(dataSets);

    List<ILineDataSet> sets = controller.data.dataSets;

    for (ILineDataSet iSet in sets) {
      LineDataSet set = iSet as LineDataSet;
      set.setMode(Mode.LINEAR);
      set.setDrawCircles(false);
      set.setDrawValues(false);
    }
    if (mounted)
      setState(() {
        loadingChart = false;
      });
  }

  Widget _initLineChart() {
    if (controller != null && controller.data != null) {
      var lineChart = LineChart(controller);

      return lineChart;
    } else {
      return CircularProgressIndicator();
    }
  }

  Future<bool> _onbackPressed() {
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home(0)));
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    var mediaqueryHeight = MediaQuery.of(context).size.height;
    var mediaqueryWidth = MediaQuery.of(context).size.width;
    var hwSize = mediaqueryHeight + mediaqueryWidth;

    return WillPopScope(
      onWillPop: _onbackPressed,
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              title: shimmerStatus
                  ? Shimmer.fromColors(
                      enabled: true,
                      baseColor: Colors.grey[100],
                      highlightColor: Colors.grey[200],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(),
                          SizedBox(width: 10.0),
                          Container(
                            height: 10.0,
                            width: 80.0,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CachedNetworkImage(
                            width: MediaQuery.of(context).size.width / 15.0,
                            placeholder: (context, url) {
                              return utils.progressIndicator();
                            },
                            errorWidget: (context, url, error) {
                              return Image.network(
                                  "https://coincap.io/static/logo_mark.png");
                            },
                            imageUrl: apiClient.getAssetIconURL(
                                coindData["symbol"].toString())),
                        SizedBox(width: 10.0),
                        Text(
                          coindData["name"].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.height / 45.0,
                            fontFamily: StringConstants.oxygenFontnameString,
                          ),
                        ),
                        Text(
                          " (" + coindData["symbol"].toString() + ")",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.height / 45.0,
                            fontFamily: StringConstants.oxygenFontnameString,
                          ),
                        ),
                      ],
                    ),
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            body: !internetStatus
                ? NoInternetConnection()
                : Container(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: shimmerStatus || coindData == null
                        ? SingleChildScrollView(
                            child: Shimmer.fromColors(
                                enabled: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 40.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      width: 180.0,
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      width: 150.0,
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      width: 130.0,
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      width: 100.0,
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 60.0,
                                    ),
                                    Center(
                                      child: Container(
                                        color: Colors.black,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.1,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                      ),
                                    ),
                                  ],
                                ),
                                baseColor: Colors.grey[100],
                                highlightColor: Colors.grey[200]),
                          )
                        : Container(
                            child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text("Price : ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          50.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                )),
                                            Text(
                                                utils
                                                    .moneyFormatterWithOutCompact(
                                                        coindData["priceUsd"] ??
                                                            0.0.toString(),
                                                        coindData["symbol"]
                                                            .toString()),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            40.0,
                                                    fontFamily: StringConstants
                                                        .oxygenFontnameString)),
                                            SizedBox(width: 10.0),
                                            coindData['changePercent24Hr'] !=
                                                    null
                                                ? Text(
                                                    utils.moneyFormatterWithOutSymbol(
                                                            coindData[
                                                                    "changePercent24Hr"]
                                                                .toString(),
                                                            coindData["symbol"]
                                                                .toString()) +
                                                        "%",
                                                    style: TextStyle(
                                                      color: double.parse(coindData[
                                                                  "changePercent24Hr"]) >
                                                              0
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              55.0,
                                                      fontFamily: StringConstants
                                                          .oxygenFontnameString,
                                                    ))
                                                : Text(""),
                                            coindData['changePercent24Hr'] !=
                                                    null
                                                ? Icon(
                                                    double.parse(coindData[
                                                                "changePercent24Hr"]) >
                                                            0
                                                        ? Icons.arrow_drop_up
                                                        : Icons.arrow_drop_down,
                                                    color: double.parse(coindData[
                                                                "changePercent24Hr"]) >
                                                            0
                                                        ? Colors.green
                                                        : Colors.red,
                                                  )
                                                : Container()
                                          ],
                                        ),
                                        SizedBox(height: 5.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text("Market Cap : ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          50.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                )),
                                            Text(
                                                utils.moneyFormatterWithSymbolWithCompact(
                                                    coindData["marketCapUsd"] ??
                                                        0.0.toString(),
                                                    coindData["symbol"]
                                                        .toString()),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          60.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                ))
                                          ],
                                        ),
                                        SizedBox(height: 5.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text("Volume (24Hr) : ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          50.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                )),
                                            Text(
                                                utils.moneyFormatterWithSymbolWithCompact(
                                                    coindData[
                                                            "volumeUsd24Hr"] ??
                                                        0.0.toString(),
                                                    coindData["symbol"]
                                                        .toString()),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          60.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                ))
                                          ],
                                        ),
                                        SizedBox(height: 5.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text("Supply : ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          50.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                )),
                                            Text(
                                                utils.moneyFormatterWithSymbolWithCompact(
                                                        coindData["supply"] ??
                                                            0.0.toString(),
                                                        coindData["symbol"]
                                                            .toString()) +
                                                    " " +
                                                    coindData["symbol"]
                                                        .toString(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          60.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(coindData["rank"].toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50.0,
                                                fontFamily: StringConstants
                                                    .oxygenFontnameString,
                                              )),
                                          SizedBox(height: 5.0),
                                          Text("Rank",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    70.0,
                                                fontFamily: StringConstants
                                                    .oxygenFontnameString,
                                              )),
                                        ],
                                      ),
                                      width:
                                          MediaQuery.of(context).size.width / 6,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              13.0,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/rank_banner.png"),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text("HIGH : ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          55.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                )),
                                            Text(
                                                utils
                                                    .moneyFormatterWithOutCompact(
                                                        highValue ??
                                                            0.0.toString(),
                                                        coindData["symbol"]
                                                            .toString()),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          55.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                ))
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: <Widget>[
                                            Text("LOW : ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          55.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                )),
                                            Text(
                                                utils
                                                    .moneyFormatterWithOutCompact(
                                                        lowValue.toString(),
                                                        coindData["symbol"]
                                                            .toString()),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          55.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text("AVG : ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          55.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                )),
                                            Text(
                                                utils.moneyFormatterWithSymbolWithCompact(
                                                    coindData["marketCapUsd"] ??
                                                        0.0.toString(),
                                                    coindData["symbol"]
                                                        .toString()),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          60.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
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
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          55.0,
                                                  fontFamily: StringConstants
                                                      .oxygenFontnameString,
                                                )),
                                            coindData['changePercent24Hr'] !=
                                                    null
                                                ? Text(
                                                    utils.moneyFormatterWithOutSymbol(
                                                            coindData[
                                                                    "changePercent24Hr"]
                                                                .toString(),
                                                            coindData["symbol"]
                                                                .toString()) +
                                                        "%",
                                                    style: TextStyle(
                                                      color: double.parse(coindData[
                                                                  "changePercent24Hr"]) >
                                                              0
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              60.0,
                                                      fontFamily: StringConstants
                                                          .oxygenFontnameString,
                                                    ))
                                                : Text(""),
                                            coindData['changePercent24Hr'] !=
                                                    null
                                                ? Icon(
                                                    double.parse(coindData[
                                                                "changePercent24Hr"]) >
                                                            0
                                                        ? Icons.arrow_drop_up
                                                        : Icons.arrow_drop_down,
                                                    color: double.parse(coindData[
                                                                "changePercent24Hr"]) >
                                                            0
                                                        ? Colors.green
                                                        : Colors.red,
                                                  )
                                                : Text("")
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  "Move your finger on chart to view values",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            60.0,
                                    fontFamily:
                                        StringConstants.oxygenFontnameString,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Container(
                                  // color: Colors.blue,
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: loadingChart
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : _initLineChart(),
                                  // child: fl_charts.AnimatedLineChart(
                                  //   chartData,
                                  //   // key: UniqueKey(),
                                  // ),
                                ),
                                SizedBox(
                                  height: 30.0,
                                  child: ListView(
                                    // shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      FlatButton(
                                          padding: EdgeInsets.all(0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          color:
                                              timePeriod == TimePeriod.oneHour
                                                  ? Colors.blue
                                                  : Colors.grey[200],
                                          onPressed: () {
                                            if (timePeriod !=
                                                TimePeriod.oneHour) if (mounted)
                                              setState(() {
                                                timePeriod = TimePeriod.oneHour;
                                                loadingChart = true;
                                              });
                                          },
                                          child: Text(
                                            "1 Hour",
                                            style: TextStyle(
                                                color: timePeriod ==
                                                        TimePeriod.oneHour
                                                    ? Colors.white
                                                    : Colors.black),
                                          )),
                                      FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          color: timePeriod == TimePeriod.oneDay
                                              ? Colors.blue
                                              : Colors.grey[200],
                                          onPressed: () {
                                            if (timePeriod !=
                                                TimePeriod.oneDay) if (mounted)
                                              setState(() {
                                                timePeriod = TimePeriod.oneDay;
                                                loadingChart = true;
                                              });
                                          },
                                          child: Text(
                                            "24 Hour",
                                            style: TextStyle(
                                                color: timePeriod ==
                                                        TimePeriod.oneDay
                                                    ? Colors.white
                                                    : Colors.black),
                                          )),
                                      FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          color:
                                              timePeriod == TimePeriod.oneWeek
                                                  ? Colors.blue
                                                  : Colors.grey[200],
                                          onPressed: () {
                                            if (timePeriod !=
                                                TimePeriod.oneWeek) if (mounted)
                                              setState(() {
                                                timePeriod = TimePeriod.oneWeek;
                                                loadingChart = true;
                                              });
                                          },
                                          child: Text("1 Week",
                                              style: TextStyle(
                                                  color: timePeriod ==
                                                          TimePeriod.oneWeek
                                                      ? Colors.white
                                                      : Colors.black))),
                                      FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          color:
                                              timePeriod == TimePeriod.oneMonth
                                                  ? Colors.blue
                                                  : Colors.grey[200],
                                          onPressed: () {
                                            if (timePeriod !=
                                                TimePeriod
                                                    .oneMonth) if (mounted)
                                              setState(() {
                                                timePeriod =
                                                    TimePeriod.oneMonth;
                                                loadingChart = true;
                                              });
                                          },
                                          child: Text("1 Month",
                                              style: TextStyle(
                                                  color: timePeriod ==
                                                          TimePeriod.oneMonth
                                                      ? Colors.white
                                                      : Colors.black))),
                                      FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          color:
                                              timePeriod == TimePeriod.sixMonth
                                                  ? Colors.blue
                                                  : Colors.grey[200],
                                          onPressed: () {
                                            if (timePeriod !=
                                                TimePeriod
                                                    .sixMonth) if (mounted)
                                              setState(() {
                                                timePeriod =
                                                    TimePeriod.sixMonth;
                                                loadingChart = true;
                                              });
                                          },
                                          child: Text("6 Month",
                                              style: TextStyle(
                                                  color: timePeriod ==
                                                          TimePeriod.sixMonth
                                                      ? Colors.white
                                                      : Colors.black))),
                                      FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          color:
                                              timePeriod == TimePeriod.oneYear
                                                  ? Colors.blue
                                                  : Colors.grey[200],
                                          onPressed: () {
                                            if (timePeriod !=
                                                TimePeriod.oneYear) if (mounted)
                                              setState(() {
                                                timePeriod = TimePeriod.oneYear;
                                                loadingChart = true;
                                              });
                                          },
                                          child: Text("1 Year",
                                              style: TextStyle(
                                                  color: timePeriod ==
                                                          TimePeriod.oneYear
                                                      ? Colors.white
                                                      : Colors.black))),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 50.0,
                                ),
                                Visibility(
                                  visible: showBuyButton,
                                  child: PrimaryButton({
                                    "horizontalPadding": mediaqueryWidth / 7.0,
                                    "verticalPadding": mediaqueryHeight / 75.0,
                                    "fontSize": hwSize / 75.0,
                                    "data": "Buy Now"
                                  }, () {
                                    ///check if user has wallet if [0] then navigate to create wallet screen
                                    ///if [1] then the take to the particular crypto currency
                                    if (userData.data.walletStatus == 1) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TransferWallet(
                                                    wallet.coinDetailList,
                                                    index,
                                                  )));
                                    } else {
                                      Navigator.canPop(context);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home(1)),
                                        (route) => true,
                                      );
                                    }
                                  }),
                                )
                              ],
                            ),
                          )),
                  )),
      ),
    );
  }
}
