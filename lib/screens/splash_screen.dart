import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/vault.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'setup_screen.dart';
import 'unlock_screen.dart';

/// Prvi ekran: logo, pa odluka kuda dalje (prijava / setup / unlock).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final Widget next;
    if (AuthService.instance.currentUser == null) {
      next = const AuthScreen();
    } else {
      final initialized = await Vault.instance.isInitialized();
      if (!mounted) return;
      next = initialized ? const UnlockScreen() : const SetupScreen();
    }

    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.warmGradient,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: AppTheme.terracotta,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.terracotta.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_rounded,
                    size: 56, color: Colors.white),
              ),
              const SizedBox(height: 28),
              Text('Account Manager',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink)),
              const SizedBox(height: 8),
              Text(t.appTagline,
                  style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.ink.withValues(alpha: 0.6))),
              const SizedBox(height: 36),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: AppTheme.terracotta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
