class ApiClient {
  final String baseUrl = "api.coincap.io";
  final String baseUrlWithSlash = "https://api.coincap.io/";

  getBaseUrl() {
    return baseUrl;
  }

  getBaseUrlWithSlash() {
    return baseUrlWithSlash;
  }

  getAssetIconURL(symbolName) {
    return "https://static.coincap.io/assets/icons/" +
            symbolName.toString().toLowerCase() +
            "@2x.png" ??
        "https://coincap.io/static/logo_mark.png";
  }
}
