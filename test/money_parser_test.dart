import 'package:dark_finance/core/utils/money_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interpreta los formatos que escribe el usuario', () {
    expect(parseMoney('1200'), 1200);
    expect(parseMoney('1200.50'), 1200.5);
    expect(parseMoney('1200,50'), 1200.5);
    expect(parseMoney('1.200,50'), 1200.5);
    expect(parseMoney(r' $ 300 '), 300);
  });

  test('rechaza texto inválido', () {
    expect(parseMoney(''), isNull);
    expect(parseMoney('abc'), isNull);
    expect(parseMoney('-5'), isNull);
  });
}
