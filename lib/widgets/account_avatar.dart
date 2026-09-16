import 'package:flutter/material.dart';

import '../models/account.dart';

/// Prikazuje ikonicu (logo) servisa za nalog. Ako se logo ne nađe (ili nema
/// interneta), prikaže prvo slovo naziva u boji naloga.
///
/// Domen se uzima iz polja [Account.website]; ako je prazno, pogađa se iz
/// naziva (npr. "Instagram" -> instagram.com).
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.account,
    required this.color,
    this.radius = 24,
  });

  final Account account;
  final Color color;
  final double radius;

  String? _domain() {
    var raw = account.website.trim().toLowerCase();
    if (raw.isEmpty) {
      final name =
          account.accountName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      return name.isEmpty ? null : '$name.com';
    }
    raw = raw.replaceFirst(RegExp(r'^https?://'), '');
    raw = raw.split('/').first.replaceFirst(RegExp(r'^www\.'), '');
    if (!raw.contains('.')) {
      final w = raw.replaceAll(RegExp(r'[^a-z0-9]'), '');
      return w.isEmpty ? null : '$w.com';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final initial = account.accountName.isNotEmpty
        ? account.accountName[0].toUpperCase()
        : '?';
    final letter = Text(
      initial,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w800,
        fontSize: radius * 0.85,
      ),
    );

    final domain = _domain();
    Widget child = letter;
    if (domain != null) {
      child = Image.network(
        'https://www.google.com/s2/favicons?domain=$domain&sz=64',
        fit: BoxFit.contain,
        gaplessPlayback: true,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (_, _, _) => letter,
        loadingBuilder: (ctx, c, progress) => progress == null ? c : letter,
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      padding: EdgeInsets.all(radius * 0.42),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
      ),
      child: Center(child: child),
    );
  }
}
