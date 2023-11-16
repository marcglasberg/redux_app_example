import "dart:convert"; // for the utf8.encode method
import "dart:math";
import 'package:async_redux_project_template/_EXPORT.dart';

import "package:crypto/crypto.dart";

abstract class Crypto {
  //
  Crypto._();

  static const base = Base62.base;

  /// 28 chars. See my question in StackOverflow:
  /// https://crypto.stackexchange.com/questions/52775/how-many-bits-should-a-token-have-to-be-unguessable-given-some-computational-re
  static const numOfRandomCharsForUid = 28;

  static const String charset = Base62.charset;

  static const String hexadecimalCharset = "0123456789ABCDEF";

  static final Random _random = Random.secure();

  static bool get anyBool => _random.nextBool();

  /// From 0, inclusive, to [max], exclusive.
  static int anyInt(int max) => _random.nextInt(max);

  /// I the range from 0.0, inclusive, to 1.0, exclusive.
  static double anyDouble(int max) => _random.nextDouble();

  /// Example: var myEnum = Crypto.anyEnum(MyEnum.values);
  static T anyEnum<T>(List<T> enumValues, {List<T>? except}) {
    except ??= [];

    var result = enumValues[anyInt(enumValues.length)];
    while (except.contains(result)) {
      result = enumValues[anyInt(enumValues.length)];
    }
    return result;
  }

  static String anyUid() => generateUid(numOfRandomCharsForUid);

  static String readableUid() => '${Crypto.generateHexadecimal(4)}'
      '-${Crypto.generateHexadecimal(4)}'
      '-${Crypto.generateHexadecimal(4)}';

  static String anyName([String prefix = '']) => prefix + Crypto.generateUid(8);

  static const loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, "
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
      "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris "
      "nisi ut aliquip ex ea commodo consequat. Duis aute irure "
      "dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. "
      "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit "
      "anim id est laborum."
      "\n\n"
      "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque "
      "laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi "
      "architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas "
      "sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione "
      "voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit "
      "amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut "
      "labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis "
      "nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea "
      "commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit "
      "esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas "
      "nulla pariatur?";

  /// Returns a text randomly takes from "lorem ipsum", with a minimum of [minLength] chars,
  /// and a maximum of [maxLength].
  ///
  static String anyText({int minLength = 0, int maxLength = loremIpsum.length}) {
    assert(minLength < maxLength);
    minLength = min(minLength, loremIpsum.length);
    maxLength = min(maxLength, loremIpsum.length);
    var size = _random.nextInt(maxLength - minLength) + minLength;
    var start = _random.nextInt(maxLength - size);
    return loremIpsum.substring(start, start + size).capitalize(Capitalize.firstLetterUpper);
  }

  static String generateUid(int numChars) {
    final StringBuffer result = StringBuffer("");
    for (int i = 0; i < numChars; ++i) {
      int randomInt = _random.nextInt(base);
      result.write(charset[randomInt]);
    }
    return result.toString();
  }

  static String generateHexadecimal(int numChars) {
    final StringBuffer result = StringBuffer("");
    for (int i = 0; i < numChars; ++i) {
      int randomInt = _random.nextInt(16);
      result.write(hexadecimalCharset[randomInt]);
    }
    return result.toString();
  }

  /// Generate a random-consistent uid from the given [plaintext].
  static String uidFromSha256(String plaintext) {
    var bytes = utf8.encode(plaintext); // data being hashed
    String digest = sha256.convert(bytes).toString();
    return digest.substring(0, numOfRandomCharsForUid);
  }

  /// Given an object, generates a random-consistent number between 0 inclusive and [max] exclusive,
  /// from the object's toString(). Note: max can't be larger than 4294967296.
  static int numberFromSha256(Object? obj, {required int max}) {
    if (max > 4294967296) throw ArgumentError('Maximum is 4294967296.');
    var bytes = utf8.encode(obj.toString()); // data being hashed
    List<int> digest = sha256.convert(bytes).bytes;
    int sum =
        digest[0] + (256 * digest[1]) + (256 * 256 * digest[2]) + (256 * 256 * 256 * digest[3]);

    return sum % max;
  }

  /// Given an object, returns a random-consistent enum from the object's toString().
  static T enumFromSha256<T>(Object? obj, List<T> enumValues, {List<T>? except}) {
    except ??= [];

    String plaintext = obj.toString();

    var result = enumValues[numberFromSha256(plaintext, max: enumValues.length)];
    while (except.contains(result)) {
      plaintext += 'x';
      result = enumValues[numberFromSha256(plaintext, max: enumValues.length)];
    }
    return result;
  }
}


