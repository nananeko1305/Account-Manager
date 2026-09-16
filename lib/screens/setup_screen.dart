import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/vault.dart';
import '../theme/app_theme.dart';
import '../widgets/round_icon.dart';
import 'accounts_screen.dart';

/// Prvi put: korisnik postavlja svoju master lozinku.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await Vault.instance.setup(_passwordController.text);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AccountsScreen()),
    );
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
                  const RoundIcon(icon: Icons.shield_moon_rounded),
                  const SizedBox(height: 20),
                  Text(t.setupTitle,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink)),
                  const SizedBox(height: 8),
                  Text(
                    t.setupSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.65)),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: t.masterPassword,
                                prefixIcon: const Icon(Icons.key_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 4)
                                  ? t.minChars4
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: t.confirmPassword,
                                prefixIcon: const Icon(Icons.check_circle_outline),
                              ),
                              validator: (v) => (v != _passwordController.text)
                                  ? t.passwordsNoMatch
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.lock_open_rounded),
                    label: Text(_saving ? t.saving : t.saveAndEnter),
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
