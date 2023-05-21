import 'package:dartexify_cli/src/commands/create/commands/create_subcommands.dart';
import 'package:dartexify_cli/src/commands/create/templates/templates.dart';

/// {@template very_good_create_dart_cli_command}
/// A [CreateSubCommand] for creating Dart command line interfaces.
/// {@endtemplate}
class CreateDartexifyArticle extends CreateSubCommand {
  /// {@macro very_good_create_dart_cli_command}
  CreateDartexifyArticle({
    required super.logger,
    required super.generatorFromBundle,
    required super.generatorFromBrick,
  });

  @override
  String get name => 'article';

  @override
  String get description => 'Generate a nice LaTeX article project.';

  @override
  Template get template => DartexifyArticleTemplate();

  // @override
  // Map<String, dynamic> getTemplateVars() {
  //   final vars = super.getTemplateVars();

  //   final executableName =
  //       argResults['executable-name'] as String? ?? projectName;

  //   vars['executable_name'] = executableName;

  //   return vars;
  // }
}
