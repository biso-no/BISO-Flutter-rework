import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth/auth_provider.dart';
import 'chat_conversation_screen.dart';
import 'chat_list_screen.dart';

final userSearchProvider = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  // TODO: Implement user search via Appwrite
  await Future.delayed(const Duration(milliseconds: 500));
  return [];
});

final departmentUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, departmentId) async {
  // TODO: Implement department user fetching
  await Future.delayed(const Duration(milliseconds: 500));
  return [];
});

class NewChatScreen extends ConsumerStatefulWidget {
  final bool isGroupChat;

  const NewChatScreen({
    super.key,
    this.isGroupChat = false,
  });

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  
  String _searchQuery = '';
  final List<String> _selectedUsers = [];
  bool _isCreating = false;
  String _selectedTab = 'users';

  final List<String> _tabs = ['users', 'departments', 'teams'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (authState.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroupChat ? 'New Group Chat' : 'New Chat'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          if (_canCreateChat())
            TextButton(
              onPressed: _isCreating ? null : _createChat,
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Group name input (only for group chats)
          if (widget.isGroupChat) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: 'Group name (optional)',
                  prefixIcon: const Icon(Icons.group),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const Divider(height: 1),
          ],

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for people...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.gray100,
              ),
            ),
          ),

          // Tab selector
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = _selectedTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.defaultBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _getTabDisplayName(tab),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Selected users chips (for group chats)
          if (widget.isGroupChat && _selectedUsers.isNotEmpty) ...[
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedUsers.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final userId = _selectedUsers[index];
                  return Chip(
                    label: Text(userId), // TODO: Show actual user name
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeSelectedUser(userId),
                    backgroundColor: AppColors.subtleBlue,
                    deleteIconColor: AppColors.defaultBlue,
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],

          // User list
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  String _getTabDisplayName(String tab) {
    switch (tab) {
      case 'users': return 'People';
      case 'departments': return 'Departments';
      case 'teams': return 'Teams';
      default: return tab;
    }
  }

  Widget _buildUserList() {
    if (_selectedTab == 'users') {
      if (_searchQuery.isEmpty) {
        return _buildRecentContacts();
      } else {
        final usersAsync = ref.watch(userSearchProvider(_searchQuery));
        return usersAsync.when(
          data: (users) => _buildUserListView(users),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: ${error.toString()}'),
          ),
        );
      }
    } else if (_selectedTab == 'departments') {
      return _buildDepartmentsList();
    } else {
      return _buildTeamsList();
    }
  }

  Widget _buildRecentContacts() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recent Contacts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        // TODO: Implement recent contacts from chat history
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'No recent contacts',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserListView(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelected = _selectedUsers.contains(user.id);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            backgroundColor: AppColors.gray300,
            child: user.avatarUrl == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: widget.isGroupChat
              ? Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      _addSelectedUser(user.id);
                    } else {
                      _removeSelectedUser(user.id);
                    }
                  },
                )
              : null,
          onTap: () {
            if (widget.isGroupChat) {
              if (isSelected) {
                _removeSelectedUser(user.id);
              } else {
                _addSelectedUser(user.id);
              }
            } else {
              _createDirectChat(user.id);
            }
          },
        );
      },
    );
  }

  Widget _buildDepartmentsList() {
    // TODO: Implement departments list
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.business,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(height: 16),
          Text(
            'Department chats coming soon',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsList() {
    // TODO: Implement teams list
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.groups,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(height: 16),
          Text(
            'Team chats coming soon',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _addSelectedUser(String userId) {
    setState(() {
      if (!_selectedUsers.contains(userId)) {
        _selectedUsers.add(userId);
      }
    });
  }

  void _removeSelectedUser(String userId) {
    setState(() {
      _selectedUsers.remove(userId);
    });
  }

  bool _canCreateChat() {
    if (widget.isGroupChat) {
      return _selectedUsers.length >= 2;
    } else {
      return false; // Direct chats are created by tapping on a user
    }
  }

  Future<void> _createChat() async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final currentUserId = ref.read(authStateProvider).user!.id;

      if (widget.isGroupChat) {
        final groupName = _groupNameController.text.trim().isNotEmpty
            ? _groupNameController.text.trim()
            : 'Group Chat';

        final participants = [..._selectedUsers, currentUserId];

        final chat = await chatService.createGroupChat(
          name: groupName,
          participants: participants,
          createdBy: currentUserId,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationScreen(chat: chat),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create chat: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _createDirectChat(String userId) async {
    setState(() {
      _isCreating = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final currentUserId = ref.read(authStateProvider).user!.id;

      final chat = await chatService.createDirectChat(
        participants: [currentUserId, userId],
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(chat: chat),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create chat: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}