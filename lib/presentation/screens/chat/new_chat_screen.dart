import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth/auth_provider.dart';
import 'chat_conversation_screen.dart';
import 'chat_list_screen.dart';

final userSearchProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  final chatService = ref.read(chatServiceProvider);
  return await chatService.searchUsers(query);
});

final recentContactsProvider = FutureProvider<List<String>>((ref) async {
  final chatService = ref.read(chatServiceProvider);
  final authState = ref.read(authStateProvider);
  
  if (authState.user == null) return [];
  
  return await chatService.getRecentContacts(authState.user!.id);
});

final departmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final chatService = ref.read(chatServiceProvider);
  return await chatService.getDepartments();
});

final teamsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final chatService = ref.read(chatServiceProvider);
  return await chatService.getTeams();
});

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  final List<String> _selectedUserIds = [];
  final Map<String, Map<String, dynamic>> _selectedUserData = {};
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
        title: const Text('New Chat'),
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
                  : Text(_selectedUserIds.length == 1 ? 'Message' : 'Create Group'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Selected users tags + Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selected users chips
                if (_selectedUserIds.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedUserIds.map((userId) {
                        final userData = _selectedUserData[userId];
                        final userName = userData?['name'] ?? userId;
                        
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: AppColors.subtleBlue,
                            radius: 12,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppColors.defaultBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          label: Text(userName),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeSelectedUser(userId),
                          backgroundColor: AppColors.subtleBlue,
                          deleteIconColor: AppColors.defaultBlue,
                        );
                      }).toList(),
                    ),
                  ),
                ],
                
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _selectedUserIds.isEmpty 
                        ? 'Search for people...' 
                        : 'Add more people...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.gray100,
                  ),
                ),
              ],
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
    final recentContactsAsync = ref.watch(recentContactsProvider);
    
    return recentContactsAsync.when(
      data: (contactIds) {
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
            if (contactIds.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No recent contacts',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              )
            else
              ...contactIds.map((userId) {
                final isSelected = _selectedUsers.contains(userId);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.subtleBlue,
                    child: Text(
                      userId.isNotEmpty ? userId[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.defaultBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(userId), // TODO: Show actual user name
                  trailing: widget.isGroupChat
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            if (value == true) {
                              _addSelectedUser(userId);
                            } else {
                              _removeSelectedUser(userId);
                            }
                          },
                        )
                      : null,
                  onTap: () {
                    if (widget.isGroupChat) {
                      if (isSelected) {
                        _removeSelectedUser(userId);
                      } else {
                        _addSelectedUser(userId);
                      }
                    } else {
                      _createDirectChat(userId);
                    }
                  },
                );
              }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ListView(
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Failed to load recent contacts: $error',
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListView(List<Map<String, dynamic>> users) {
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
        final userId = user['\$id'] ?? '';
        final userName = user['name'] ?? 'Unknown User';
        final userEmail = user['email'] ?? '';
        final isSelected = _selectedUsers.contains(userId);

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
          title: Text(userName),
          subtitle: userEmail.isNotEmpty ? Text(userEmail) : null,
          trailing: widget.isGroupChat
              ? Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      _addSelectedUser(userId);
                    } else {
                      _removeSelectedUser(userId);
                    }
                  },
                )
              : null,
          onTap: () {
            if (widget.isGroupChat) {
              if (isSelected) {
                _removeSelectedUser(userId);
              } else {
                _addSelectedUser(userId);
              }
            } else {
              _createDirectChat(userId);
            }
          },
        );
      },
    );
  }

  Widget _buildDepartmentsList() {
    final departmentsAsync = ref.watch(departmentsProvider);
    
    return departmentsAsync.when(
      data: (departments) {
        if (departments.isEmpty) {
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
                  'No departments available',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: departments.length,
          itemBuilder: (context, index) {
            final department = departments[index];
            final departmentId = department['\$id'] ?? '';
            final departmentName = department['name'] ?? 'Unknown Department';
            final description = department['description'] ?? '';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.orange9,
                child: Icon(
                  Icons.business,
                  color: Colors.white,
                ),
              ),
              title: Text(departmentName),
              subtitle: description.isNotEmpty ? Text(description) : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _createDepartmentChat(departmentId, departmentName),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load departments: $error',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsList() {
    final teamsAsync = ref.watch(teamsProvider);
    
    return teamsAsync.when(
      data: (teams) {
        if (teams.isEmpty) {
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
                  'No teams available',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            final teamId = team['\$id'] ?? '';
            final teamName = team['name'] ?? 'Unknown Team';
            final description = team['description'] ?? '';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.purple9,
                child: Icon(
                  Icons.groups,
                  color: Colors.white,
                ),
              ),
              title: Text(teamName),
              subtitle: description.isNotEmpty ? Text(description) : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _createTeamChat(teamId, teamName),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load teams: $error',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  Future<void> _createDepartmentChat(String departmentId, String departmentName) async {
    setState(() {
      _isCreating = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final currentUserId = ref.read(authStateProvider).user!.id;

      final chat = await chatService.createDepartmentChat(
        name: departmentName,
        departmentId: departmentId,
        participants: [currentUserId],
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create department chat: ${e.toString()}'),
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

  Future<void> _createTeamChat(String teamId, String teamName) async {
    setState(() {
      _isCreating = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final currentUserId = ref.read(authStateProvider).user!.id;

      final chat = await chatService.createTeamChat(
        name: teamName,
        teamId: teamId,
        participants: [currentUserId],
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create team chat: ${e.toString()}'),
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