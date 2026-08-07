// ignore_for_file: public_member_api_docs

final alphaReg = RegExp(r'^[a-zA-Z]+$');
final alphaNumericReg = RegExp(r'^[a-zA-Z0-9]+$');
final asciiReg = RegExp(r'^[\x00-\x7F]+$');
final base64Reg = RegExp(
  r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$',
);
final emailReg = RegExp(
  r'^[a-zA-Z0-9.!#$%&'
  "'"
  r'*+/=?^_`{|}~-]+'
  r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
  r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*'
  r'\.[a-zA-Z]{2,}$',
);
final floatReg = RegExp(
  r'^-?(?:(?:[0-9]+(?:\.[0-9]*)?)|(?:\.[0-9]+))(?:[eE][+-]?[0-9]+)?$',
);
final fullWidthReg = RegExp(r'[^ -~｡-ﾟﾠ-ￜ￨-￮0-9a-zA-Z]');
final halfWidthReg = RegExp(r'[ -~｡-ﾟﾠ-ￜ￨-￮0-9a-zA-Z]');
final hexadecimalReg = RegExp(r'^[0-9a-fA-F]+$');
final hexColorReg = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
final intReg = RegExp(r'^(?:-?(?:0|[1-9][0-9]*))$');
final multiByteReg = RegExp(r'[^\x00-\x7F]');
final numericReg = RegExp(r'^-?[0-9]+$');
final surrogatePairsReg = RegExp(r'[\uD800-\uDBFF][\uDC00-\uDFFF]');

final camelCaseReg = RegExp(r'^[a-z]+(?:[A-Z][a-z0-9]*)*$');
final pascalCaseReg = RegExp(r'^[A-Z][a-zA-Z0-9]*$');
final snakeCaseReg = RegExp(r'^[a-z0-9]+(?:_[a-z0-9]+)*$');
final kebabCaseReg = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

final jwtReg = RegExp(r'^[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]*$');
final mimeTypeReg = RegExp(
  r'^[a-zA-Z0-9][a-zA-Z0-9!#$&^_\-\.\+]*\/[a-zA-Z0-9][a-zA-Z0-9!#$&^_\-\.\+]*$',
);

final Map<String, RegExp> hashReg = {
  'md5': RegExp(r'^[a-fA-F0-9]{32}$'),
  'sha1': RegExp(r'^[a-fA-F0-9]{40}$'),
  'sha256': RegExp(r'^[a-fA-F0-9]{64}$'),
  'sha512': RegExp(r'^[a-fA-F0-9]{128}$'),
};

