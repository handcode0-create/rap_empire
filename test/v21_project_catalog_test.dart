import 'package:flutter_test/flutter_test.dart';
import 'package:rap_empire/domain/v21/engine21.dart';

typedef J = Map<String, dynamic>;
J m(dynamic x) => x as J;
List l(dynamic x) => x as List;

void main() {
  test('EP/album : streams, ventes et revenus cumulés progressent chaque jour', () {
    var s = init21();
    s['projects'] = <dynamic>[
      <String, dynamic>{
        'id': 'EP-TEST',
        'title': 'Horizons',
        'type': 'EP',
        'day': 1,
        'launchL': 10000,
        'L': 10000,
        'sales': 100,
        'rev': 3000,
        'cut': 0,
        'signed': 0,
        'platforms': <String, dynamic>{'ondea': 7000, 'cauri': 3000},
        'lastCatalogDay': 1,
        'inedits': <dynamic>[
          <String, dynamic>{'id': 'T1', 'title': 'Inédit 1', 'Q': 70, 'L': 0, 'sales': 0, 'rev': 0, 'lastCatalogDay': 1},
          <String, dynamic>{'id': 'T2', 'title': 'Inédit 2', 'Q': 75, 'L': 0, 'sales': 0, 'rev': 0, 'lastCatalogDay': 1},
        ],
      }
    ];
    final beforeCash = s['cash'] as num;

    // La première transition quitte le jour de sortie ; la suivante traite J+1.
    s = act21(s, 'endDay').s;
    final afterFirstDay = m(l(s['projects']).single);
    expect(afterFirstDay['L'], 10000);
    s = act21(s, 'endDay').s;

    final project = m(l(s['projects']).single);
    expect(project['L'], greaterThan(10000));
    expect(project['sales'], greaterThan(100));
    expect(project['rev'], greaterThan(3000));
    expect(m(project['platforms'])['ondea'], greaterThan(7000));
    expect(s['cash'] as num, greaterThan(beforeCash));

    final tracks = l(project['inedits']).map(m).toList();
    expect(tracks.every((t) => (t['L'] as num) > 0), isTrue);
    expect(tracks.every((t) => (t['sales'] as num) > 0), isTrue);
    expect(tracks.every((t) => (t['rev'] as num) > 0), isTrue);
    expect(project['lastCatalogDay'], s['day']);
    expect(project['lastDayL'], greaterThan(0));
    expect(project['lastDaySales'], greaterThan(0));
  });
}
