import '../../features/settings/domain/entities/shortcut_entity.dart';
import '../constants/defaults.dart';

/// Result of parsing a raw task input string.
class ParseResult {
  /// The cleaned task title (prefix and separator stripped).
  final String title;

  /// The matched category ID, or [Defaults.inboxCategoryId] if no match.
  final String categoryId;

  /// The matched category name, or [Defaults.inboxCategoryName] if no match.
  final String categoryName;

  const ParseResult({
    required this.title,
    required this.categoryId,
    required this.categoryName,
  });
}

/// Pure function: parse raw user input and match against defined shortcuts.
///
/// Supports prefixes of any length (single-char like "K" or multi-char like "pay").
/// Recognizes separators: ` - `, ` : `, or a single space after the prefix.
///
/// Examples:
///   "K - Buy milk"          → title: "Buy milk",         category: "Kitchen"
///   "pay - electricity bill" → title: "electricity bill", category: matched to "pay" shortcut
///   "Just a random task"    → title: "Just a random task", category: "Inbox"
ParseResult parseTaskInput(String rawInput, List<ShortcutEntity> shortcuts) {
  final trimmed = rawInput.trim();
  if (trimmed.isEmpty) {
    return const ParseResult(
      title: '',
      categoryId: Defaults.inboxCategoryId,
      categoryName: Defaults.inboxCategoryName,
    );
  }

  // Separator patterns, ordered by specificity (most specific first).
  const separators = [' - ', ' : ', ': ', '- '];

  // Try each separator.
  for (final sep in separators) {
    final sepIndex = trimmed.indexOf(sep);
    if (sepIndex > 0) {
      final potentialPrefix = trimmed.substring(0, sepIndex).trim();
      final match = _findMatch(potentialPrefix, shortcuts);
      if (match != null) {
        final title = trimmed.substring(sepIndex + sep.length).trim();
        return ParseResult(
          title: title.isNotEmpty ? title : trimmed,
          categoryId: match.id,
          categoryName: match.categoryName,
        );
      }
    }
  }

  // Fallback: check if the first token (space-separated) is a registered prefix.
  // Only match if there are more words after it (to avoid consuming single-word tasks).
  final spaceIndex = trimmed.indexOf(' ');
  if (spaceIndex > 0) {
    final firstToken = trimmed.substring(0, spaceIndex).trim();
    final rest = trimmed.substring(spaceIndex + 1).trim();
    if (rest.isNotEmpty) {
      final match = _findMatch(firstToken, shortcuts);
      if (match != null) {
        return ParseResult(
          title: rest,
          categoryId: match.id,
          categoryName: match.categoryName,
        );
      }
    }
  }

  // No match found → Inbox.
  return ParseResult(
    title: trimmed,
    categoryId: Defaults.inboxCategoryId,
    categoryName: Defaults.inboxCategoryName,
  );
}

/// Case-insensitive prefix lookup.
ShortcutEntity? _findMatch(String token, List<ShortcutEntity> shortcuts) {
  final lower = token.toLowerCase();
  for (final shortcut in shortcuts) {
    if (shortcut.prefix.toLowerCase() == lower) {
      return shortcut;
    }
  }
  return null;
}
