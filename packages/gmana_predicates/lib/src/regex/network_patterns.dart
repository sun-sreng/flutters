// ignore_for_file: public_member_api_docs

final ipv4Maybe = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
final ipv6 = RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

final cidrV4Maybe = RegExp(
  r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\/([0-9]|[1-2][0-9]|3[0-2])$',
);
final cidrV6Maybe = RegExp(
  r'^([a-fA-F0-9:]+)\/(12[0-8]|1[0-1][0-9]|[1-9]?[0-9])$',
);

final dataUriReg = RegExp(
  r'^data:([a-z0-9][a-z0-9!\#\$\&\^\_\-\.\+]*\/[a-z0-9][a-z0-9!\#\$\&\^\_\-\.\+]*)?(;charset=[a-zA-Z0-9\-_]+)?(;base64)?,[a-zA-Z0-9!$&'
  "'"
  r'()*+,;=._~%@\/\?#-]*$',
  caseSensitive: false,
);

final magnetUriReg = RegExp(
  r'^magnet:\?xt=urn:[a-z0-9]+:[a-z0-9]{32,40}.*',
  caseSensitive: false,
);
