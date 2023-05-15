import 'dart:io';

import 'package:dartexify_cli/src/commands/create/templates/templates.dart';
import 'package:dartexify_cli/src/logger_extension.dart';
import 'package:mason_logger/mason_logger.dart';

class DartexifyArticleTemplate extends Template {
  DartexifyArticleTemplate()
      : super(
          name: 'article',
          bundle: dartexifyArticleBundle,
          help: 'Generate a nice LaTeX article project.',
        );

  @override
  Future<void> onGenerateComplete(
    Logger logger,
    Directory outputDir,
  ) async {
    await _logSummary(logger);
  }

  Future<void> _logSummary(Logger logger) async {
    logger
      ..info('\n')
      ..created('Created a nice LaTeX article project.')
      ..info('\n');
  }
}
