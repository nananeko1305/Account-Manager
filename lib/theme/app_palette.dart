import 'package:flutter/material.dart';

/// Jedna tema = jedan skup boja. Svetle vrednosti su zadate, a tamne
/// (za dark mod) se izvode iz glavne boje da ostanu usklađene.
class AppPalette {
  const AppPalette({
    required this.id,
    required this.label,
    required this.primary,
    required this.soft,
    required this.bg,
    required this.ink,
  });

  final String id;
  final String label;
  final Color primary;
  final Color soft;
  final Color bg;
  final Color ink;

  // --- tamne varijante (dark mod) ---
  Color get primaryOnDark => _hsl(lightness: (_h(primary).lightness + 0.06).clamp(0.0, 0.72));
  Color get darkBg => _hsl(saturation: 0.20, lightness: 0.10);
  Color get darkSurface => _hsl(saturation: 0.16, lightness: 0.16);
  Color get darkInk => _hsl(saturation: 0.14, lightness: 0.92);
  Color get darkSoft => _hsl(saturation: 0.30, lightness: 0.24);

  HSLColor _h(Color c) => HSLColor.fromColor(c);
  Color _hsl({double? saturation, double? lightness}) {
    final base = _h(primary);
    return base
        .withSaturation(saturation ?? base.saturation)
        .withLightness(lightness ?? base.lightness)
        .toColor();
  }

  /// Šarene boje za avatare naloga — izvedene iz glavne boje teme.
  List<Color> get avatars {
    final hsl = HSLColor.fromColor(primary);
    return List.generate(6, (i) {
      final hue = (hsl.hue + i * 14) % 360;
      final light = (0.52 - (i % 3) * 0.06).clamp(0.32, 0.6);
      final sat = hsl.saturation.clamp(0.35, 0.72);
      return hsl.withHue(hue).withLightness(light).withSaturation(sat).toColor();
    });
  }
}

/// Sve dostupne teme (boje).
const List<AppPalette> kPalettes = [
  AppPalette(id: 'topla', label: 'Topla', primary: Color(0xFFE07A5F), soft: Color(0xFFFFE3D3), bg: Color(0xFFFFF7F0), ink: Color(0xFF3D2C25)),
  AppPalette(id: 'plava', label: 'Plava', primary: Color(0xFF4A78D6), soft: Color(0xFFDCE6FB), bg: Color(0xFFF3F6FF), ink: Color(0xFF22314F)),
  AppPalette(id: 'crvena', label: 'Crvena', primary: Color(0xFFD94E4E), soft: Color(0xFFFBDCDC), bg: Color(0xFFFFF4F3), ink: Color(0xFF4A2222)),
  AppPalette(id: 'zelena', label: 'Zelena', primary: Color(0xFF3FA66A), soft: Color(0xFFD6F0DF), bg: Color(0xFFF1FBF5), ink: Color(0xFF1F4130)),
  AppPalette(id: 'zuta', label: 'Žuta', primary: Color(0xFFE0A63E), soft: Color(0xFFFBEFCF), bg: Color(0xFFFFFBEF), ink: Color(0xFF4A3B1A)),
  AppPalette(id: 'ljubicasta', label: 'Ljubičasta', primary: Color(0xFF8A5CD1), soft: Color(0xFFEADFFB), bg: Color(0xFFF8F4FF), ink: Color(0xFF362450)),
];
