import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:crypto/crypto.dart';
import '../../models/monster_dna.dart';
import '../../models/monster_dex.dart';
import '../../widgets/monster_widget.dart';
import '../pokedex/pokedex_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MonsterDNA? _monster;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    MonsterDex().loadFromPrefs();
  }

  bool isMonsterBarcode(String code) {
    final hash = sha256.convert(utf8.encode(code)).toString();
    final lastChar = hash.substring(hash.length - 1);
    final lastInt = int.tryParse(lastChar, radix: 16) ?? 0;
    return lastInt % 2 == 0;
  }

  void _onDetect(BarcodeCapture capture) async {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode != null && barcode.rawValue != null) {
      final code = barcode.rawValue!;
      if (!isMonsterBarcode(code)) {
        setState(() => _monster = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No monster in this barcode!'),
          backgroundColor: Colors.redAccent,
        ));
        return;
      }

      final newMonster = dnaFromCode(code);

      if (MonsterDex().containsBarcode(code)) {
        setState(() => _monster = newMonster);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You already discovered this monster!'),
          backgroundColor: Colors.amber,
        ));
      } else {
        await MonsterDex().addMonster(newMonster);
        setState(() => _monster = newMonster);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('New monster discovered!'),
          backgroundColor: Colors.green,
        ));
      }

      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _monster = null);
      });
    }
  }

  void _openDex() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PokedexScreen()),
    );
    setState(() {}); // Refresh in case Dex changed
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(),
            onDetect: _onDetect,
          ),
          // PROMPT at TOP
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                color: Colors.indigo.shade700,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Point at a barcode or QR code',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
          if (_monster != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: Colors.black.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MonsterWidget(dna: _monster!, size: 140),
                      const SizedBox(height: 8),
                      const Text(
                        'Monster Found!',
                        style: TextStyle(color: Colors.amber, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text('Body: ${_monster!.bodyType}', style: const TextStyle(color: Colors.white)),
                      Text('Color: ${_monster!.color}', style: const TextStyle(color: Colors.white)),
                      Text('Eyes: ${_monster!.eyes}', style: const TextStyle(color: Colors.white)),
                      Text('Mouth: ${_monster!.mouthType}', style: const TextStyle(color: Colors.white)),
                      Text(
                        'Decorations: ${_monster!.decorations.join(", ")}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Barcode: ${_monster!.sourceHash}',
                        style: TextStyle(color: Colors.grey[300], fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openDex,
        icon: const Icon(Icons.catching_pokemon),
        label: const Text('Dex'),
      ),
    );
  }
}