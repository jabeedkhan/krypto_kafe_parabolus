class HttpUrl {
  static const String BASE_URL =
      "http://kryptokafe.com/newapi/index.php/api/v1/";

  static const String LOGIN = BASE_URL + "user/mainLogin";
  static const String REGESTRATION = BASE_URL + "user/userRegistration";
  static const String FORGOT_PASSWORD = BASE_URL + 'user/forgotPassword';
  static const String USER_STATUS = BASE_URL + "user/userStatus";
  static const String CREATE_WALLET = BASE_URL + "user/createUserWallet";
  static const String WDATA = BASE_URL + "common/getWvalues";
  static const String APP_UPDATE = BASE_URL + "common/appUpdate";
  static const String LOOKUP_WALLET = BASE_URL + "user/getWalletDetails";
  static const String CHECKOUT = BASE_URL + "user/purchaseCoin";
}
