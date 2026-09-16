import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/account.dart';
import '../theme/app_theme.dart';

/// Forma za dodavanje novog ili izmenu postojećeg naloga.
class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({super.key, this.existing});

  final Account? existing;

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;
  late final TextEditingController _websiteController;
  late bool _useEmail;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.accountName ?? '');
    _identifierController = TextEditingController(text: e?.identifier ?? '');
    _passwordController = TextEditingController(text: e?.password ?? '');
    _websiteController = TextEditingController(text: e?.website ?? '');
    _useEmail = e?.useEmail ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.existing;
    final account = Account(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      accountName: _nameController.text.trim(),
      useEmail: _useEmail,
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
      website: _websiteController.text.trim(),
    );
    Navigator.of(context).pop(account);
  }

  void _copyPassword() {
    Clipboard.setData(ClipboardData(text: _passwordController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).passwordCopied),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? t.editAccount : t.newAccount)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: t.accountName,
                          hintText: t.accountNameHint,
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? t.required
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: t.website,
                          hintText: t.websiteHint,
                          prefixIcon: const Icon(Icons.public_rounded),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _EmailUsernameToggle(
                        useEmail: _useEmail,
                        onChanged: (v) => setState(() => _useEmail = v),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _identifierController,
                        keyboardType: _useEmail
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                        decoration: InputDecoration(
                          labelText: _useEmail ? t.email : t.username,
                          prefixIcon: Icon(_useEmail
                              ? Icons.email_outlined
                              : Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? t.required
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: t.password,
                          prefixIcon: const Icon(Icons.key_outlined),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded),
                                tooltip: t.showHide,
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded),
                                color: AppTheme.terracotta,
                                tooltip: t.copyPassword,
                                onPressed: _copyPassword,
                              ),
                            ],
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? t.required : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: Icon(isEditing
                    ? Icons.save_rounded
                    : Icons.add_circle_outline_rounded),
                label: Text(isEditing ? t.saveChanges : t.addAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Prekidač koji bira da li je polje email ili korisničko ime.
class _EmailUsernameToggle extends StatelessWidget {
  const _EmailUsernameToggle({required this.useEmail, required this.onChanged});

  final bool useEmail;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.peach.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        activeThumbColor: AppTheme.terracotta,
        title: Text(useEmail ? t.usingEmail : t.usingUsername),
        subtitle: Text(
          useEmail ? t.switchToUsername : t.switchToEmail,
          style: const TextStyle(fontSize: 12),
        ),
        value: useEmail,
        onChanged: onChanged,
      ),
    );
  }
}
