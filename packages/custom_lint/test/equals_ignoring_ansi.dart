import 'package:ansi_styles/extension.dart';
import 'package:test/test.dart';

/// Returns a matcher which matches if the match argument is a string and
/// is equal to [value] after removing ansi codes
Matcher equalsIgnoringAnsi(String value) => _IsEqualIgnoringAnsi(value);

class _IsEqualIgnoringAnsi extends Matcher {
  _IsEqualIgnoringAnsi(this._value);

  static final Object _mismatchedValueKey = Object();

  final String _value;

  @override
  bool matches(Object? object, Map<Object?, Object?> matchState) {
    final description = (object! as String).strip.replaceAll(';49m', '');
    if (_value != description) {
      matchState[_mismatchedValueKey] = description;
      return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description.addDescriptionOf(_value).add(' ignoring ansi codes');
  }

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<Object?, Object?> matchState,
    bool verbose,
  ) {
    if (matchState.containsKey(_mismatchedValueKey)) {
      final actualValue = matchState[_mismatchedValueKey]! as String;
      // Leading whitespace is added so that lines in the multiline
      // description returned by addDescriptionOf are all indented equally
      // which makes the output easier to read for this case.
      return mismatchDescription
          .add('expected normalized value\n  ')
          .addDescriptionOf(_value)
          .add('\nbut got\n  ')
          .addDescriptionOf(actualValue);
    }
    return mismatchDescription;
  }
}
