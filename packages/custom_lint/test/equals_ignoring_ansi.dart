import 'package:ansi_styles/extension.dart';
import 'package:test/test.dart';

/// Returns a matcher which matches if the match argument is a string and
/// is equal to [value] after removing ansi codes
Matcher equalsIgnoringAnsi(String value) => _IsEqualIgnoringAnsi(null, value);

Matcher matchIgnoringAnsi(
  Matcher Function(String value) matcher,
  String value,
) {
  return _IsEqualIgnoringAnsi(matcher(value), value);
}

class _IsEqualIgnoringAnsi extends Matcher {
  _IsEqualIgnoringAnsi(this.matcher, this._value);

  static final Object _mismatchedValueKey = Object();
  static final Object _matcherKey = Object();

  final Matcher? matcher;
  final String _value;

  @override
  bool matches(Object? object, Map<Object?, Object?> matchState) {
    final description = (object! as String).strip.replaceAll(';49m', '');
    final matcher = this.matcher;

    final isMatching =
        matcher?.matches(description, matchState) ?? _value == description;

    if (!isMatching) matchState[_mismatchedValueKey] = description;
    if (matcher != null) matchState[_matcherKey] = matcher;
    return isMatching;
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
      final matcher = matchState[_matcherKey] as Matcher?;

      // Leading whitespace is added so that lines in the multiline
      // description returned by addDescriptionOf are all indented equally
      // which makes the output easier to read for this case.
      mismatchDescription.add('expected normalized value\n  ');

      if (matcher != null) {
        mismatchDescription.add('\nto match\n  ').addDescriptionOf(matcher);
      } else {
        mismatchDescription.addDescriptionOf(_value);
      }

      mismatchDescription.add('\nbut got\n  ');
      mismatchDescription.addDescriptionOf(actualValue);
    }

    return mismatchDescription;
  }
}
