import 'dart:convert';
import 'package:crypto/crypto.dart';

class MonsterDNA {
  final String bodyType;
  final String color;
  final int eyes;
  final String mouthType;
  final List<String> decorations;
  final String sourceHash;
  final bool tradedAway;

  MonsterDNA({
    required this.bodyType,
    required this.color,
    required this.eyes,
    required this.mouthType,
    required this.decorations,
    required this.sourceHash,
    this.tradedAway = false,
  });

  Map<String, dynamic> toJson() => {
        'bodyType': bodyType,
        'color': color,
        'eyes': eyes,
        'mouthType': mouthType,
        'decorations': decorations,
        'sourceHash': sourceHash,
        'tradedAway': tradedAway,
      };

  factory MonsterDNA.fromJson(Map<String, dynamic> json) => MonsterDNA(
        bodyType: json['bodyType'],
        color: json['color'],
        eyes: json['eyes'],
        mouthType: json['mouthType'],
        decorations: List<String>.from(json['decorations']),
        sourceHash: json['sourceHash'],
        tradedAway: json['tradedAway'] ?? false,
      );

  MonsterDNA copyWith({
    String? bodyType,
    String? color,
    int? eyes,
    String? mouthType,
    List<String>? decorations,
    String? sourceHash,
    bool? tradedAway,
  }) {
    return MonsterDNA(
      bodyType: bodyType ?? this.bodyType,
      color: color ?? this.color,
      eyes: eyes ?? this.eyes,
      mouthType: mouthType ?? this.mouthType,
      decorations: decorations ?? this.decorations,
      sourceHash: sourceHash ?? this.sourceHash,
      tradedAway: tradedAway ?? this.tradedAway,
    );
  }
}

// --- Trait lists ---
const List<String> _bodyTypes = ['round', 'tall', 'square', 'blob'];
const List<String> _colors = ['#FFB300', '#00C853', '#039BE5', '#D500F9'];
const List<String> _mouthTypes = ['smile', 'frown', 'grin', 'o'];
const List<String> _decorations = ['antenna', 'horns', 'spikes', 'frill'];

// --- Deterministic DNA generator ---
MonsterDNA dnaFromCode(String code) {
  final hashBytes = sha256.convert(utf8.encode(code)).bytes;

  int idx(int n) => hashBytes[n % hashBytes.length];

  return MonsterDNA(
    bodyType: _bodyTypes[idx(0) % _bodyTypes.length],
    color: _colors[idx(1) % _colors.length],
    eyes: 1 + (idx(2) % 4), // 1-4 eyes
    mouthType: _mouthTypes[idx(3) % _mouthTypes.length],
    decorations: [
      if (idx(4) % 2 == 0) _decorations[idx(5) % _decorations.length],
      if (idx(6) % 3 == 0) _decorations[idx(7) % _decorations.length],
    ].toSet().toList(), // Unique decorations
    sourceHash: code,
  );
}