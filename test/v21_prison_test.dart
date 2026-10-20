import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';

void main() {
  J jailed() {
    final s = act21(init21(), 'preset', 'carriere').s;
    s['jail'] = {'until': s['day'] + 4, 'days': 4};
    return s;
  }

  test('enregistrement en prison : qualité faible par défaut', () {
    final r = act21(jailed(), 'jrecord');
    expect(r.err, isNull);
    expect(r.s['cur']['title'], contains('Freestyle de cellule'));
    expect(r.s['cur']['Q'], 24);
    expect(r.s['cur']['jailRecord'], 1);
  });

  test('téléphone satellite améliore les prochains enregistrements', () {
    final initial = jailed();
    final before = initial['cash'] as num;
    final bought = act21(initial, 'jphone');
    expect(bought.err, isNull);
    expect(bought.s['jphone'], 1);
    expect(bought.s['cash'], before - 18000);
    final recorded = act21(bought.s, 'jrecord');
    expect(recorded.err, isNull);
    expect(recorded.s['cur']['Q'], 62);
  });

  test('RIO augmente la réputation carcérale et reste un morceau de prison', () {
    final r = act21(jailed(), 'jrio');
    expect(r.err, isNull);
    expect(r.s['cur']['rio'], 1);
    expect(r.s['cur']['title'], 'RIO de cellule');
    expect(r.s['jrep'], 2);
  });

  test('affrontement carcéral limité à une tentative par jour', () {
    final first = act21(jailed(), 'jfight');
    expect(first.err, isNull);
    final second = act21(first.s, 'jfight');
    expect(second.err, 'deja');
  });

  test('actions de prison interdites hors détention', () {
    expect(act21(init21(), 'jrecord').err, 'prison');
    expect(act21(init21(), 'jrio').err, 'prison');
    expect(act21(init21(), 'jfight').err, 'prison');
  });
}
