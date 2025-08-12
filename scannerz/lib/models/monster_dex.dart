import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'monster_dna.dart';

class MonsterDex {
  static final MonsterDex _instance = MonsterDex._internal();
  factory MonsterDex() => _instance;
  MonsterDex._internal();

  final List<MonsterDNA> _monsters = [];

  List<MonsterDNA> get monsters => List.unmodifiable(_monsters);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('monsterDex') ?? [];
    _monsters
      ..clear()
      ..addAll(jsonList.map((s) => MonsterDNA.fromJson(Map<String, dynamic>.from(jsonDecode(s)))));
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _monsters.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('monsterDex', jsonList);
  }

  bool containsBarcode(String barcode) => _monsters.any((m) => m.sourceHash == barcode);

  Future<bool> addMonster(MonsterDNA monster) async {
    if (!_monsters.any((m) => m.sourceHash == monster.sourceHash)) {
      _monsters.add(monster);
      await saveToPrefs();
      return true;
    }
    return false;
  }

  Future<void> markTradedAway(String barcode) async {
    final idx = _monsters.indexWhere((m) => m.sourceHash == barcode);
    if (idx != -1) {
      _monsters[idx] = _monsters[idx].copyWith(tradedAway: true);
      await saveToPrefs();
    }
  }
}