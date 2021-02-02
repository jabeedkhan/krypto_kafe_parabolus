class WyreCurrencies {
  List<String> currency;

  WyreCurrencies({this.currency});

  WyreCurrencies.fromJson(Map<String, dynamic> json) {
    currency = json['USD'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['USD'] = this.currency;
    return data;
  }
}
