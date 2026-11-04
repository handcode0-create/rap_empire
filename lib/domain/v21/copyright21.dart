import 'dart:math' as math;

import 'reg21.dart';

/// Modèle économique des droits d'auteur. Les probabilités sont des paramètres de gameplay,
/// pas une affirmation juridique sur une licence réelle.
const copyrightHitThreshold21 = 250000;
const copyrightMinClaim21 = 6000;
const copyrightMaxClaim21 = 150000;

J initCopyright21() => <String, dynamic>{
  'nextId': 1,
  'claims': <dynamic>[],
};

J normCopyright21(dynamic value) {
  final state = value is Map
      ? Map<String, dynamic>.from(value)
      : initCopyright21();
  state['nextId'] ??= 1;
  state['claims'] ??= <dynamic>[];
  return state;
}

/// Les instrus payantes du catalogue disposent d'un accord d'exploitation dans le jeu.
/// « Nuit à Ndo » est gratuite, mais ses conditions commerciales ne sont pas vérifiées.
J copyrightRightsFor21(String instrumentId, int day) {
  if (instrumentId == 'nuit') {
    return <String, dynamic>{
      'source': 'instrumentale_gratuite',
      'status': 'unverified_free',
      'risk': 0.35,
      'recordedDay': day,
      'producer': 'Beatmaker indépendant',
      'terms': 'Autorisation commerciale non vérifiée',
    };
  }
  return <String, dynamic>{
    'source': 'catalogue_producteur',
    'status': 'licensed',
    'risk': 0.0,
    'recordedDay': day,
    'producer': Reg21.instrus[instrumentId]?['who'] ?? 'Producteur du jeu',
    'terms': 'Accord d’exploitation inclus',
  };
}

bool copyrightIsBlocked21(J song) {
  final rights = song['rights'];
  if (rights is! Map) return false;
  return rights['status'] == 'suspended' || rights['status'] == 'removed';
}

int copyrightSalt21(dynamic songId) {
  final text = '$songId';
  var value = 0;
  for (final unit in text.codeUnits) {
    value = (value * 31 + unit) & 0x7fffffff;
  }
  return value;
}

num copyrightClaimChance21(J song) {
  final rights = song['rights'];
  if (rights is! Map || rights['status'] != 'unverified_free') return 0;
  final risk = (rights['risk'] as num? ?? 0).clamp(0, 1);
  final streams = (song['L'] as num? ?? 0).clamp(0, 10000000);
  final revenue = (song['rev'] as num? ?? 0).clamp(0, 1000000);
  final exposure = math.min(0.025, 0.0015 + streams / 3000000 * 0.004 + revenue / 1000000 * 0.002);
  return exposure * risk;
}

bool copyrightHasOpenClaim21(J state) {
  final cr = state['cr'];
  if (cr is! Map || cr['claims'] is! List) return false;
  return (cr['claims'] as List).any((raw) {
    final status = (raw as Map)['status'];
    return status == 'open' || status == 'negotiating';
  });
}

bool copyrightTryClaim21(J state, J song, int day, num random) {
  final rights = song['rights'];
  if (rights is! Map || rights['status'] != 'unverified_free') return false;
  if (day - ((rights['recordedDay'] as num?) ?? day) < 3) return false;
  if ((song['L'] as num? ?? 0) < copyrightHitThreshold21) return false;
  final cr = normCopyright21(state['cr']);
  state['cr'] = cr;
  final claims = cr['claims'] as List;
  final unresolved = claims.any((raw) =>
      const {'open', 'negotiating', 'contested', 'ignored'}.contains((raw as Map)['status']));
  if (unresolved || random >= copyrightClaimChance21(song)) return false;

  final amount = ((song['rev'] as num? ?? 0) * 0.22).round().clamp(copyrightMinClaim21, copyrightMaxClaim21);
  final id = 'CR${cr['nextId']}';
  cr['nextId'] = (cr['nextId'] as num) + 1;
  final claim = <String, dynamic>{
    'id': id,
    'songId': song['id'],
    'title': song['title'],
    'producer': rights['producer'],
    'day': day,
    'amount': amount,
    'status': 'open',
    'streamsAtClaim': song['L'],
    'revenueAtClaim': song['rev'],
  };
  claims.add(claim);
  rights['status'] = 'claim_open';
  rights['claimId'] = id;
  rights['claimDay'] = day;
  return true;
}

J? _activeCopyrightClaim21(J state) {
  final cr = state['cr'];
  if (cr is! Map || cr['claims'] is! List) return null;
  for (final raw in (cr['claims'] as List).reversed) {
    final claim = raw as Map;
    if (const {'open', 'negotiating', 'contested', 'ignored'}.contains(claim['status'])) {
      return Map<String, dynamic>.from(claim);
    }
  }
  return null;
}

J? _mutableClaim21(J state, String id) {
  final cr = normCopyright21(state['cr']);
  state['cr'] = cr;
  for (final raw in cr['claims'] as List) {
    if ((raw as Map)['id'] == id) return raw as J;
  }
  return null;
}

num copyrightActionCost21(J state, String action) {
  if (action != 'settle') return 0;
  final claim = _activeCopyrightClaim21(state);
  return claim == null ? 0 : (claim['amount'] as num? ?? 0);
}

/// Applique une décision de scène. Renvoie les cauris à débiter (0 si aucun paiement).
num applyCopyrightAction21(J state, String action) {
  final snapshot = _activeCopyrightClaim21(state);
  if (snapshot == null) return 0;
  final claim = _mutableClaim21(state, snapshot['id'] as String);
  if (claim == null) return 0;
  final song = (state['disco'] as List).cast<Map>().where((s) => s['id'] == claim['songId']).firstOrNull;
  final rights = song?['rights'];
  switch (action) {
    case 'negotiate':
      claim['amount'] = math.max(copyrightMinClaim21, ((claim['amount'] as num) * 0.70).round());
      claim['status'] = 'negotiating';
      if (rights is Map) rights['status'] = 'negotiating';
      return 0;
    case 'settle':
      final amount = (claim['amount'] as num? ?? 0);
      claim['status'] = 'settled';
      claim['settledDay'] = state['day'];
      if (rights is Map) {
        rights['status'] = 'licensed_after_settlement';
        rights['settledDay'] = state['day'];
      }
      return amount;
    case 'contest':
      claim['status'] = 'contested';
      claim['contestedDay'] = state['day'];
      if (rights is Map) rights['status'] = 'contested';
      return 0;
    case 'ignore':
      claim['status'] = 'ignored';
      claim['ignoredDay'] = state['day'];
      if (rights is Map) rights['status'] = 'ignored';
      return 0;
    default:
      return 0;
  }
}

/// Après une contestation ou un refus, le producteur peut obtenir une suspension différée.
/// Ce risque reste faible et n'est jamais une sanction automatique.
bool copyrightAdvance21(J state, J song, int day, num random) {
  final rights = song['rights'];
  if (rights is! Map) return false;
  final status = rights['status'];
  if (status != 'ignored' && status != 'contested') return false;
  final since = (rights['claimDay'] as num? ?? day).toInt();
  if (day - since < 3) return false;
  final chance = status == 'ignored' ? 0.035 : 0.012;
  if (random >= chance) return false;
  rights['status'] = 'suspended';
  rights['suspendedDay'] = day;
  final id = rights['claimId'];
  if (id != null) {
    final claim = _mutableClaim21(state, '$id');
    if (claim != null) {
      claim['status'] = 'suspended';
      claim['suspendedDay'] = day;
    }
  }
  return true;
}
