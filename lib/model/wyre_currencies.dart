class WyreCurrencyPair {
  List<String> cLP;
  List<String> uSD;
  List<String> sEK;
  List<String> pLN;
  List<String> gBP;
  List<String> uSDT;
  List<String> yFI;
  List<String> bRL;
  List<String> aRS;
  List<String> hUSD;
  List<String> cOMP;
  List<String> jPY;
  List<String> tHB;
  List<String> iLS;
  List<String> iNR;
  List<String> mKR;
  List<String> dAI;
  List<String> cHF;
  List<String> sGD;
  List<String> cRV;
  List<String> kRW;
  List<String> uSDC;
  List<String> cOP;
  List<String> uMA;
  List<String> zAR;
  List<String> pAX;
  List<String> nOK;
  List<String> aAVE;
  List<String> bUSD;
  List<String> gUSD;
  List<String> hKD;
  List<String> sNX;
  List<String> aUD;
  List<String> cZK;
  List<String> vND;
  List<String> cAD;
  List<String> mXN;
  List<String> pHP;
  List<String> uSDS;
  List<String> wBTC;
  List<String> eUR;
  List<String> bTC;
  List<String> tRY;
  List<String> eTH;
  List<String> lINK;
  List<String> mYR;
  List<String> uNI;
  List<String> nZD;
  List<String> bAT;
  List<String> iSK;
  List<String> dKK;

  WyreCurrencyPair(
      {this.cLP,
      this.uSD,
      this.sEK,
      this.pLN,
      this.gBP,
      this.uSDT,
      this.yFI,
      this.bRL,
      this.aRS,
      this.hUSD,
      this.cOMP,
      this.jPY,
      this.tHB,
      this.iLS,
      this.iNR,
      this.mKR,
      this.dAI,
      this.cHF,
      this.sGD,
      this.cRV,
      this.kRW,
      this.uSDC,
      this.cOP,
      this.uMA,
      this.zAR,
      this.pAX,
      this.nOK,
      this.aAVE,
      this.bUSD,
      this.gUSD,
      this.hKD,
      this.sNX,
      this.aUD,
      this.cZK,
      this.vND,
      this.cAD,
      this.mXN,
      this.pHP,
      this.uSDS,
      this.wBTC,
      this.eUR,
      this.bTC,
      this.tRY,
      this.eTH,
      this.lINK,
      this.mYR,
      this.uNI,
      this.nZD,
      this.bAT,
      this.iSK,
      this.dKK});

  WyreCurrencyPair.fromJson(Map<String, dynamic> json) {
    cLP = json['CLP'].cast<String>();
    uSD = json['USD'].cast<String>();
    sEK = json['SEK'].cast<String>();
    pLN = json['PLN'].cast<String>();
    gBP = json['GBP'].cast<String>();
    uSDT = json['USDT'].cast<String>();
    yFI = json['YFI'].cast<String>();
    bRL = json['BRL'].cast<String>();
    aRS = json['ARS'].cast<String>();
    hUSD = json['HUSD'].cast<String>();
    cOMP = json['COMP'].cast<String>();
    jPY = json['JPY'].cast<String>();
    tHB = json['THB'].cast<String>();
    iLS = json['ILS'].cast<String>();
    iNR = json['INR'].cast<String>();
    mKR = json['MKR'].cast<String>();
    dAI = json['DAI'].cast<String>();
    cHF = json['CHF'].cast<String>();
    sGD = json['SGD'].cast<String>();
    cRV = json['CRV'].cast<String>();
    kRW = json['KRW'].cast<String>();
    uSDC = json['USDC'].cast<String>();
    cOP = json['COP'].cast<String>();
    uMA = json['UMA'].cast<String>();
    zAR = json['ZAR'].cast<String>();
    pAX = json['PAX'].cast<String>();
    nOK = json['NOK'].cast<String>();
    aAVE = json['AAVE'].cast<String>();
    bUSD = json['BUSD'].cast<String>();
    gUSD = json['GUSD'].cast<String>();
    hKD = json['HKD'].cast<String>();
    sNX = json['SNX'].cast<String>();
    aUD = json['AUD'].cast<String>();
    cZK = json['CZK'].cast<String>();
    vND = json['VND'].cast<String>();
    cAD = json['CAD'].cast<String>();
    mXN = json['MXN'].cast<String>();
    pHP = json['PHP'].cast<String>();
    uSDS = json['USDS'].cast<String>();
    wBTC = json['WBTC'].cast<String>();
    eUR = json['EUR'].cast<String>();
    bTC = json['BTC'].cast<String>();
    tRY = json['TRY'].cast<String>();
    eTH = json['ETH'].cast<String>();
    lINK = json['LINK'].cast<String>();
    mYR = json['MYR'].cast<String>();
    uNI = json['UNI'].cast<String>();
    nZD = json['NZD'].cast<String>();
    bAT = json['BAT'].cast<String>();
    iSK = json['ISK'].cast<String>();
    dKK = json['DKK'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CLP'] = this.cLP;
    data['USD'] = this.uSD;
    data['SEK'] = this.sEK;
    data['PLN'] = this.pLN;
    data['GBP'] = this.gBP;
    data['USDT'] = this.uSDT;
    data['YFI'] = this.yFI;
    data['BRL'] = this.bRL;
    data['ARS'] = this.aRS;
    data['HUSD'] = this.hUSD;
    data['COMP'] = this.cOMP;
    data['JPY'] = this.jPY;
    data['THB'] = this.tHB;
    data['ILS'] = this.iLS;
    data['INR'] = this.iNR;
    data['MKR'] = this.mKR;
    data['DAI'] = this.dAI;
    data['CHF'] = this.cHF;
    data['SGD'] = this.sGD;
    data['CRV'] = this.cRV;
    data['KRW'] = this.kRW;
    data['USDC'] = this.uSDC;
    data['COP'] = this.cOP;
    data['UMA'] = this.uMA;
    data['ZAR'] = this.zAR;
    data['PAX'] = this.pAX;
    data['NOK'] = this.nOK;
    data['AAVE'] = this.aAVE;
    data['BUSD'] = this.bUSD;
    data['GUSD'] = this.gUSD;
    data['HKD'] = this.hKD;
    data['SNX'] = this.sNX;
    data['AUD'] = this.aUD;
    data['CZK'] = this.cZK;
    data['VND'] = this.vND;
    data['CAD'] = this.cAD;
    data['MXN'] = this.mXN;
    data['PHP'] = this.pHP;
    data['USDS'] = this.uSDS;
    data['WBTC'] = this.wBTC;
    data['EUR'] = this.eUR;
    data['BTC'] = this.bTC;
    data['TRY'] = this.tRY;
    data['ETH'] = this.eTH;
    data['LINK'] = this.lINK;
    data['MYR'] = this.mYR;
    data['UNI'] = this.uNI;
    data['NZD'] = this.nZD;
    data['BAT'] = this.bAT;
    data['ISK'] = this.iSK;
    data['DKK'] = this.dKK;
    return data;
  }
}
