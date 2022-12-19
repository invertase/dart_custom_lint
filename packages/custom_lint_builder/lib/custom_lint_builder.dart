export 'src/plugin_base.dart' show PluginBase;

// This is fine to do since we are using tight constraints on custom_lint
export 'src/public_protocol.dart'
    show
        Lint,
        LintLocation,
        LintSeverity,
        LineLocationUtils,
        LintLocationFileResultExtension;
