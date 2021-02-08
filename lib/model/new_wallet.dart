import 'package:kryptokafe/utils/assets.dart';

class NewWallet {
  PendingInterestBalances pendingInterestBalances;
  PendingInterestBalances savingRates;
  String status;
  String notes;
  DepositAddresses depositAddresses;
  TotalBalances totalBalances;
  AvailableBalances availableBalances;
  VerificationData verificationData;
  String pusherChannel;
  String srn;
  String callbackUrl;
  Balances balances;
  String name;
  String id;
  String type;
  List<CoinDetails> coinDetailList = [];

  NewWallet(
      {this.pendingInterestBalances,
      this.savingRates,
      this.status,
      this.notes,
      this.depositAddresses,
      this.totalBalances,
      this.availableBalances,
      this.verificationData,
      this.pusherChannel,
      this.srn,
      this.callbackUrl,
      this.balances,
      this.name,
      this.id,
      this.type,
      this.coinDetailList});

  NewWallet.fromJson(Map<String, dynamic> json) {
    pendingInterestBalances = json['pendingInterestBalances'] != null
        ? new PendingInterestBalances.fromJson(json['pendingInterestBalances'])
        : null;
    savingRates = json['savingRates'] != null
        ? new PendingInterestBalances.fromJson(json['savingRates'])
        : null;
    status = json['status'];
    notes = json['notes'];
    depositAddresses = json['depositAddresses'] != null
        ? new DepositAddresses.fromJson(json['depositAddresses'])
        : null;
    totalBalances = json['totalBalances'] != null
        ? new TotalBalances.fromJson(json['totalBalances'])
        : null;
    availableBalances = json['availableBalances'] != null
        ? new AvailableBalances.fromJson(json['availableBalances'])
        : null;
    verificationData = json['verificationData'] != null
        ? new VerificationData.fromJson(json['verificationData'])
        : null;
    pusherChannel = json['pusherChannel'];
    srn = json['srn'];
    callbackUrl = json['callbackUrl'];
    balances = json['balances'] != null
        ? new Balances.fromJson(json['balances'])
        : null;
    name = json['name'];
    id = json['id'];
    type = json['type'];

    int addressLength = depositAddresses.toJson().length;
    int balanceLength = availableBalances.toJson().length;
    var balanceCoinType, depositCoinType, coinName;
    CoinDetails coin;

// write a new logic
    // for (var i = 0; i < addressLength; i++) {
    //   if (balanceLength != 0) {
    //     for (var j = 0; j < balanceLength; j++) {
    //       balanceCoinType = availableBalances.availableBalancesList[j].coinType
    //           .toString()
    //           .toLowerCase();
    //       depositCoinType = depositAddresses
    //           .toJson()
    //           .keys
    //           .elementAt(i)
    //           .toString()
    //           .toLowerCase();

    //       Assets().cryptoCurrencies.forEach((key, value) {
    //         if (key == depositAddresses.toJson().keys.elementAt(i))
    //           coinName = value;
    //       });

    //       if (depositCoinType == balanceCoinType) {
    //         coin = CoinDetails(
    //             coinSymbol: depositCoinType,
    //             address: depositAddresses.toJson().values.elementAt(i),
    //             coinName: coinName,
    //             balance:
    //                 availableBalances.availableBalancesList[j].balances ?? 0.0);
    //       } else if (addressLength != balanceLength) {
    //         coin = CoinDetails(
    //             coinSymbol: depositCoinType,
    //             address: depositAddresses.toJson().values.elementAt(i),
    //             coinName: coinName,
    //             balance: 0.0);
    //       }
    //     }
    //   } else {
    //     depositCoinType = depositAddresses
    //         .toJson()
    //         .keys
    //         .elementAt(i)
    //         .toString()
    //         .toLowerCase();

    //     Assets().cryptoCurrencies.forEach((key, value) {
    //       if (key == depositAddresses.toJson().keys.elementAt(i))
    //         coinName = value;
    //     });

    //     coin = CoinDetails(
    //         coinSymbol: depositCoinType,
    //         address: depositAddresses.toJson().values.elementAt(i),
    //         coinName: coinName,
    //         balance: 0.0);
    //   }
    //   if (!coinDetailList.contains(coin)) coinDetailList.add(coin);
    // }

    Assets().cryptoCurrencies.forEach((key, value) {
      var depoAddress;
      if (key == "BTC") {
        depoAddress = depositAddresses.bTC;
      } else {
        depoAddress = depositAddresses.eTH;
      }
      coinDetailList.add(
        CoinDetails(
            coinSymbol: key,
            address: depoAddress,
            coinName: value,
            balance: availableBalances.availableBalancesList.singleWhere(
                    (element) => element.coinType == key, orElse: () {
                  return AvailableBalances(balances: 0.0, coinType: key);
                }).balances ??
                0.0),
      );
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pendingInterestBalances != null) {
      data['pendingInterestBalances'] = this.pendingInterestBalances.toJson();
    }
    if (this.savingRates != null) {
      data['savingRates'] = this.savingRates.toJson();
    }
    data['status'] = this.status;
    data['notes'] = this.notes;
    if (this.depositAddresses != null) {
      data['depositAddresses'] = this.depositAddresses.toJson();
    }
    if (this.totalBalances != null) {
      data['totalBalances'] = this.totalBalances.toJson();
    }
    if (this.availableBalances != null) {
      data['availableBalances'] = this.availableBalances.toJson();
    }
    if (this.verificationData != null) {
      data['verificationData'] = this.verificationData.toJson();
    }
    data['pusherChannel'] = this.pusherChannel;
    data['srn'] = this.srn;
    data['callbackUrl'] = this.callbackUrl;
    if (this.balances != null) {
      data['balances'] = this.balances.toJson();
    }
    data['name'] = this.name;
    data['id'] = this.id;
    data['type'] = this.type;
    return data;
  }
}

class CoinDetails {
  String coinName;
  String coinSymbol;
  String address;
  var balance;

