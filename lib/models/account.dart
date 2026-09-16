/// Account je jedan sačuvan nalog.
///
/// [order] određuje redosled u listi (manji = više gore). Korisnik ga menja
/// prevlačenjem kartica. [website] je opciono — za ikonicu servisa.
class Account {
  Account({
    required this.id,
    required this.accountName,
    required this.useEmail,
    required this.identifier,
    required this.password,
    this.website = '',
    this.order = 0,
  });

  final String id;
  final String accountName;
  final bool useEmail;
  final String identifier;
  final String password;
  final String website;
  final double order;

  Account copyWith({
    String? accountName,
    bool? useEmail,
    String? identifier,
    String? password,
    String? website,
    double? order,
  }) {
    return Account(
      id: id,
      accountName: accountName ?? this.accountName,
      useEmail: useEmail ?? this.useEmail,
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      website: website ?? this.website,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountName': accountName,
        'useEmail': useEmail,
        'identifier': identifier,
        'password': password,
        'website': website,
        'order': order,
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        accountName: json['accountName'] as String,
        useEmail: json['useEmail'] as bool,
        identifier: json['identifier'] as String,
        password: json['password'] as String,
        website: (json['website'] as String?) ?? '',
        order: (json['order'] as num?)?.toDouble() ?? 0,
      );
}
