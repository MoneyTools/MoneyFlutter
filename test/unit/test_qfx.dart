import 'package:flutter_test/flutter_test.dart';
import 'package:money/helpers.dart';
import 'package:money/models/import_qfx.dart';

void main() {
  group('QFX:', () {
    test('Read', () {
      final String qfxString = getQfxSample();

      final String ofxString = getStringBetweenTwoTokens(qfxString, '<OFX>', '</OFX>');
      expect(ofxString.isEmpty, false);

      final List<QFXTransaction> list = getTransactionFromOFX(ofxString);
      expect(list.length, 2);

      expect(list[0].type, 'CREDIT');
      expect(list[0].amount, 2.09);

      expect(list[1].type, 'DEBIT');
      expect(list[1].amount, -2373.71);
    });
  });
}

String getQfxSample() {
  return '''
OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE

<OFX>

<SIGNONMSGSRSV1>
<SONRS>
<STATUS>
<CODE>0
<SEVERITY>INFO
</STATUS>
<DTSERVER>20231230224748.000[0:UTC]
<LANGUAGE>ENG
<DTACCTUP>20231230224748.000[0:UTC]
<FI>
<ORG>Bank of America
<FID>5959
</FI>
<INTU.BID>6526
<INTU.USERID>jpnancy
</SONRS>
</SIGNONMSGSRSV1>
<BANKMSGSRSV1>
<STMTTRNRS>
<TRNUID>0

<STATUS>
<CODE>0
<SEVERITY>INFO
</STATUS>

<STMTRS>
<CURDEF>USD

<BANKACCTFROM>
  <BANKID>125000024
  <ACCTID>000091590869
  <ACCTTYPE>CHECKING
</BANKACCTFROM>

<BANKTRANLIST>

  <DTSTART>2000000000000  
  <DTEND>2333333333333

  <STMTTRN>
    <TRNTYPE>CREDIT
    <DTPOSTED>20231229120000
    <TRNAMT>2.09
    <FITID>129484.610231229129484.61
    <NAME>Interest Earned
  </STMTTRN>

  <STMTTRN>
    <TRNTYPE>DEBIT
    <DTPOSTED>20231228120000
    <TRNAMT>-2373.71
    <FITID>129482.520231228129482.52
    <NAME>CreditCard AUTOPAY
  </STMTTRN>

</BANKTRANLIST>

<LEDGERBAL>
<BALAMT>129484.61
<DTASOF>20231230224748
</LEDGERBAL>
</STMTRS>
</STMTTRNRS>
</BANKMSGSRSV1>

</OFX>
''';
}
