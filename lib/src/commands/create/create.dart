import 'package:args/command_runner.dart';
import 'package:dartexify_cli/src/commands/create/commands/commands.dart';
import 'package:mason/mason.dart';

/// {@template create_command}
/// `dartexify create` command creates code from various built-in templates.
/// {@endtemplate}
///
/// See also:
/// - [CreateSubCommand] for the base class for all create subcommands.
class CreateCommand extends Command<int> {
  /// {@macro create_command}
  CreateCommand({
    required Logger logger,
    MasonGeneratorFromBundle? generatorFromBundle,
    MasonGeneratorFromBrick? generatorFromBrick,
  }) {
    // dartexify create dartexify_article <args>
    addSubcommand(
      CreateDartexifyArticle(
        logger: logger,
        generatorFromBundle: generatorFromBundle,
        generatorFromBrick: generatorFromBrick,
      ),
    );
  }

  @override
  String get summary => '$invocation\n$description';

  @override
  String get description =>
      'Creates a new LaTeX project in the specified directory.';

  @override
  String get name => 'create';

  @override
  String get invocation =>
      'dartexify create <subcommand> <project-name> [arguments]';
}
