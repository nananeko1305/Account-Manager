import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../models/account.dart';
import '../services/auth_service.dart';
import '../services/sync_status.dart';
import '../services/vault.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/account_avatar.dart';
import '../widgets/account_card.dart';
import '../widgets/sync_banner.dart';
import 'account_form_screen.dart';
import 'auth_screen.dart';
import 'unlock_screen.dart';

/// Glavni ekran: lista naloga + drawer (tema, jezik, sync, zaključaj, odjava).
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _searchController = TextEditingController();
  late final Stream<List<Account>> _stream;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _stream = Vault.instance.watchAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Account> _filter(List<Account> accounts) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return accounts;
    return accounts
        .where((a) =>
            a.accountName.toLowerCase().contains(q) ||
            a.identifier.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openForm({Account? existing}) async {
    final result = await Navigator.of(context).push<Account>(
      MaterialPageRoute(builder: (_) => AccountFormScreen(existing: existing)),
    );
    if (result == null) return;
    await syncController.track(() => Vault.instance.upsertAccount(result));
  }

  Future<void> _delete(Account account) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0x1AD64545),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFD64545), size: 32),
              ),
              const SizedBox(height: 16),
              Text(t.deleteTitle,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.peach.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    AccountAvatar(
                        account: account,
                        color: AppTheme.terracotta,
                        radius: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(account.accountName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis),
                          Text(account.identifier,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.ink.withValues(alpha: 0.6)),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppTheme.ink.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(t.deleteWarning,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.ink.withValues(alpha: 0.6))),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(t.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD64545),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(t.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;
    await syncController.track(() => Vault.instance.deleteAccount(account.id));
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).passwordCopied),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _syncNow() async {
    try {
      await syncController.track(() => Vault.instance.forceSync());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errNoNetwork)),
      );
    }
  }

  void _lock() {
    Vault.instance.lock();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const UnlockScreen()),
    );
  }

  Future<void> _signOut() async {
    Vault.instance.lock();
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  String _paletteLabel(AppLocalizations t, String id) {
    switch (id) {
      case 'topla':
        return t.paletteTopla;
      case 'plava':
        return t.palettePlava;
      case 'crvena':
        return t.paletteCrvena;
      case 'zelena':
        return t.paletteZelena;
      case 'zuta':
        return t.paletteZuta;
      case 'ljubicasta':
        return t.paletteLjubicasta;
    }
    return id;
  }

  Future<void> _pickTheme() async {
    final t = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.theme,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: t.light,
                      icon: Icons.light_mode_rounded,
                      selected: !themeController.isDark,
                      onTap: () async {
                        await themeController.setDark(false);
                        if (mounted) setState(() {});
                        setModalState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModeButton(
                      label: t.dark,
                      icon: Icons.dark_mode_rounded,
                      selected: themeController.isDark,
                      onTap: () async {
                        await themeController.setDark(true);
                        if (mounted) setState(() {});
                        setModalState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(t.chooseColor,
                  style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.6))),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: kPalettes.map((p) {
                  final selected = p.id == themeController.current.id;
                  return GestureDetector(
                    onTap: () async {
                      await themeController.select(p);
                      if (mounted) setState(() {});
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: p.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppTheme.ink
                                  : Colors.black.withValues(alpha: 0.12),
                              width: selected ? 3 : 1,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(_paletteLabel(t, p.id),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLanguage() async {
    final t = AppLocalizations.of(context);
    final current = localeController.locale?.languageCode;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Widget tile(String flag, String label, String code) {
          final selected = current == code;
          return ListTile(
            leading: Text(flag, style: const TextStyle(fontSize: 26)),
            title: Text(label),
            trailing: selected
                ? Icon(Icons.check_rounded, color: AppTheme.terracotta)
                : null,
            onTap: () async {
              await localeController.select(Locale(code));
              if (mounted) setState(() {});
              if (ctx.mounted) Navigator.pop(ctx);
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.language,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(t.chooseLanguage,
                  style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              tile('🇬🇧', 'English', 'en'),
              tile('🇷🇸', 'Srpski', 'sr'),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    final c = color ?? AppTheme.ink.withValues(alpha: 0.75);
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label,
          style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      onTap: onTap,
    );
  }

  Widget _buildDrawer(AppLocalizations t) {
    final email = AuthService.instance.currentUser?.email ?? '';
    return Drawer(
      backgroundColor: AppTheme.cream,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.terracotta,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Account Manager',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800)),
                        if (email.isNotEmpty)
                          Text(email,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.ink.withValues(alpha: 0.6)),
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppTheme.ink.withValues(alpha: 0.1)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(Icons.sync_rounded, t.syncNow, () {
                    Navigator.pop(context);
                    _syncNow();
                  }),
                  _drawerItem(Icons.palette_outlined, t.theme, () {
                    Navigator.pop(context);
                    _pickTheme();
                  }),
                  _drawerItem(Icons.language_rounded, t.language, () {
                    Navigator.pop(context);
                    _pickLanguage();
                  }),
                  _drawerItem(Icons.lock_outline_rounded, t.lock, () {
                    Navigator.pop(context);
                    _lock();
                  }),
                ],
              ),
            ),
            Divider(height: 1, color: AppTheme.ink.withValues(alpha: 0.1)),
            _drawerItem(Icons.logout_rounded, t.logout, () {
              Navigator.pop(context);
              _signOut();
            }, color: const Color(0xFFD64545)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      drawer: _buildDrawer(t),
      appBar: AppBar(title: Text(t.myAccounts)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.newAccount),
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: StreamBuilder<List<Account>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data!;
                if (all.isEmpty) return const _EmptyState();

                final items = _filter(all);
                return Column(
                  children: [
                    _SearchField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      onClear: () => setState(() {
                        _searchController.clear();
                        _query = '';
                      }),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? _NoResults(query: _query)
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 96),
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) => AccountCard(
                                account: items[i],
                                color: AppTheme.avatarColors[
                                    i % AppTheme.avatarColors.length],
                                onTap: () => _openForm(existing: items[i]),
                                onCopy: () => _copy(items[i].password),
                                onDelete: () => _delete(items[i]),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Dugme za izbor svetle/tamne teme.
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.peach.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppTheme.terracotta
                : AppTheme.ink.withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.terracotta),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Polje za pretragu na vrhu liste.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hasText = controller.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: t.searchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: t.clearSearch,
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}

/// Prikaz kad pretraga ne nađe nijedan nalog.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: AppTheme.ink.withValues(alpha: 0.35)),
          const SizedBox(height: 12),
          Text(t.noResults(query),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Prikaz kad još nema nijedan nalog.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.peach,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_rounded,
                size: 46, color: AppTheme.terracotta),
          ),
          const SizedBox(height: 20),
          Text(t.emptyTitle,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(t.emptySubtitle,
              style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
