import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/currency_label.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/storage/data/data.dart';

/*
  cid  name         type          notnull  default  pk
  ---  -----------  ------------  -------  -------  --
  0    Id           INT           0                 1 
  1    Symbol       nchar(20)     1                 0 
  2    Name         nvarchar(80)  1                 0 
  3    Ratio        money         0                 0 
  4    LastRatio    money         0                 0 
  5    CultureCode  nvarchar(80)  0                 0 
 */
class Currency extends MoneyObject {
  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    return name.value;
  }

  // 0
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => instance.uniqueId,
  );

  /// 1
  /// 1    Symbol       nchar(20)     1                 0
  FieldString symbol = FieldString(
    importance: 1,
    name: 'Symbol',
    serializeName: 'Symbol',
    getValueForDisplay: (final MoneyObject instance) => (instance as Currency).symbol.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Currency).symbol.value,
  );

  /// 2
  /// 2    name       nchar(20)     1                 0
  FieldString name = FieldString(
    importance: 2,
    name: 'Name',
    serializeName: 'Name',
    getValueForDisplay: (final MoneyObject instance) => (instance as Currency).name.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Currency).name.value,
  );

  /// 3
  /// 3    Ratio        money         0                 0
  FieldDouble ratio = FieldDouble(
    importance: 3,
    name: 'Ratio',
    serializeName: 'Ratio',
    getValueForDisplay: (final MoneyObject instance) => (instance as Currency).ratio.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Currency).ratio.value,
  );

  // 4
  FieldDouble lastRatio = FieldDouble(
    importance: 4,
    name: 'LastRatio',
    serializeName: 'LastRatio',
    getValueForDisplay: (final MoneyObject instance) => (instance as Currency).lastRatio.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Currency).lastRatio.value,
  );

  /// 5
  /// 5    CultureCode  nvarchar(80)  0                 0
  FieldString cultureCode = FieldString(
    name: 'Culture Code',
    serializeName: 'CultureCode',
    getValueForDisplay: (final MoneyObject instance) => (instance as Currency).cultureCode.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Currency).cultureCode.value,
  );

  Currency({
    required final int id, // 0
    required final String symbol, // 1
    required final String name, // 2
    required final double ratio, // 3
    required final String cultureCode, // 4
    required final double lastRatio, // 5
  }) {
    this.id.value = id;
    this.name.value = name;
    this.symbol.value = symbol;
    this.ratio.value = ratio;
    this.cultureCode.value = cultureCode;
    this.lastRatio.value = lastRatio;
  }

  /// Constructor from a SQLite row
  factory Currency.fromJson(final MyJson row) {
    return Currency(
      // 0
      id: row.getInt('Id', -1),
      // 1
      symbol: row.getString('Symbol'),
      // 2
      name: row.getString('Name'),
      // 3
      ratio: row.getDouble('Ratio'),
      // 4
      lastRatio: row.getDouble('LastRatio'),
      // 5
      cultureCode: row.getString('CultureCode'),
    );
  }

  static String getCurrencyAsText(final String threeLetterCurrencySymbol) {
    if (threeLetterCurrencySymbol.isEmpty) {
      return Constants.defaultCurrency;
    }
    return threeLetterCurrencySymbol;
  }

  static Widget buildCurrencyWidget(String threeLetterCurrencySymbol) {
    String locale = Data().currencies.fromSymbolToCountryAlpha2(threeLetterCurrencySymbol);

    return CurrencyLabel(
      threeLetterCurrencySymbol: getCurrencyAsText(threeLetterCurrencySymbol),
      flagId: getCountryFromLocale(locale).toLowerCase(),
    );
  }

  /// Convert from ISO 4217 to a locale
  static String? getLocaleFromCurrencyIso4217(String iso4217code) {
    // Map currency codes to their respective locales
    const currencyLocales = {
      'AED': 'ar_AE',
      'AFN': 'ps_AF',
      'ALL': 'sq_AL',
      'AMD': 'hy_AM',
      'ANG': 'nl_AN',
      'AOA': 'pt_AO',
      'ARS': 'es_AR',
      'AUD': 'en_AU',
      'AWG': 'nl_AW',
      'AZN': 'az_AZ',
      'BAM': 'bs_BA',
      'BBD': 'en_BB',
      'BDT': 'bn_BD',
      'BGN': 'bg_BG',
      'BHD': 'ar_BH',
      'BIF': 'fr_BI',
      'BMD': 'en_BM',
      'BND': 'ms_BN',
      'BOB': 'es_BO',
      'BOV': 'es_BO',
      'BRL': 'pt_BR',
      'BSD': 'en_BS',
      'BTN': '', // dz_BT is not yet supported in dart-intl
      'BWP': 'en_BW',
      'BYN': 'be_BY',
      'BYR': 'be_BY',
      'BZD': 'en_BZ',
      'CAD': 'en_CA',
      'CDF': 'fr_CD',
      'CHE': 'de_CH',
      'CHF': 'de_CH',
      'CHW': 'fr_CH',
      'CLF': '', // This is not a real physical currency
      'CLP': 'es_CL',
      'CNY': 'zh_CN',
      'COP': 'es_CO',
      'COU': '', // This is not a real physical currency
      'CRC': 'es_CR',
      'CUC': 'es_CU',
      'CUP': 'es_CU',
      'CVE': 'pt_CV',
      'CZK': 'cs_CZ',
      'DJF': 'fr_DJ',
      'DKK': 'da_DK',
      'DOP': 'es_DO',
      'DZD': 'ar_DZ',
      'EGP': 'ar_EG',
      'ERN': '', // ti_ER is not yet supported in dart-intl
      'ETB': 'am_ET',
      'EUR': 'de_DE',
      'FJD': 'en_FJ',
      'FKP': 'en_FK',
      'GBP': 'en_GB',
      'GEL': 'ka_GE',
      'GHS': 'en_GH',
      'GIP': 'en_GI',
      'GMD': 'en_GM',
      'GNF': 'fr_GN',
      'GTQ': 'es_GT',
      'GYD': 'en_GY',
      'HKD': 'zh_HK',
      'HNL': 'es_HN',
      'HRK': 'hr_HR',
      'HTG': 'fr_HT',
      'HUF': 'hu_HU',
      'IDR': 'id_ID',
      'ILS': 'he_IL',
      'INR': 'en_IN',
      'IQD': 'ar_IQ',
      'IRR': 'fa_IR',
      'ISK': 'is_IS',
      'JMD': 'en_JM',
      'JOD': 'ar_JO',
      'JPY': 'ja_JP',
      'KES': 'sw_KE',
      'KGS': 'ky_KG',
      'KHR': 'km_KH',
      'KID': 'en_KI',
      'KMF': 'fr_KM',
      'KPW': 'ko_KP',
      'KRW': 'ko_KR',
      'KWD': 'ar_KW',
      'KYD': 'en_KY',
      'KZT': 'kk_KZ',
      'LAK': 'lo_LA',
      'LBP': 'ar_LB',
      'LKR': 'si_LK',
      'LRD': 'en_LR',
      'LSL': 'en_LS',
      'LYD': 'ar_LY',
      'MAD': 'ar_MA',
      'MDL': 'ro_MD',
      'MGA': 'mg_MG',
      'MKD': 'mk_MK',
      'MMK': 'my_MM',
      'MNT': 'mn_MN',
      'MOP': 'zh_MO',
      'MRO': 'ar_MR',
      'MRU': 'ar_MR',
      'MUR': 'en_MU',
      'MVR': '', // dv_MV is not yet supported in dart-intl
      'MWK': 'en_MW',
      'MXN': 'es_MX',
      'MXV': '', // This is not a real physical currency
      'MYR': 'ms_MY',
      'MZN': 'pt_MZ',
      'NAD': 'en_NA',
      'NGN': 'en_NG',
      'NIO': 'es_NI',
      'NOK': 'nb_NO',
      'NPR': 'ne_NP',
      'NZD': 'en_NZ',
      'OMR': 'ar_OM',
      'PAB': 'es_PA',
      'PEN': 'es_PE',
      'PGK': 'en_PG',
      'PHP': 'en_PH',
      'PKR': 'en_PK',
      'PLN': 'pl_PL',
      'PYG': 'es_PY',
      'QAR': 'ar_QA',
      'RON': 'ro_RO',
      'RSD': 'sr_RS',
      'RUB': 'ru_RU',
      'RWF': 'en_RW',
      'SAR': 'ar_SA',
      'SBD': 'en_SB',
      'SCR': 'en_SC',
      'SDG': 'ar_SD',
      'SEK': 'sv_SE',
      'SGD': 'en_SG',
      'SHP': 'en_SH',
      'SLL': 'en_SL',
      'SOS': '', // so_SO is not yet supported in dart-intl
      'SRD': 'nl_SR',
      'SSP': 'en_SS',
      'STD': 'pt_ST',
      'STN': 'pt_ST',
      'SVC': 'es_SV',
      'SYP': 'ar_SY',
      'SZL': 'en_SZ',
      'THB': 'th_TH',
      'TJS': 'en_TJ',
      'TMT': 'en_TM',
      'TND': 'ar_TN',
      'TOP': 'en_TO',
      'TRY': 'tr_TR',
      'TTD': 'en_TT',
      'TWD': 'zh_TW',
      'TZS': 'sw_TZ',
      'UAH': 'uk_UA',
      'UGX': 'sw_UG',
      'USD': 'en_US',
      'USN': 'en_US',
      'UYI': '', // This is not a real physical currency
      'UYU': 'es_UY',
      'UZS': 'uz_UZ',
      'VEF': 'es_VE',
      'VES': 'es_VE',
      'VND': 'vi_VN',
      'VUV': 'en_VU',
      'WST': '', // sm_WS is not yet supported in dart-intl
      'XAF': 'fr_XF',
      'XCD': 'en_XC',
      'XOF': 'fr_XO',
      'XPF': 'fr_XP',
      'YER': 'ar_YE',
      'ZAR': 'en_ZA',
      'ZMW': 'en_ZM',
      'ZWL': 'en_ZW',
    };

    // Default to 'en_US' if the currency code is not found
    return currencyLocales[iso4217code];
  }

  // Define a function to get the currency symbol from ISO 4217 code
  static String getCurrencySymbol(String isoCode) {
    // Create a NumberFormat instance with the currency name and locale
    var format = NumberFormat.simpleCurrency(name: isoCode);
    // Return the currency symbol
    return format.currencySymbol;
  }

  /// Return a formatted string from the given amount using the supplied ISO4217 code
  static String getAmountAsStringUsingCurrency(
    dynamic amount, {
    String iso4217code = Constants.defaultCurrency,
    int? decimalDigits,
  }) {
    if (amount is String) {
      return amount; // its already a string
    }
    // determining the locale to be used when formatting the currency amount
    String localeToUse = iso4217code == Constants.defaultCurrency || iso4217code.isEmpty
        ? 'en_US'
        : Currency.getLocaleFromCurrencyIso4217(iso4217code) ?? 'en_US';

    final currencyFormat = NumberFormat.simpleCurrency(
      locale: localeToUse,
      name: iso4217code,
      decimalDigits: decimalDigits,
    );
    return currencyFormat.format(isAlmostZero(amount) ? 0.00 : amount);
  }

  /// Return a formatted string from the given amount using the supplied ISO4217 code
  static String getAmountAsShortHandStringUsingCurrency(
    dynamic amount, {
    String iso4217code = Constants.defaultCurrency,
  }) {
    if (amount is String) {
      return amount; // its already a string
    }

    return getAmountAsShorthandText(amount, symbol: getCurrencySymbol(iso4217code));
  }
}
