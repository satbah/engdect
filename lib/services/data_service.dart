import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unit.dart';

class DataService {
  static const String _savedUnitsKey = 'saved_units';

  Future<List<Unit>> loadUnits() async {
    // Load from assets first
    final String jsonString = await rootBundle.loadString('assets/units.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final List<Unit> assetUnits = jsonList.map((json) => Unit.fromJson(json)).toList();

    // Load saved units from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedUnitsJson = prefs.getStringList(_savedUnitsKey) ?? [];
    final List<Unit> savedUnits = savedUnitsJson
        .map((jsonStr) => Unit.fromJson(jsonDecode(jsonStr)))
        .toList();

    // Combine asset units and saved units
    return [...assetUnits, ...savedUnits];
  }

  Future<void> saveUnit(Unit unit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnitsJson = prefs.getStringList(_savedUnitsKey) ?? [];

    // Add new unit
    savedUnitsJson.add(jsonEncode(unit.toJson()));

    // Save back to SharedPreferences
    await prefs.setStringList(_savedUnitsKey, savedUnitsJson);
    print('Saved unit: ${unit.title}');
  }

  Future<void> deleteUnit(String unitId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnitsJson = prefs.getStringList(_savedUnitsKey) ?? [];

    // Remove unit with matching ID
    savedUnitsJson.removeWhere((jsonStr) {
      final unit = Unit.fromJson(jsonDecode(jsonStr));
      return unit.unitId == unitId;
    });

    // Save back to SharedPreferences
    await prefs.setStringList(_savedUnitsKey, savedUnitsJson);
  }
}