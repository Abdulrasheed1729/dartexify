import 'package:dartexify_cli/src/commands/create/commands/create_subcommands.dart';
import 'package:dartexify_cli/src/commands/create/templates/template.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

class MockTemplate extends Mock implements CreateSubCommand {}

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

  
}
