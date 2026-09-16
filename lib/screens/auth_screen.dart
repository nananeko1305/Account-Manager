import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/vault.dart';
import '../theme/app_theme.dart';
import '../widgets/round_icon.dart';
import 'setup_screen.dart';
import 'unlock_screen.dart';

/// Prijava ili registracija naloga (email + lozinka) preko Firebase-a.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      if (_isLogin) {
        await AuthService.instance.signIn(email, password);
      } else {
        await AuthService.instance.register(email, password);
      }
      if (!mounted) return;

      final initialized = await Vault.instance.isInitialized();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => initialized ? const UnlockScreen() : const SetupScreen(),
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _busy = false;
        _error = _messageFor(e.code);
      });
    } catch (_) {
      setState(() {
        _busy = false;
        _error = AppLocalizations.of(context).errGeneric;
      });
    }
  }

  String _messageFor(String code) {
    final t = AppLocalizations.of(context);
    switch (code) {
      case 'invalid-email':
        return t.errInvalidEmail;
      case 'email-already-in-use':
        return t.errEmailInUse;
      case 'weak-password':
        return t.errWeakPassword;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return t.errWrongCredentials;
      case 'network-request-failed':
        return t.errNoNetwork;
      default:
        return t.errWithCode(code);
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
                  const RoundIcon(icon: Icons.cloud_rounded),
                  const SizedBox(height: 20),
                  Text(_isLogin ? t.loginTitle : t.registerTitle,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink)),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? t.loginSubtitle : t.registerSubtitle,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppTheme.ink.withValues(alpha: 0.65)),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration: InputDecoration(
                                labelText: t.email,
                                prefixIcon:
                                    const Icon(Icons.alternate_email_rounded),
                              ),
                              validator: (v) => (v == null || !v.contains('@'))
                                  ? t.invalidEmail
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: t.accountPassword,
                                prefixIcon: const Icon(Icons.lock_outline),
                                errorText: _error,
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? t.minChars6
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _busy ? null : _submit,
                    icon: _busy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(_isLogin
                            ? Icons.login_rounded
                            : Icons.person_add_alt_1_rounded),
                    label: Text(_busy
                        ? t.wait
                        : (_isLogin ? t.signIn : t.register)),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _isLogin = !_isLogin;
                              _error = null;
                            }),
                    child: Text(_isLogin ? t.toRegister : t.toLogin),
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
