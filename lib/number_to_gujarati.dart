// lib/number_to_gujarati.dart

Map<int, String> gujaratiUnitsMap = {
  0: 'શૂન્ય',
  1: 'એક',
  2: 'બે',
  3: 'ત્રણ',
  4: 'ચાર',
  5: 'પાંચ',
  6: 'છ',
  7: 'સાત',
  8: 'આઠ',
  9: 'નવ',
  10: 'દસ',
  11: 'અગિયાર',
  12: 'બાર',
  13: 'તેર',
  14: 'ચૌદ',
  15: 'પંદર',
  16: 'સોળ',
  17: 'સત્તર',
  18: 'અઢાર',
  19: 'ઓગણીસ',
  20: 'વીસ',
  30: 'ત્રીસ',
  40: 'ચાળીશ',
  50: 'પંચાશ',
  60: 'સાઠ',
  70: 'સિત્તેર',
  80: 'એંસી',
  90: 'નેવું'
};

Map<int, String> gujaratiPlaceValueMap = {
  100: 'સો',
  1000: 'હજાર',
  100000: 'લાખ',
  10000000: 'કરોડ'
};

String numberToGujaratiWords(int number) {
  if (number == 0) return gujaratiUnitsMap[0]!;

  String result = '';

  if (number >= 10000000) {
    // Crores
    result += numberToGujaratiWords(number ~/ 10000000) +
        ' ' +
        gujaratiPlaceValueMap[10000000]! +
        ' ';
    number %= 10000000;
  }

  if (number >= 100000) {
    // Lakhs
    result += numberToGujaratiWords(number ~/ 100000) +
        ' ' +
        gujaratiPlaceValueMap[100000]! +
        ' ';
    number %= 100000;
  }

  if (number >= 1000) {
    // Thousands
    result += numberToGujaratiWords(number ~/ 1000) +
        ' ' +
        gujaratiPlaceValueMap[1000]! +
        ' ';
    number %= 1000;
  }

  if (number >= 100) {
    // Hundreds
    result += gujaratiUnitsMap[(number ~/ 100)]! +
        ' ' +
        gujaratiPlaceValueMap[100]! +
        ' ';
    number %= 100;
  }

  if (number > 0) {
    if (number < 20) {
      result += gujaratiUnitsMap[number]!;
    } else {
      result += gujaratiUnitsMap[(number ~/ 10) * 10]!;
      if (number % 10 > 0) {
        result += ' ' + gujaratiUnitsMap[number % 10]!;
      }
    }
  }

  return result.trim();
}
