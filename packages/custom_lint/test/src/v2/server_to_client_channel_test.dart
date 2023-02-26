import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/v2/server_to_client_channel.dart';
import 'package:package_config/package_config.dart';
import 'package:test/test.dart';

void main() {
  Package createPackage(String name, String version) {
    return Package(
      name,
      Uri.parse('file:///Users/user/.pub-cache/hosted/pub.dev/$name-$version/'),
    );
  }

  ContextRoot createContextRoot(String relativePath) {
    return ContextRoot('/Users/user/project/$relativePath', []);
  }

  group('ConflictingPackagesChecker', () {
    test('should NOT throw error when there are no conflicting packages', () {
      final checker = ConflictingPackagesChecker();
      final contextRoots = [
        createContextRoot('app'),
        createContextRoot('app/packages/http'),
      ];
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('flutter_hooks', '0.18.6'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        // Same package as in the first context root
        // so there is no conflict here
        createPackage('riverpod', '2.2.0'),
        createPackage('http', '0.13.3'),
        createPackage('http_parser', '4.0.0'),
      ];

      checker.addContextRoot(contextRoots[0], firstContextRootPackages);
      checker.addContextRoot(contextRoots[1], secondContextRootPackages);

      expect(
        checker.throwErrorIfConflictingPackages,
        returnsNormally,
      );
    });

    test('should throw error when there are conflicting packages', () {
      final checker = ConflictingPackagesChecker();
      final contextRoots = [
        createContextRoot('app'),
        createContextRoot('app/packages/http'),
        createContextRoot('app/packages/design_system'),
      ];
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('flutter_hooks', '0.18.6'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        // Same package as in the first context root, but with different version
        // this should cause an error
        createPackage('riverpod', '2.1.0'),
        // This should also be shown in the error message
        createPackage('flutter_hooks', '0.18.5'),
        createPackage('http', '0.13.3'),
        createPackage('http_parser', '4.0.0'),
      ];
      // Here we want to test that the error message contains multiple locations
      final thirdContextRootPackages = [
        createPackage('riverpod', '2.1.1'),
        createPackage('flutter_hooks', '0.18.5'),
      ];

      checker.addContextRoot(contextRoots[0], firstContextRootPackages);
      checker.addContextRoot(contextRoots[1], secondContextRootPackages);
      checker.addContextRoot(contextRoots[2], thirdContextRootPackages);

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              'Some packages have conflicting versions:\n'
              '- riverpod\n'
              '    -- riverpod-2.2.0 used in:\n'
              '      --- /Users/user/project/app\n'
              '    -- riverpod-2.1.0 used in:\n'
              '      --- /Users/user/project/app/packages/http\n'
              '    -- riverpod-2.1.1 used in:\n'
              '      --- /Users/user/project/app/packages/design_system\n'
              '\n'
              '- flutter_hooks\n'
              '    -- flutter_hooks-0.18.6 used in:\n'
              '      --- /Users/user/project/app\n'
              '    -- flutter_hooks-0.18.5 used in:\n'
              '      --- /Users/user/project/app/packages/http\n'
              '      --- /Users/user/project/app/packages/design_system\n'
              '\n'
              'This is not supported. Please make sure all packages have the same version.\n'
              'You could try running `flutter pub upgrade` in the affected directories.',
            ),
          ),
        ),
      );
    });
  });
}
