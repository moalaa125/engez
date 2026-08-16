import 'dart:io';

void main() {
  final dir = Directory(r'c:\flutter\Engez\lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') && !f.path.contains('my_colors.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    String originalContent = content;

    // We need to add import 'package:engez/constants/my_colors.dart'; if we make changes and it's not there.
    bool needsImport = false;

    // Helper to replace with regex
    String replace(String pattern, String replacement, {bool requireImport = true}) {
      final regExp = RegExp(pattern);
      if (regExp.hasMatch(content)) {
        content = content.replaceAll(regExp, replacement);
        if (requireImport) needsImport = true;
      }
      return content;
    }

    content = replace(r'Colors\.white', 'MyColors.myWhite');
    content = replace(r'Colors\.orange', 'MyColors.myOrange');
    content = replace(r'Colors\.deepOrange', 'MyColors.myOrange');
    content = replace(r'Colors\.red', 'MyColors.myError');
    content = replace(r'Colors\.green', 'MyColors.mySuccess');
    
    // Grey logic:
    // colors like Colors.grey[200], Colors.grey[300], Colors.grey.shade300 -> MyColors.myBorder
    content = replace(r'Colors\.grey\[[1234]00\]', 'MyColors.myBorder');
    content = replace(r'Colors\.grey\.shade[1234]00', 'MyColors.myBorder');
    
    // colors like Colors.grey, Colors.grey[500], Colors.grey[600], etc -> MyColors.myTextSecondary
    content = replace(r'Colors\.grey\[[56789]00\]', 'MyColors.myTextSecondary');
    content = replace(r'Colors\.grey\.shade[56789]00', 'MyColors.myTextSecondary');
    content = replace(r'Colors\.grey(?!\[|\.shade)', 'MyColors.myTextSecondary');

    // Black logic:
    // Only replace Colors.black if NOT inside BoxShadow or followed by .withValues / .withOpacity
    // We'll do this with a bit more complex regex or just manually handling it.
    // Actually, looking at the code, Colors.black is mostly used in BoxShadow or Text.
    // Let's replace Colors.black87 with MyColors.myDarkText
    content = replace(r'Colors\.black87', 'MyColors.myDarkText');
    content = replace(r'Colors\.black54', 'MyColors.myTextSecondary');
    
    // For Colors.black, if it's color: Colors.black.withValues, we leave it.
    // We will replace `color: Colors.black,` -> `color: MyColors.myDarkText,`
    content = replace(r'color:\s*Colors\.black\s*,', 'color: MyColors.myDarkText,');
    
    // Colors.black in TextStyles etc.
    content = replace(r'color:\s*Colors\.black\s*\)', 'color: MyColors.myDarkText)');

    if (content != originalContent) {
      if (needsImport && !content.contains('my_colors.dart')) {
        // add import at the top
        content = "import 'package:engez/constants/my_colors.dart';\n" + content;
      }
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
