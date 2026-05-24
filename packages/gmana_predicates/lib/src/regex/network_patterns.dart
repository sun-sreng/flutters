// ignore_for_file: public_member_api_docs

final ipv4Maybe = RegExp(
  r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$',
);
final ipv6 = RegExp(
  r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$',
);
