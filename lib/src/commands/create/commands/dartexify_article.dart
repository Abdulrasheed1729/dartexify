// import 'package:dartexify_cli/src/commands/create/commands/create_subcommands.dart';
// import 'package:dartexify_cli/src/commands/create/templates/templates.dart';

// /// {@template very_good_create_dart_cli_command}
// /// A [CreateSubCommand] for creating Dart command line interfaces.
// /// {@endtemplate}
// class CreateDartexifyProject extends CreateSubCommand {
//   /// {@macro very_good_create_dart_cli_command}
//   CreateDartexifyProject({
//     required super.logger,
//     required super.generatorFromBundle,
//     required super.generatorFromBrick,
//   });

//   @override
//   String get name => 'article';

//   @override
//   String get description => 'Generate a nice LaTeX article project.';

//   @override
//   Template get template => DartexifyArticleTemplate();

//   @override
//   Map<String, dynamic> getTemplateVars() {
//     final vars = super.getTemplateVars();

//     final name = argResults['project_name'] as String? ?? projectName;
//     final projectTitle = argResults['title'] as String? ?? title;
//     final projectType = argResults['type'] as String? ?? type;
//     final projectAuthor = argResults['author'] as String? ?? author;
//     final description =
//         argResults['descrition'] as String? ?? projectDescription;
//     final useLatexmk = argResults['latexmk'] as bool? ?? latexmk;
//     final useMakefile = argResults['makefile'] as bool? ?? makefile;

//     vars['project_name'] = name;
//     vars['title'] = projectTitle;
//     vars['type'] = projectType;
//     vars['author'] = projectAuthor;
//     vars['description'] = description;
//     vars['latexmk'] = useLatexmk;
//     vars['makefile'] = useMakefile;

//     return vars;
//   }
// }
