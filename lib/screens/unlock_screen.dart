import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/vault.dart';
import '../theme/app_theme.dart';
import '../widgets/round_icon.dart';
import 'accounts_screen.dart';

// Svaki sledeći ulazak: korisnik unosi master lozinku.
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _checking = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _checking = true;
      _error = null;
    });

    final ok = await Vault.instance.unlock(_passwordController.text);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AccountsScreen()),
      );
    } else {
      setState(() {
        _checking = false;
        _error = AppLocalizations.of(context).wrongPassword;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.warmGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const RoundIcon(icon: Icons.lock_rounded),
                  const SizedBox(height: 20),
                  Text(t.unlockTitle,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink)),
                  const SizedBox(height: 8),
                  Text(t.unlockSubtitle,
                      style:
                          TextStyle(color: AppTheme.ink.withValues(alpha: 0.65))),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        autofocus: true,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: t.masterPassword,
                          prefixIcon: const Icon(Icons.key_rounded),
                          errorText: _error,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _checking ? null : _submit,
                    icon: _checking
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.lock_open_rounded),
                    label: Text(_checking ? t.checking : t.enter),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
