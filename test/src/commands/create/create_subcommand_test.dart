import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dartexify_cli/src/commands/create/commands/create_subcommands.dart';
import 'package:dartexify_cli/src/commands/create/templates/template.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

class MockTemplate extends Mock implements Template {}

class MockLogger extends Mock implements Logger {}

class MockProgress extends Mock implements Progress {}

class MockMasonGenerator extends Mock implements MasonGenerator {}

class MockBundle extends Mock implements MasonBundle {}

class MockGeneratorHooks extends Mock implements GeneratorHooks {}

class FakeLogger extends Fake implements Logger {}

class FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

class FakeDirectory extends Fake implements Directory {}

class _TestCreateSubCommand extends CreateSubCommand {
  _TestCreateSubCommand({
    required this.template,
    required super.logger,
    required super.generatorFromBundle,
    required super.generatorFromBrick,
  });

  @override
  final String name = 'create_subcommand';

  @override
  final String description = 'Create command';

  @override
  final Template template;
}

class _TestCommandRunner extends CommandRunner<int> {
  _TestCommandRunner({
    required this.command,
  }) : super('runner', 'Test command runner') {
    addCommand(command);
  }

  final Command<int> command;
}

void main() {
  final generatedFiles = List.filled(
    12,
    const GeneratedFile.created(path: 'path'),
  );

  late List<String> progressLogs;
  late Logger logger;
  late Progress progress;

  setUpAll(() {
    registerFallbackValue(FakeDirectoryGeneratorTarget());
    registerFallbackValue(FakeLogger());
    registerFallbackValue(FakeDirectory());
  });

  setUp(() {
    progressLogs = <String>[];

    logger = MockLogger();

    progress = MockProgress();
    when(() => progress.complete(any())).thenAnswer((_) {
      final message = _.positionalArguments.elementAt(0) as String?;
      if (message != null) progressLogs.add(message);
    });
    when(() => logger.progress(any())).thenReturn(progress);
  });

  group('CreateSubCommand', () {
    const expectedUsage = '''
Usage: dartexify create article <project-name> [arguments]
-h, --help                Print this usage information.
    --author              Name of author.
    --description                     The description (subject matter) for this new project. E.g. (A Dart method for Analysing the Cauchy Differential Equation)
-o, --output-directory    The desired output directory when creating a new project.

Run "dartexify help" to see global options.
''';
    late Template template;
    late MockBundle bundle;

    setUp(() {
      bundle = MockBundle();
      when(() => bundle.name).thenReturn('test');
      when(() => bundle.description).thenReturn('Test bundle');
      when(() => bundle.name).thenReturn('<bundleversion>');

      template = MockTemplate();
      when(() => template.name).thenReturn('test');
      when(() => template.bundle).thenReturn(bundle);
      when(() => template.onGenerateComplete(any(), any())).thenAnswer(
        (_) async {},
      );
    });

    group('can be instantiated', () {
      test('with default options', () {
        final command = _TestCreateSubCommand(
          template: template,
          logger: logger,
          generatorFromBundle: null,
          generatorFromBrick: null,
        );
        expect(command.name, isNotNull);
        expect(command.name, isNotNull);
        expect(command.argParser.options, {
          'help': isA<Option>(),
          'author': isA<Option>().having((p0) => p0.abbr, 'abbr', null).having(
                (p0) => p0.mandatory,
                'mandatory',
                false,
              ),
          'output-directory': isA<Option>()
              .having(
                (p0) => p0.isSingle,
                'isSingle',
                true,
              )
              .having(
                (p0) => p0.abbr,
                'abbr',
                'o',
              )
              .having(
                (p0) => p0.mandatory,
                'mandatory',
                false,
              ),
          'description': isA<Option>()
              .having(
                (p0) => p0.isSingle,
                'isSingle',
                true,
              )
              .having((p0) => p0.abbr, 'abbr', null)
              .having((p0) => p0.aliases, 'aliases', ['desc']).having(
            (p0) => p0.mandatory,
            'mandatory',
            false,
          ),
        });
        expect(command.argParser.commands, isEmpty);
      });
    });

    group('running command', () {
      late GeneratorHooks hooks;
      late MasonGenerator generator;

      late _TestCommandRunner runner;

      setUp(() {
        hooks = MockGeneratorHooks();
        generator = MockMasonGenerator();

        when(() => generator.hooks).thenReturn(hooks);

        when(
          () => hooks.preGen(
            vars: any(named: 'vars'),
            onVarsChanged: any(named: 'onVarsChanged'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => generator.generate(
            any(),
            vars: any(named: 'vars'),
            logger: any(named: 'logger'),
          ),
        ).thenAnswer((_) async {
          return generatedFiles;
        });

        when(() => generator.id).thenReturn('generator_id');
        when(() => generator.description).thenReturn('generator description');
        when(() => generator.hooks).thenReturn(hooks);

        when(
          () => hooks.preGen(
            vars: any(named: 'vars'),
            onVarsChanged: any(named: 'onVarsChanged'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => generator.generate(
            any(),
            vars: any(named: 'vars'),
            logger: any(named: 'logger'),
          ),
        ).thenAnswer((_) async {
          return generatedFiles;
        });

        final command = _TestCreateSubCommand(
          template: template,
          logger: logger,
          generatorFromBundle: (_) async => throw Exception('oops'),
          generatorFromBrick: (_) async => generator,
        );

        runner = _TestCommandRunner(command: command);

        group('parsing of options', () {
          test('parses author, description, output dir and project name',
              () async {
            final result = await runner.run([
              'create_subcommand',
              'test_project',
              '--description',
              'test_desc',
              'author',
              'test_author',
              '--output-directory',
              'test_dir'
            ]);

            expect(result, equals(ExitCode.success.code));

            verify(() => logger.progress('Bootstrapping')).called(1);
            verify(
              () => hooks.preGen(
                vars: <String, dynamic>{
                  'project_name': 'test_project',
                  'description': 'test_desc',
                  'author': 'test_author',
                },
                onVarsChanged: any(named: 'onVarsChanged'),
              ),
            );

            verify(
              () => generator.generate(
                any(
                  that: isA<DirectoryGeneratorTarget>().having(
                    (g) => g.dir.path,
                    'dir',
                    'test_dir',
                  ),
                ),
                vars: <String, dynamic>{
                  'project_name': 'test_project',
                  'description': 'test_desc',
                  'author': 'test_author',
                },
                logger: logger,
              ),
            ).called(1);

            expect(
              progressLogs,
              equals(['Generated ${generatedFiles.length} file(s)']),
            );

            verify(
              () => template.onGenerateComplete(
                logger,
                any(
                  that: isA<Directory>().having(
                    (d) => d.path,
                    'path',
                    'test_dir/test_project',
                  ),
                ),
              ),
            ).called(1);
          });
        });
      });
    });
  });
}
