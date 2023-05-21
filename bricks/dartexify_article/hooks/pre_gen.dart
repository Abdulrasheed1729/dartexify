import 'package:mason/mason.dart';

void run(HookContext context) {
  // Read author name
  final author = context.vars['author'];

  // Read project title
  final description = context.vars['description'];

  // update the author name
  context.vars['author'] = '{$author}';

  // update the title
  context.vars['description'] = '{$description}';
}
