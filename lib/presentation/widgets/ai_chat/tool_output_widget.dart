import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/ai_chat_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/ai_chat_service.dart';

class ToolOutputWidget extends StatefulWidget {
  final ToolPart toolPart;
  final bool isDark;

  const ToolOutputWidget({
    super.key,
    required this.toolPart,
    this.isDark = false,
  });

  @override
  State<ToolOutputWidget> createState() => _ToolOutputWidgetState();
}

class _ToolOutputWidgetState extends State<ToolOutputWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  final AiChatService _chatService = AiChatService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: (widget.isDark ? AppColors.surfaceDark : AppColors.white)
                .withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (widget.isDark ? AppColors.outlineDark : AppColors.outline)
                  .withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark ? AppColors.shadowHeavy : AppColors.shadowLight)
                    .withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildToolContent(theme),
        ),
      ),
    );
  }

  Widget _buildToolContent(ThemeData theme) {
    switch (widget.toolPart.state) {
      case ToolPartState.inputStreaming:
      case ToolPartState.inputAvailable:
        return _buildLoadingState(theme);
      case ToolPartState.outputAvailable:
        return _buildSuccessState(theme);
      case ToolPartState.outputError:
        return _buildErrorState(theme);
    }
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildToolIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getToolDisplayName(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLoadingMessage(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.crystalBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLoadingSpinner(),
            ],
          ),
          const SizedBox(height: 12),
          _buildLoadingProgress(theme),
        ],
      ),
    );
  }

  Widget _buildLoadingSpinner() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value * 2 * 3.14159,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  AppColors.crystalBlue,
                  AppColors.emeraldGreen,
                ],
              ),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.white,
              size: 14,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingProgress(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.crystalBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.crystalBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getToolIcon(),
            color: AppColors.crystalBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProgressDescription(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                _buildProgressBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: null, // Indeterminate
          backgroundColor: AppColors.crystalBlue.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.crystalBlue.withOpacity(0.8),
          ),
          minHeight: 3,
        );
      },
    );
  }

  String _getLoadingMessage() {
    switch (widget.toolPart.toolName) {
      case 'searchSharePoint':
        return 'Searching SharePoint documents...';
      case 'getDocumentStats':
        return 'Analyzing document statistics...';
      case 'listSharePointSites':
        return 'Fetching SharePoint sites...';
      case 'weather':
        return 'Getting weather information...';
      default:
        return 'Executing ${widget.toolPart.toolName}...';
    }
  }

  String _getProgressDescription() {
    switch (widget.toolPart.toolName) {
      case 'searchSharePoint':
        return 'Querying Pinecone vector database for relevant documents';
      case 'getDocumentStats':
        return 'Calculating document counts and indexing statistics';
      case 'listSharePointSites':
        return 'Retrieving available SharePoint sites and permissions';
      case 'weather':
        return 'Fetching current weather conditions';
      default:
        return 'Processing your request';
    }
  }

  IconData _getToolIcon() {
    switch (widget.toolPart.toolName) {
      case 'searchSharePoint':
        return Icons.search_rounded;
      case 'getDocumentStats':
        return Icons.analytics_rounded;
      case 'listSharePointSites':
        return Icons.web_rounded;
      case 'weather':
        return Icons.cloud_rounded;
      default:
        return Icons.extension_rounded;
    }
  }

  Widget _buildSuccessState(ThemeData theme) {
    final result = widget.toolPart.result;
    if (result == null) return _buildErrorState(theme);

    switch (widget.toolPart.toolName) {
      case 'searchSharePoint':
        return _buildSharePointResults(theme, result);
      case 'getDocumentStats':
        return _buildDocumentStats(theme, result);
      case 'listSharePointSites':
        return _buildSharePointSites(theme, result);
      case 'weather':
        return _buildWeatherWidget(theme, result);
      default:
        return _buildDynamicToolResult(theme, result);
    }
  }

  Widget _buildErrorState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getToolDisplayName(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Error occurred while executing tool',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharePointResults(ThemeData theme, Map<String, dynamic> result) {
    try {
      final response = SharePointSearchResponse.fromJson(result);
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolHeader(theme, '${response.results.length} results found'),
          if (response.message.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.emeraldGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.emeraldGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.emeraldGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      response.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (response.results.isEmpty)
            _buildNoResultsState(theme)
          else ...[
            _buildSearchStats(theme, response),
            ...response.results.take(5).map((searchResult) {
              return _buildSearchResultCard(theme, searchResult);
            }),
            if (response.results.length > 5)
              _buildMoreResultsCard(theme, response.results.length - 5),
          ],
        ],
      );
    } catch (e) {
      return _buildErrorState(theme);
    }
  }

  Widget _buildNoResultsState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.stoneGray : AppColors.surfaceVariant)
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (widget.isDark ? AppColors.outlineDark : AppColors.outline)
              .withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppColors.onSurfaceVariant,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No documents found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try rephrasing your query or using different keywords',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchStats(ThemeData theme, SharePointSearchResponse response) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.crystalBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.crystalBlue.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics_rounded,
            color: AppColors.crystalBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Query: "${response.query}" (${response.queryLanguage.toUpperCase()})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreResultsCard(ThemeData theme, int moreCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sunGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.sunGold.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.expand_more_rounded,
            color: AppColors.sunGold,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '+ $moreCount additional results found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Ask for more details',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.sunGold,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(ThemeData theme, SharePointResult result) {
    final scoreColor = _getScoreColor(result.score);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.surfaceDark : AppColors.white)
            .withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: result.documentViewerUrl != null 
              ? () => _launchUrl(result.documentViewerUrl!)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: scoreColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.crystalBlue,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildScoreBadge(theme, result.score, scoreColor),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (widget.isDark ? AppColors.stoneGray : AppColors.surfaceVariant)
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.domain_rounded,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        result.site,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (result.lastModified.isNotEmpty) ...[
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(result.lastModified),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                if (result.documentViewerUrl != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.crystalBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.crystalBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.open_in_new_rounded,
                                color: AppColors.crystalBlue,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Open Document',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.crystalBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(ThemeData theme, double score, Color scoreColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scoreColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getScoreIcon(score),
            color: scoreColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            '${(score * 100).toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppColors.emeraldGreen;
    if (score >= 0.6) return AppColors.sunGold;
    if (score >= 0.4) return AppColors.warmGold;
    return AppColors.onSurfaceVariant;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 0.8) return Icons.star_rounded;
    if (score >= 0.6) return Icons.star_half_rounded;
    return Icons.star_border_rounded;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else {
        return '${(difference.inDays / 365).floor()}y ago';
      }
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDocumentStats(ThemeData theme, Map<String, dynamic> result) {
    try {
      final response = DocumentStatsResponse.fromJson(result);
      
      return Column(
        children: [
          _buildToolHeader(theme, 'Document Statistics'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Documents',
                    response.totalDocuments.toString(),
                    Icons.description_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Chunks',
                    response.totalChunks.toString(),
                    Icons.data_object_rounded,
                  ),
                ),
              ],
            ),
          ),
          if (response.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                response.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      );
    } catch (e) {
      return _buildErrorState(theme);
    }
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crystalBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.crystalBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.crystalBlue,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.crystalBlue,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharePointSites(ThemeData theme, Map<String, dynamic> result) {
    try {
      final response = SharePointSitesResponse.fromJson(result);
      
      return Column(
        children: [
          _buildToolHeader(theme, '${response.sites.length} SharePoint Sites'),
          ...response.sites.map((site) {
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.crystalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.web_rounded,
                  color: AppColors.crystalBlue,
                  size: 20,
                ),
              ),
              title: Text(
                site.displayName,
                style: theme.textTheme.titleSmall,
              ),
              subtitle: Text(
                site.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              trailing: IconButton(
                onPressed: () => _launchUrl(site.webUrl),
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            );
          }),
        ],
      );
    } catch (e) {
      return _buildErrorState(theme);
    }
  }

  Widget _buildWeatherWidget(ThemeData theme, Map<String, dynamic> result) {
    try {
      final response = WeatherResponse.fromJson(result);
      
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.skyBlue, AppColors.crystalBlue],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cloud_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response.location,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    response.temperature,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.crystalBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return _buildErrorState(theme);
    }
  }

  Widget _buildDynamicToolResult(ThemeData theme, Map<String, dynamic> result) {
    return Column(
      children: [
        _buildToolHeader(theme, 'Tool Result'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (widget.isDark ? AppColors.stoneGray : AppColors.surfaceVariant)
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (widget.isDark ? AppColors.outlineDark : AppColors.outline)
                      .withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Raw JSON Result',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _formatJson(result),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Courier',
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolHeader(ThemeData theme, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: (widget.isDark ? AppColors.outlineDark : AppColors.outline)
                .withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildToolIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getToolDisplayName(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.emeraldGreen,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon() {
    final icon = _getToolIcon();
    final color = _getToolIconColor();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Color _getToolIconColor() {
    switch (widget.toolPart.toolName) {
      case 'searchSharePoint':
        return AppColors.crystalBlue;
      case 'getDocumentStats':
        return AppColors.emeraldGreen;
      case 'listSharePointSites':
        return AppColors.warmGold;
      case 'weather':
        return AppColors.skyBlue;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _getToolDisplayName() {
    switch (widget.toolPart.toolName) {
      case 'searchSharePoint':
        return 'SharePoint Search';
      case 'getDocumentStats':
        return 'Document Statistics';
      case 'listSharePointSites':
        return 'SharePoint Sites';
      case 'weather':
        return 'Weather';
      default:
        return widget.toolPart.toolName;
    }
  }

  String _formatJson(Map<String, dynamic> json) {
    return json.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
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