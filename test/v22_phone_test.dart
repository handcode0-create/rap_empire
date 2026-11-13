import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';

void main() {
  test('les invitations V22 affichées par le téléphone proviennent du moteur existant', () {
    final s = act21(init21(), 'preset', 'carriere').s;
    s['rank'] = 4;
    final invitations = cvView21(s)
        .where((offer) => offer['status'] == 'available')
        .toList();

    expect(invitations, hasLength(3));
    expect(invitations.map((offer) => offer['id']).toSet(), hasLength(3));
    expect(invitations.every((offer) => offer['title'] is String), isTrue);
    expect(invitations.every((offer) => offer['cityName'] is String), isTrue);
  });

  test('les invitations restent disponibles sans modifier la sauvegarde', () {
    final s = act21(init21(), 'preset', 'carriere').s;
    s['rank'] = 4;
    final before = Map<String, dynamic>.from(s);
    final first = cvView21(s).first;

    expect(first['status'], 'available');
    expect(s.containsKey('cv'), isFalse);
    expect(s['day'], before['day']);
  });
}