  CoinDetails({this.coinName, this.coinSymbol, this.address, this.balance});
}

class PendingInterestBalances {
  double dAI;
  double eTH;
  double bTC;
  double uSDC;

  PendingInterestBalances({this.dAI, this.eTH, this.bTC, this.uSDC});

  PendingInterestBalances.fromJson(Map<String, dynamic> json) {
    dAI = double.tryParse(json['DAI'].toString());
    eTH = double.tryParse(json['ETH'].toString());
    bTC = double.tryParse(json['BTC'].toString());
    uSDC = double.tryParse(json['USDC'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DAI'] = this.dAI;
    data['ETH'] = this.eTH;
    data['BTC'] = this.bTC;
    data['USDC'] = this.uSDC;
    return data;
  }
}

class DepositAddresses {
  String eTH;
  String bTC;

  DepositAddresses({this.eTH, this.bTC});

  DepositAddresses.fromJson(Map<String, dynamic> json) {
    eTH = json['ETH'];
    bTC = json['BTC'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ETH'] = this.eTH;
    data['BTC'] = this.bTC;
    return data;
  }
}

class TotalBalances {
  String coinType;
  var balances;
  List<TotalBalances> totalBalancesList = [];

  TotalBalances({this.coinType, this.balances});

  TotalBalances.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      totalBalancesList.add(TotalBalances(coinType: key, balances: value));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    totalBalancesList.forEach((element) {
      data[element.coinType] = element.balances;
    });
    return data;
  }
}

class Balances {
  String coinType;
  var balances;
  List<Balances> balancesList = [];

  Balances({this.coinType, this.balances});

  Balances.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      balancesList.add(Balances(coinType: key, balances: value));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    balancesList.forEach((element) {
      data[element.coinType] = element.balances;
    });
    return data;
  }
}

class AvailableBalances {
  String coinType;
  var balances;
  List<AvailableBalances> availableBalancesList = [];

  AvailableBalances({this.coinType, this.balances});

  AvailableBalances.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      availableBalancesList
          .add(AvailableBalances(coinType: key, balances: value));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    availableBalancesList.forEach((element) {
      data[element.coinType] = element.balances;
    });
    return data;
  }
}

class VerificationData {
  String firstName;
  String middleName;
  String lastName;
  String ssn;
  String passport;
  Null sourceOfFunds;
  String birthDay;
  String birthMonth;
  String birthYear;
  String dateOfBirth;
  Address address;
  String phoneNumber;
  String fullName;
  String beneficialOwners;

  VerificationData(
      {this.firstName,
      this.middleName,
      this.lastName,
      this.ssn,
      this.passport,
      this.sourceOfFunds,
      this.birthDay,
      this.birthMonth,
      this.birthYear,
      this.dateOfBirth,
      this.address,
      this.phoneNumber,
      this.fullName,
      this.beneficialOwners});

  VerificationData.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    ssn = json['ssn'];
    passport = json['passport'];
    sourceOfFunds = json['sourceOfFunds'];
    birthDay = json['birthDay'];
    birthMonth = json['birthMonth'];
    birthYear = json['birthYear'];
    dateOfBirth = json['dateOfBirth'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    phoneNumber = json['phoneNumber'];
    fullName = json['fullName'];
    beneficialOwners = json['beneficialOwners'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['middleName'] = this.middleName;
    data['lastName'] = this.lastName;
    data['ssn'] = this.ssn;
    data['passport'] = this.passport;
    data['sourceOfFunds'] = this.sourceOfFunds;
    data['birthDay'] = this.birthDay;
    data['birthMonth'] = this.birthMonth;
    data['birthYear'] = this.birthYear;
    data['dateOfBirth'] = this.dateOfBirth;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    data['phoneNumber'] = this.phoneNumber;
    data['fullName'] = this.fullName;
    data['beneficialOwners'] = this.beneficialOwners;
    return data;
  }
}

class Address {
  String street1;
  String street2;
  String city;
  String state;
  String postalCode;
  String country;

  Address(
      {this.street1,
      this.street2,
      this.city,
      this.state,
      this.postalCode,
      this.country});

  Address.fromJson(Map<String, dynamic> json) {
    street1 = json['street1'];
    street2 = json['street2'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postalCode'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['street1'] = this.street1;
    data['street2'] = this.street2;
    data['city'] = this.city;
    data['state'] = this.state;
    data['postalCode'] = this.postalCode;
    data['country'] = this.country;
    return data;
  }
}
