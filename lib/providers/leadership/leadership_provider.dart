import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/board_member_model.dart';
import '../../data/services/leadership_service.dart';

// State class for board members
class BoardMembersState {
  final bool isLoading;
  final BoardMembersResponse? response;
  final String? error;

  const BoardMembersState({
    this.isLoading = false,
    this.response,
    this.error,
  });

  BoardMembersState copyWith({
    bool? isLoading,
    BoardMembersResponse? response,
    String? error,
  }) {
    return BoardMembersState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get hasData => response != null && response!.success;
  List<BoardMemberModel> get members => response?.members ?? [];
  int get memberCount => response?.count ?? 0;
}

// Provider for fetching board members for a specific campus
final boardMembersProvider = FutureProvider.family<BoardMembersResponse, String>((ref, campusId) async {
  return await LeadershipService.getBoardMembers(campusId: campusId);
});

// Provider for fetching board members with optional department filter
final boardMembersWithDepartmentProvider = FutureProvider.family<BoardMembersResponse, BoardMembersParams>((ref, params) async {
  return await LeadershipService.getBoardMembers(
    campusId: params.campusId,
    departmentId: params.departmentId,
  );
});

// Provider for fetching all campus board members
final allCampusBoardMembersProvider = FutureProvider<Map<String, BoardMembersResponse>>((ref) async {
  return await LeadershipService.getAllCampusBoardMembers();
});

// State notifier for managing board members state with manual refresh capability
class BoardMembersNotifier extends StateNotifier<BoardMembersState> {
  BoardMembersNotifier() : super(const BoardMembersState());

  Future<void> fetchBoardMembers({
    required String campusId,
    String? departmentId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await LeadershipService.getBoardMembers(
        campusId: campusId,
        departmentId: departmentId,
      );

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          response: response,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Failed to fetch board members',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch board members: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const BoardMembersState();
  }
}

// Provider for the stateful board members notifier
final boardMembersNotifierProvider = StateNotifierProvider<BoardMembersNotifier, BoardMembersState>((ref) {
  return BoardMembersNotifier();
});

// Helper class for parameters
class BoardMembersParams {
  final String campusId;
  final String? departmentId;

  const BoardMembersParams({
    required this.campusId,
    this.departmentId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardMembersParams &&
          runtimeType == other.runtimeType &&
          campusId == other.campusId &&
          departmentId == other.departmentId;

  @override
  int get hashCode => campusId.hashCode ^ departmentId.hashCode;
}