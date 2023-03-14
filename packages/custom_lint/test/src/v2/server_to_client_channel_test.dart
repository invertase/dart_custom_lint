import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/v2/server_to_client_channel.dart';
import 'package:package_config/package_config.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

void main() {
  Package createPackage(String name, String version) {
    return Package(
      name,
      Uri.parse('file:///Users/user/.pub-cache/hosted/pub.dev/$name-$version/'),
    );
  }

  Package createGitPackage(String name, String gitPath) {
    return Package(
      name,
      Uri.parse('file:///Users/user/.pub-cache/git/$name-$gitPath/'),
    );
  }

  Package createPathPackage(String name, String path) {
    return Package(
      name,
      Uri.parse('file://$path'),
      relativeRoot: false,
    );
  }

  ContextRoot createContextRoot(String relativePath) {
    return ContextRoot('/Users/user/project/$relativePath', []);
  }

  group(ConflictingPackagesChecker, () {
    test('should NOT throw error when there are no conflicting packages', () {
      final checker = ConflictingPackagesChecker();
      // We don't need to pass a real pubspec here
      final pubspec = Pubspec('fake_package');
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

      checker.addContextRoot(
        contextRoots[0],
        firstContextRootPackages,
        pubspec,
      );
      checker.addContextRoot(
        contextRoots[1],
        secondContextRootPackages,
        pubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        returnsNormally,
      );
    });

    test('should throw error when there are conflicting packages', () {
      final checker = ConflictingPackagesChecker();
      final flutterDependency = HostedDependency();
      final firstPubspec = Pubspec(
        'app',
        dependencies: {
          'flutter': flutterDependency,
        },
      );
      final secondPubspec = Pubspec(
        'http',
        dependencies: {
          'flutter': flutterDependency,
        },
      );
      final thirdPubspec = Pubspec(
        'design_system',
        dependencies: {
          'flutter': flutterDependency,
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
            ref: '4cdfbf9159f2e9746fce29d2862f148f901da66a',
            path: 'packages/freezed',
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final thirdContextRoot = createContextRoot('app/packages/design_system');
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
        createPathPackage('freezed', '/Users/user/freezed/packages/freezed/'),
        // This is to simulate a transitive git dependency
        createGitPackage(
          'http_parser',
          '4cdfbf9159123746fce29d2862f148f901da66a',
        ),
      ];
      // Here we want to test that the error message contains multiple locations
      final thirdContextRootPackages = [
        createPackage('riverpod', '2.1.1'),
        createPackage('flutter_hooks', '0.18.5'),
        // This is a git package, so we want to make sure it's handled correctly
        createGitPackage(
          'freezed',
          '4cdfbf9159f2e9746fce29d2862f148f901da66a/packages/freezed',
        ),
        createPackage('http_parser', '4.0.0'),
      ];

      checker.addContextRoot(
        firstContextRoot,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot,
        secondContextRootPackages,
        secondPubspec,
      );
      checker.addContextRoot(
        thirdContextRoot,
        thirdContextRootPackages,
        thirdPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- flutter_hooks v0.18.6
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- flutter_hooks v0.18.5
- http_parser v4.0.0
- freezed from path /Users/user/freezed/packages/freezed/
- http_parser from git 4cdfbf9159123746fce29d2862f148f901da66a/

design_system at /Users/user/project/app/packages/design_system
- riverpod v2.1.1
- flutter_hooks v0.18.5
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git ref 4cdfbf9159f2e9746fce29d2862f148f901da66a path packages/freezed
- http_parser v4.0.0

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
flutter pub upgrade riverpod flutter_hooks freezed
cd /Users/user/project/app/packages/http
flutter pub upgrade riverpod flutter_hooks http_parser freezed http_parser
cd /Users/user/project/app/packages/design_system
flutter pub upgrade riverpod flutter_hooks freezed http_parser
''',
            ),
          ),
        ),
      );
    });

    test('pure dart packages should have simple pub upgrade command', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec('http');
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createPackage('freezed', '2.3.1'),
      ];

      checker.addContextRoot(
        firstContextRoot,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed v2.3.1

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });

    test('should show git dependency without path and ref', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec(
        'http',
        dependencies: {
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createGitPackage('freezed', '4cdfbf9159f2e9746fce29d2862f148f901da66a'),
      ];

      checker.addContextRoot(
        firstContextRoot,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });

    test('should show git dependency without path', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec(
        'http',
        dependencies: {
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
            ref: '4cdfbf9159f2e9746fce29d2862f148f901da66a',
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createGitPackage('freezed', '4cdfbf9159f2e9746fce29d2862f148f901da66a'),
      ];

      checker.addContextRoot(
        firstContextRoot,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git ref 4cdfbf9159f2e9746fce29d2862f148f901da66a

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });

    test('should show git dependency without ref', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec(
        'http',
        dependencies: {
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
            path: 'packages/freezed',
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createGitPackage('freezed', '4cdfbf9159f2e9746fce29d2862f148f901da66a'),
      ];

      checker.addContextRoot(
        firstContextRoot,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git path packages/freezed

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });

    test('should show git dependency from dev dependencies', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec(
        'http',
        devDependencies: {
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createGitPackage('freezed', '4cdfbf9159f2e9746fce29d2862f148f901da66a'),
      ];

      checker.addContextRoot(
        firstContextRoot,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });
  });
}
