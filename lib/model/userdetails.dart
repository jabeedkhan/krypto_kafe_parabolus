import 'package:kryptokafe/wyre/wyre_keynames.dart';

class UserDetails {
  String id;
  String status;
  String type;
  String country;
  int createdAt;
  DepositAddresses depositAddresses;
  TotalBalances totalBalances;
  TotalBalances availableBalances;
  List<ProfileData> profileFields;

  UserDetails(
      {this.id,
      this.status,
      this.type,
      this.country,
      this.createdAt,
      this.depositAddresses,
      this.totalBalances,
      this.availableBalances,
      this.profileFields});

  UserDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    type = json['type'];
    country = json['country'];
    createdAt = json['createdAt'];
    depositAddresses = json['depositAddresses'] != null
        ? new DepositAddresses.fromJson(json['depositAddresses'])
        : null;
    totalBalances = json['totalBalances'] != null
        ? new TotalBalances.fromJson(json['totalBalances'])
        : null;
    availableBalances = json['availableBalances'] != null
        ? new TotalBalances.fromJson(json['availableBalances'])
        : null;
    if (json['profileFields'] != null) {
      profileFields = new List<ProfileData>();
      json['profileFields'].forEach((v) {
        profileFields.add(new ProfileData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['type'] = this.type;
    data['country'] = this.country;
    data['createdAt'] = this.createdAt;
    if (this.depositAddresses != null) {
      data['depositAddresses'] = this.depositAddresses.toJson();
    }
    if (this.totalBalances != null) {
      data['totalBalances'] = this.totalBalances.toJson();
    }
    if (this.availableBalances != null) {
      data['availableBalances'] = this.availableBalances.toJson();
    }
    if (this.profileFields != null) {
      data['profileFields'] =
          this.profileFields.map((v) => v.toJson()).toList();
    }
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
  int bTC;
  double eTH;

  TotalBalances({this.bTC, this.eTH});

  TotalBalances.fromJson(Map<String, dynamic> json) {
    bTC = json['BTC'];
    eTH = json['ETH'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BTC'] = this.bTC;
    data['ETH'] = this.eTH;
    return data;
  }
}

class ProfileData {
  String fieldId;
  String fieldType;
  dynamic value;
  String note;
  String status;

  ProfileData(
      {this.fieldId, this.fieldType, this.value, this.note, this.status});

  ProfileData.fromJson(Map<String, dynamic> json) {
    fieldId = json['fieldId'];
    fieldType = json['fieldType'];
    // value = json['value'];
    note = json['note'];
    status = json['status'];

    if (fieldId == WyreKey.fieldResAddress) {
      if (json['value'] != null) {
        value = new Value.fromJson(json['value']);
      }
    } else {
      value = json['value'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fieldId'] = this.fieldId;
    data['fieldType'] = this.fieldType;
    // data['value'] = this.value;
    data['note'] = this.note;
    data['status'] = this.status;
    if (this.fieldId == WyreKey.fieldResAddress) {
      if (this.value != null) {
        //  this.value = Value();
        data['value'] = this.value.toJson();
      }
    } else {
      data['value'] = this.value;
    }
    return data;
  }
}

class Value {
  String street1;
  String street2;
  String city;
  String state;
  String postalCode;
  String country;

  Value(
      {this.street1,
      this.street2,
      this.city,
      this.state,
      this.postalCode,
      this.country});

  Value.fromJson(Map<String, dynamic> json) {
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

// class UserDetails {
//   String id;
//   String status;
//   String type;
//   String country;
//   int createdAt;
//   DepositAddresses depositAddresses;
//   TotalBalances totalBalances;
//   TotalBalances availableBalances;
//   List<ProfileFields> profileFields;

//   UserDetails(
//       {this.id,
//       this.status,
//       this.type,
//       this.country,
//       this.createdAt,
//       this.depositAddresses,
//       this.totalBalances,
//       this.availableBalances,
//       this.profileFields});

//   UserDetails.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     status = json['status'];
//     type = json['type'];
//     country = json['country'];
//     createdAt = json['createdAt'];
//     depositAddresses = json['depositAddresses'] != null
//         ? new DepositAddresses.fromJson(json['depositAddresses'])
//         : null;
//     totalBalances = json['totalBalances'] != null
//         ? new TotalBalances.fromJson(json['totalBalances'])
//         : null;
//     availableBalances = json['availableBalances'] != null
//         ? new TotalBalances.fromJson(json['availableBalances'])
//         : null;
//     if (json['profileFields'] != null) {
//       profileFields = new List<ProfileFields>();
//       json['profileFields'].forEach((v) {
//         profileFields.add(new ProfileFields.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['status'] = this.status;
//     data['type'] = this.type;
//     data['country'] = this.country;
//     data['createdAt'] = this.createdAt;
//     if (this.depositAddresses != null) {
//       data['depositAddresses'] = this.depositAddresses.toJson();
//     }
//     if (this.totalBalances != null) {
//       data['totalBalances'] = this.totalBalances.toJson();
//     }
//     if (this.availableBalances != null) {
//       data['availableBalances'] = this.availableBalances.toJson();
//     }
//     if (this.profileFields != null) {
//       data['profileFields'] = this.profileFields.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class DepositAddresses {
//   String eTH;
//   String bTC;

//   DepositAddresses({this.eTH, this.bTC});

//   DepositAddresses.fromJson(Map<String, dynamic> json) {
//     eTH = json['ETH'];
//     bTC = json['BTC'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['ETH'] = this.eTH;
//     data['BTC'] = this.bTC;
//     return data;
//   }
// }

// class TotalBalances {
//   int bTC;
//   double eTH;

//   TotalBalances({this.bTC, this.eTH});

//   TotalBalances.fromJson(Map<String, dynamic> json) {
//     bTC = json['BTC'];
//     eTH = json['ETH'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['BTC'] = this.bTC;
//     data['ETH'] = this.eTH;
//     return data;
//   }
// }

// class ProfileFields {
//   String fieldId;
//   String fieldType;
//   dynamic value;
//   String note;
//   String status;

//   ProfileFields(
//       {this.fieldId, this.fieldType, this.value, this.note, this.status});

//   ProfileFields.fromJson(Map<String, dynamic> json) {
//     fieldId = json['fieldId'];
//     fieldType = json['fieldType'];

//     note = json['note'];
//     status = json['status'];

//     if (fieldId == WyreKey.fieldResAddress) {
//       value = json['value'] != null ? new Value.fromJson(json['value']) : null;
//     }
// else    {
//    value = json['value'];
// }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['fieldId'] = this.fieldId;
//     data['fieldType'] = this.fieldType;
//     if (this.value != null) {
//       data['value'] = this.value.toJson();
//     }
//     data['note'] = this.note;
//     data['status'] = this.status;
//     return data;
//   }
// }

// class Value {
//   String street1;
//   String street2;
//   String city;
//   String state;
//   String postalCode;
//   String country;

//   Value(
//       {this.street1,
//       this.street2,
//       this.city,
//       this.state,
//       this.postalCode,
//       this.country});

//   Value.fromJson(Map<String, dynamic> json) {
//     street1 = json['street1'];
//     street2 = json['street2'];
//     city = json['city'];
//     state = json['state'];
//     postalCode = json['postalCode'];
//     country = json['country'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['street1'] = this.street1;
//     data['street2'] = this.street2;
//     data['city'] = this.city;
//     data['state'] = this.state;
//     data['postalCode'] = this.postalCode;
//     data['country'] = this.country;
//     return data;
//   }
// }
