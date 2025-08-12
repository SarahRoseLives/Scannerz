import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../models/monster_dex.dart';
import '../../widgets/monster_widget.dart';
import '../../models/monster_dna.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({Key? key}) : super(key: key);

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  @override
  void initState() {
    super.initState();
    MonsterDex().loadFromPrefs().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _askTrade(MonsterDNA monster) async {
    if (monster.tradedAway) {
      // Show info dialog that you cannot trade again
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Already Traded'),
          content: const Text('This monster has already been traded away and cannot be traded again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trade this monster?'),
        content: const Text('Do you want to trade this monster?\nThis will display its QR code for sharing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (result == true) {
      _showShareDialog(monster);
    }
  }

  void _showShareDialog(MonsterDNA monster) async {
    final oldBrightness = await ScreenBrightness().current;
    await ScreenBrightness().setScreenBrightness(1.0);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Monster'),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: monster.sourceHash,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Let your friend scan this code to trade!",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Mark as traded away
              await MonsterDex().markTradedAway(monster.sourceHash);
              if (mounted) setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Mark As Traded Away'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    // Restore screen brightness
    await ScreenBrightness().setScreenBrightness(oldBrightness);
  }

  @override
  Widget build(BuildContext context) {
    final monsters = MonsterDex().monsters.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monster Dex"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: monsters.isEmpty
          ? const Center(
              child: Text(
                'No monsters found yet!\nScan a barcode to discover your first monster.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.indigo),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: monsters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, i) {
                final m = monsters[i];
                final bool isTraded = m.tradedAway;
                return GestureDetector(
                  onTap: () => _askTrade(m),
                  child: Opacity(
                    opacity: isTraded ? 0.4 : 1.0,
                    child: Card(
                      elevation: 3,
                      color: isTraded ? Colors.grey[200] : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MonsterWidget(dna: m, size: 70),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        m.bodyType[0].toUpperCase() + m.bodyType.substring(1) + " Monster",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo.shade700,
                                        ),
                                      ),
                                      if (isTraded)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Icon(Icons.swap_horiz, color: Colors.grey, size: 22),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Barcode: ${m.sourceHash}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Eyes: ${m.eyes}   Mouth: ${m.mouthType}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Color: ${m.color}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  if (m.decorations.isNotEmpty)
                                    Text(
                                      "Decorations: ${m.decorations.join(', ')}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}