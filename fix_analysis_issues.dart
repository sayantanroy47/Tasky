import 'dart:io';

void main() async {
  print('Fixing analysis issues...');
  
  // Fix unnecessary non-null assertions
  await fixFile('lib/services/speech/composite_transcription_service.dart', [
    ['_cloudService!.', '_cloudService.'],
  ]);
  
  // Fix unnecessary toList in spreads
  await fixFile('lib/presentation/widgets/subtask_list.dart', [
    ['.toList()', ''],
  ]);
  
  // Fix string interpolation braces
  await fixFile('lib/services/speech/voice_command_customization.dart', [
    [r'${task}', r'$task'],
  ]);
  
  // Fix prefer_is_empty
  await fixFile('lib/services/speech/voice_command_customization.dart', [
    ['.length == 0', '.isEmpty'],
  ]);
  
  // Fix sort_child_properties_last
  await fixFile('lib/presentation/pages/calendar_page.dart', [
    ['child: ', ''],
  ]);
  
  print('Fixed analysis issues');
}

Future<void> fixFile(String filePath, List<List<String>> replacements) async {
  final file = File(filePath);
  if (!await file.exists()) return;
  
  var content = await file.readAsString();
  var changed = false;
  
  for (final replacement in replacements) {
    final oldStr = replacement[0];
    final newStr = replacement[1];
    if (content.contains(oldStr)) {
      content = content.replaceAll(oldStr, newStr);
      changed = true;
    }
  }
  
  if (changed) {
    await file.writeAsString(content);
    print('Fixed: $filePath');
  }
}