import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import 'chat_list_screen.dart';

class UserPickerScreen extends ConsumerStatefulWidget {
  final List<String> excludeUserIds;
  final String title;
  final bool multiSelect;

  const UserPickerScreen({
    super.key,
    this.excludeUserIds = const [],
    this.title = 'Select Users',
    this.multiSelect = true,
  });

  @override
  ConsumerState<UserPickerScreen> createState() => _UserPickerScreenState();
}

class _UserPickerScreenState extends ConsumerState<UserPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _selectedUserIds = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchUsers(query);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final results = await chatService.searchUsers(query);
      
      // Filter out excluded users
      final filteredResults = results.where((user) {
        final userId = user['\$id'] ?? '';
        return !widget.excludeUserIds.contains(userId);
      }).toList();

      setState(() {
        _searchResults = filteredResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _toggleUser(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        if (widget.multiSelect) {
          _selectedUserIds.add(userId);
        } else {
          _selectedUserIds = [userId];
        }
      }
    });
  }

  void _onDone() {
    if (_selectedUserIds.isNotEmpty) {
      context.pop(_selectedUserIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.title),
        actions: [
          if (_selectedUserIds.isNotEmpty)
            TextButton(
              onPressed: _onDone,
              child: Text(
                widget.multiSelect ? 'Done (${_selectedUserIds.length})' : 'Select',
                style: const TextStyle(color: AppColors.defaultBlue),
              ),
            ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onSurface,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),

          // Selected users chips (if multi-select)
          if (widget.multiSelect && _selectedUserIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: _selectedUserIds.map((userId) {
                  final user = _searchResults.firstWhere(
                    (u) => u['\$id'] == userId,
                    orElse: () => {'\$id': userId, 'name': 'Selected User'},
                  );
                  
                  return Chip(
                    label: Text(user['name'] ?? 'Unknown'),
                    onDeleted: () => _toggleUser(userId),
                    backgroundColor: AppColors.subtleBlue,
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          // Search results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 16),
            Text(
              'Start typing to search users',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final userId = user['\$id'] ?? '';
        final userName = user['name'] ?? 'Unknown User';
        final userEmail = user['email'] ?? '';
        final isSelected = _selectedUserIds.contains(userId);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.subtleBlue,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.defaultBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: userEmail.isNotEmpty ? Text(userEmail) : null,
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle,
                  color: AppColors.defaultBlue,
                )
              : const Icon(
                  Icons.radio_button_unchecked,
                  color: AppColors.onSurfaceVariant,
                ),
          onTap: () {
            _toggleUser(userId);
            
            // If single select, immediately return
            if (!widget.multiSelect && _selectedUserIds.isNotEmpty) {
              _onDone();
            }
          },
        );
      },
    );
  }
}