import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/account.dart';
import 'account_avatar.dart';
import '../theme/app_theme.dart';

/// Jedna kartica u listi — prikazuje jedan nalog.
class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.color,
    required this.onTap,
    required this.onCopy,
    required this.onDelete,
  });

  final Account account;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AccountAvatar(account: account, color: color, radius: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.accountName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          account.useEmail
                              ? Icons.email_outlined
                              : Icons.person_outline,
                          size: 15,
                          color: AppTheme.ink.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(account.identifier,
                              style: TextStyle(
                                  color: AppTheme.ink.withValues(alpha: 0.6)),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                color: AppTheme.terracotta,
                tooltip: t.copyPassword,
                onPressed: onCopy,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: AppTheme.ink.withValues(alpha: 0.45)),
                tooltip: t.delete,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
