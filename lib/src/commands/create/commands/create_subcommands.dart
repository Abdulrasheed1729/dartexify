import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dartexify_cli/src/commands/create/templates/templates.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

const _defaultDescription =
    'A very nice LaTeX Project created by DarTeXify CLI.';

const _defaultTitle = 'A very nice analysis of the DarTeXify CLI.';

const _defaultAuthor = 'Plushy Dash';

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);

/// A method which returns a [Future<MasonGenerator>] given a [Brick].
typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

class CreateSubCommand extends Command<int> {
  CreateSubCommand({
    required Logger logger,
    MasonGeneratorFromBundle? generatorFromBundle,
    MasonGeneratorFromBrick? generatorFromBrick,
  })  : _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle,
        _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick,
        _logger = logger {
    argParser
      ..addOption(
        'description',
        help: 'The description for this new project.',
        aliases: ['desc'],
        defaultsTo: _defaultDescription,
      )
      ..addOption(
        'output-directory',
        help: 'The desired output directory when creating a new project.',
        abbr: 'o',
      )
      ..addOption(
        'title',
        abbr: 't',
        help: 'Topic of discussion for the project.',
      )
      ..addOption(
        'author',
        abbr: 'a',
        help: 'Name of author ',
      )
      ..addOption(
        'type',
        help: 'Project type',
        allowed: [
          ProjectType.article.name,
          ProjectType.book.name,
          ProjectType.report.name,
          ProjectType.beamer.name,
        ],
      )
      ..addFlag(
        'latexmk',
        defaultsTo: null,
      )
      ..addFlag(
        'makefile',
        defaultsTo: null,
      );
  }

  @override
  String get description => 'Create an awesome 🌟 LaTeX project.';

  @override
  String get name => 'create';

  final Logger _logger;

  final MasonGeneratorFromBundle _generatorFromBundle;

  final MasonGeneratorFromBrick _generatorFromBrick;

  ArgResults? argResultOverrides;

  /// Should return the desired template to be created during a command run.
  Template get template => DartexifyArticleTemplate();

  @override
  String get invocation => 'dartexify create $name <project-name> [arguments]';

  @override
  ArgResults get argResults => argResultOverrides ?? super.argResults!;

  /// Gets the output [Directory].
  Directory get outputDirectory {
    final directory = argResults['output-directory'] as String? ?? '.';
    return Directory(directory);
  }


  /// Gets the project name.
  String get projectName {
    final args = argResults.rest;

    if (args.isEmpty) {
      return _logger.prompt(
        'What is the project name?',
        defaultValue: 'Hello Dartexify',
      );
    }

    // _validateProjectName(args);
    return args.first;
  }

  /// Gets the project name.
  String get title {
    return argResults['title'] as String? ??
        _logger.prompt(
          'Project topic of discussion?',
          defaultValue: _defaultTitle,
        );
  }

  /// Gets the project author name.
  String get author {
    return argResults['author'] as String? ??
        _logger.prompt(
          'Name of Author?',
          defaultValue: _defaultAuthor,
        );
  }

  /// Gets the description for the project.
  String get projectDescription => argResults['description'] as String? ?? '';

  /// Checks if latexmk should be used or not.
  bool get latexmk {
    return argResults['latexmk'] as bool? ??
        _logger.confirm(
          'Include Latexmkrc?',
          defaultValue: true,
        );
  }

  /// Checks if makefile should be used or not.
  bool get makefile {
    return argResults['latexmk'] as bool? ??
        _logger.confirm(
          'Include makefile?',
          defaultValue: true,
        );
  }

  /// Gets the type of the project
  String get type =>
      argResults['type'] as String? ??
      _logger.chooseOne(
        'Select project type',
        choices: [
          ProjectType.article.name,
          ProjectType.book.name,
          ProjectType.report.name,
          ProjectType.beamer.name,
        ],
        defaultValue: ProjectType.article.name,
      );

  Future<MasonGenerator> _getGeneratorForTemplate() async {
    try {
      final brick = Brick.version(
        name: template.bundle.name,
        version: '^${template.bundle.version}',
      );
      _logger.detail(
        '''Building generator from brick: ${brick.name} ${brick.location.version}''',
      );
      return await _generatorFromBrick(brick);
    } catch (_) {
      _logger.detail('Building generator from brick failed: $_');
    }
    _logger.detail(
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
    final type = this.type;
    final title = this.title;
    final latexmk = this.latexmk;
    final makefile = this.makefile;
    final author = this.author;

    return <String, dynamic>{
      'project_name': projectName,
      'description': projectDescription,
      'type': type,
      'title': title,
      'latexmk': latexmk,
      'makefile': makefile,
      'author': author,
    };
  }

  /// Invoked by [run] to create the project, contains the logic for using
  /// the template vars obtained by [getTemplateVars] to generate the project
  /// from the [generator] and [template].
  Future<int> runCreate(MasonGenerator generator, Template template) async {
    var vars = getTemplateVars();

    final generateProgress = _logger.progress('Bootstrapping');
    final target = DirectoryGeneratorTarget(outputDirectory);

    await generator.hooks.preGen(vars: vars, onVarsChanged: (v) => vars = v);
    final files = await generator.generate(target, vars: vars, logger: _logger);
    generateProgress.complete('Generated ${files.length} file(s)');

    await template.onGenerateComplete(
      _logger,
      Directory(path.join(target.dir.path, projectName)),
    );

    return ExitCode.success.code;
  }
}


/// Specifies the diffrent type of LaTeX projects
enum ProjectType {
  article,
  book,
  report,
  beamer,
}
