class UserData {
  bool error;
  String messgae;
  Data data;

  UserData({this.error, this.messgae, this.data});

  UserData.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    messgae = json['messgae'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['messgae'] = this.messgae;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  var id;
  String userName;
  String userEmail;
  int userDialCode;
  String userCountryName;
  String userCountryCode;
  String userCurrencyCode;
  String uniqueString;
  int walletStatus;
  String walletId;

  Data(
      {this.id,
      this.userName,
      this.userEmail,
      this.userDialCode,
      this.userCountryName,
      this.userCountryCode,
      this.userCurrencyCode,
      this.uniqueString,
      this.walletStatus,
      this.walletId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    userDialCode = json['user_country_calling_code'];
    userCountryName = json['user_country_name'];
    userCountryCode = json['user_country_code'];
    userCurrencyCode = json['currencyCode'];
    uniqueString = json['unique_string'];
    walletStatus = json['wallet_status'];
    walletId = json['wallet_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_name'] = this.userName;
    data['user_email'] = this.userEmail;
    data['user_country_calling_code'] = this.userDialCode;
    data['user_country_name'] = this.userCountryName;
    data['user_country_code'] = this.userCountryCode;
    data['currencyCode'] = this.userCurrencyCode;
    data['unique_string'] = this.uniqueString;
    data['wallet_status'] = this.walletStatus;
    data['wallet_id'] = this.walletId;
    return data;
  }
  
}


