import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MarkdownText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = style ?? theme.textTheme.bodyLarge;
    
    return RichText(
      text: _parseMarkdown(text, defaultStyle!, theme),
    );
  }

  TextSpan _parseMarkdown(String text, TextStyle defaultStyle, ThemeData theme) {
    final List<TextSpan> spans = [];
    final RegExp markdownPattern = RegExp(
      r'(\*\*.*?\*\*|\*.*?\*|`.*?`|\[.*?\]\(.*?\)|```[\s\S]*?```)',
      multiLine: true,
    );

    int lastEnd = 0;
    
    for (final match in markdownPattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: defaultStyle,
        ));
      }
      
      final matchText = match.group(0)!;
      
      if (matchText.startsWith('```') && matchText.endsWith('```')) {
        // Code block
        spans.add(_createCodeBlockSpan(matchText, theme));
      } else if (matchText.startsWith('**') && matchText.endsWith('**')) {
        // Bold text
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (matchText.startsWith('*') && matchText.endsWith('*')) {
        // Italic text
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: defaultStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (matchText.startsWith('`') && matchText.endsWith('`')) {
        // Inline code
        spans.add(_createInlineCodeSpan(matchText, theme));
      } else if (matchText.startsWith('[') && matchText.contains('](')) {
        // Link
        spans.add(_createLinkSpan(matchText, defaultStyle, theme));
      } else {
        // Fallback: add as regular text
        spans.add(TextSpan(text: matchText, style: defaultStyle));
      }
      
      lastEnd = match.end;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: defaultStyle,
      ));
    }
    
    return TextSpan(children: spans);
  }

  TextSpan _createCodeBlockSpan(String text, ThemeData theme) {
    final codeContent = text.substring(3, text.length - 3).trim();
    final isDark = theme.brightness == Brightness.dark;
    
    return TextSpan(
      text: '\n$codeContent\n',
      style: TextStyle(
        fontFamily: 'Courier',
        fontSize: 14,
        color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
        backgroundColor: isDark 
            ? AppColors.stoneGray.withOpacity(0.3)
            : AppColors.surfaceVariant.withOpacity(0.5),
      ),
    );
  }

  TextSpan _createInlineCodeSpan(String text, ThemeData theme) {
    final codeContent = text.substring(1, text.length - 1);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextSpan(
      text: codeContent,
      style: TextStyle(
        fontFamily: 'Courier',
        fontSize: 14,
        color: AppColors.crystalBlue,
        backgroundColor: isDark 
            ? AppColors.stoneGray.withOpacity(0.3)
            : AppColors.surfaceVariant.withOpacity(0.5),
      ),
    );
  }

  TextSpan _createLinkSpan(String text, TextStyle defaultStyle, ThemeData theme) {
    final linkRegex = RegExp(r'\[(.*?)\]\((.*?)\)');
    final match = linkRegex.firstMatch(text);
    
    if (match == null) {
      return TextSpan(text: text, style: defaultStyle);
    }
    
    final linkText = match.group(1)!;
    final url = match.group(2)!;
    
    return TextSpan(
      text: linkText,
      style: defaultStyle.copyWith(
        color: AppColors.crystalBlue,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.crystalBlue,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () => _launchUrl(url),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $url, Error: $e');
    }
  }
}