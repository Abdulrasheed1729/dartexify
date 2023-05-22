import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dartexify_cli/src/commands/create/templates/template.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);

/// A method which returns a [Future<MasonGenerator>] given a [Brick].
typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

abstract class CreateSubCommand extends Command<int> {
  CreateSubCommand({
    required this.logger,
    required MasonGeneratorFromBundle? generatorFromBundle,
    required MasonGeneratorFromBrick? generatorFromBrick,
  })  : _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle,
        _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick {
    argParser
      ..addOption(
        'author',
        help: 'Name of author.',
      )
      ..addOption(
        'description',
        help: '''
            The description (subject matter) for this new project. E.g. (A Dart method for Analysing the Cauchy Differential Equation)
            ''',
        aliases: ['desc'],
      )
      ..addOption(
        'output-directory',
        help: 'The desired output directory when creating a new project.',
        abbr: 'o',
      );
  }

  @override
  String get description => 'Create an awesome LaTeX project.';

  @override
  String get name => 'create';

  final Logger logger;

  final MasonGeneratorFromBundle _generatorFromBundle;

  final MasonGeneratorFromBrick _generatorFromBrick;

  ArgResults? argResultOverrides;

  /// Should return the desired template to be created during a command run.
  Template get template;

  @override
  String get invocation => 'dartexify create $name <project-name> [arguments]';

  @override
  ArgResults get argResults => argResultOverrides ?? super.argResults!;

  /// Gets the output [Directory].
  Directory get outputDirectory {
    final directory = argResults['output-directory'] as String? ?? '.';
    return Directory(directory);
  }

  void _validateProjectName(List<String> args) {
    logger.detail('Validating project name; args: $args');

    if (args.isEmpty) {
      usageException('No option specified for the project name.');
    }
  }

  /// Gets the project name.
  String get projectName {
    final args = argResults.rest;
    _validateProjectName(args);
    return args.first;
  }

  /// Gets the description for the project.
  String get projectDescription {
    return argResults['description'] as String? ??
        logger.prompt(
          'Project description?',
          defaultValue: 'Creating Mobile Solutions the Dart (Flutter) way',
        );
  }

  /// Gets the author name.
  String get author {
    return argResults['author'] as String? ??
        logger.prompt(
          'Name of Author?',
          defaultValue: 'Plushy Dash',
        );
  }

  Future<MasonGenerator> _getGeneratorForTemplate() async {
    try {
      final brick = Brick.version(
        name: template.bundle.name,
        version: '^${template.bundle.version}',
      );
      logger.detail(
        '''Building generator from brick: ${brick.name} ${brick.location.version}''',
      );
      return await _generatorFromBrick(brick);
    } catch (_) {
      logger.detail('Building generator from brick failed: $_');
    }
    logger.detail(
      '''Building generator from bundle ${template.bundle.name} ${template.bundle.version}''',
    );
    return _generatorFromBundle(template.bundle);
  }

  @override
  Future<int> run() async {
    final template = this.template;
    final generator = await _getGeneratorForTemplate();
    final result = await runCreate(generator, template);

    return result;
  }

  /// Responsible for returns the template parameters to be passed to the
  /// template brick.
  ///
  /// Override if the create sub command requires additional template
  /// parameters.
  @mustCallSuper
  Map<String, dynamic> getTemplateVars() {
    final projectName = this.projectName;
    final projectDescription = this.projectDescription;
    final author = this.author;

    return <String, dynamic>{
      'project_name': projectName,
      'description': projectDescription,
      'author': author,
    };
  }

  /// Invoked by [run] to create the project, contains the logic for using
  /// the template vars obtained by [getTemplateVars] to generate the project
  /// from the [generator] and [template].
  Future<int> runCreate(MasonGenerator generator, Template template) async {
    var vars = getTemplateVars();

    final generateProgress = logger.progress('Bootstrapping');
    final target = DirectoryGeneratorTarget(outputDirectory);

    await generator.hooks.preGen(vars: vars, onVarsChanged: (v) => vars = v);
    final files = await generator.generate(target, vars: vars, logger: logger);
    generateProgress.complete('Generated ${files.length} file(s)');

    await template.onGenerateComplete(
      logger,
      Directory(path.join(target.dir.path, projectName)),
    );

    return ExitCode.success.code;
  }
}
