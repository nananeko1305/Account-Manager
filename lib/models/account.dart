/// Account je jedan sačuvan nalog u našem menadžeru.
///
/// [useEmail] kaže da li [identifier] predstavlja email (true) ili
/// korisničko ime (false). [website] je opciono — koristi se za ikonicu.
class Account {
  Account({
    required this.id,
    required this.accountName,
    required this.useEmail,
    required this.identifier,
    required this.password,
    this.website = '',
  });

  final String id;
  final String accountName;
  final bool useEmail;
  final String identifier;
  final String password;
  final String website;

  Account copyWith({
    String? accountName,
    bool? useEmail,
    String? identifier,
    String? password,
    String? website,
  }) {
    return Account(
      id: id,
      accountName: accountName ?? this.accountName,
      useEmail: useEmail ?? this.useEmail,
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      website: website ?? this.website,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountName': accountName,
        'useEmail': useEmail,
        'identifier': identifier,
        'password': password,
        'website': website,
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        accountName: json['accountName'] as String,
        useEmail: json['useEmail'] as bool,
        identifier: json['identifier'] as String,
        password: json['password'] as String,
        website: (json['website'] as String?) ?? '',
      );
}
