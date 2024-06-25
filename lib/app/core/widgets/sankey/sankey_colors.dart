import 'dart:ui';

class SankeyColors {

  SankeyColors({required bool darkTheme}) {
    if (darkTheme) {
      textColor = const Color(0xffffffff);

      colorIncome = const Color(0xff4b6735);
      colorExpense = const Color(0xff813e3e);
      colorNet = const Color(0xff214f72);
    }
  }
  // default light theme color
  Color textColor = const Color(0xff000000);

  Color colorIncome = const Color(0xff8ba16a);
  Color colorExpense = const Color(0xffC08282);
  Color colorNet = const Color(0xff869AAD);
}
