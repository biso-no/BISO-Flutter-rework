import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/campus_model.dart';
import '../../data/services/campus_service.dart';
import '../auth/auth_provider.dart';

// Filter campus provider - used for filtering content display
final filterCampusProvider = StateNotifierProvider<FilterCampusNotifier, CampusModel>((ref) {
  return FilterCampusNotifier();
});

// DEPRECATED: Use filterCampusProvider instead
// This is kept for backward compatibility during migration
final selectedCampusProvider = Provider<CampusModel>((ref) {
  return ref.watch(filterCampusProvider);
});

// User's profile campus provider - derived from user data
final profileCampusProvider = Provider<CampusModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;
  
  if (user?.campusId != null) {
    return CampusData.getCampusById(user!.campusId!);
  }
  return null;
});

// All campuses provider - fetches from Appwrite with fallback to static data
final allCampusesProvider = FutureProvider<List<CampusModel>>((ref) async {
  final campusService = CampusService();
  return await campusService.getAllCampuses();
});

// Synchronous provider for immediate access (with static fallback)
final allCampusesSyncProvider = Provider<List<CampusModel>>((ref) {
  final asyncCampuses = ref.watch(allCampusesProvider);
  return asyncCampuses.when(
    data: (campuses) => campuses,
    loading: () => CampusData.campuses, // Fallback while loading
    error: (_, __) => CampusData.campuses, // Fallback on error
  );
});

// Filter campus state notifier - manages campus for content filtering
class FilterCampusNotifier extends StateNotifier<CampusModel> {
  static const String _filterCampusKey = 'filter_campus_id';
  final CampusService _campusService = CampusService();

  FilterCampusNotifier() : super(CampusData.defaultCampus) {
    _loadFilterCampus();
  }

  Future<void> _loadFilterCampus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final campusId = prefs.getString(_filterCampusKey);
      
      if (campusId != null) {
        print('🏛️ FilterCampusNotifier: Loading campus with ID: $campusId');
        
        // Try to fetch from Appwrite first
        final campus = await _campusService.getCampusById(campusId);
        if (campus != null) {
          print('✅ FilterCampusNotifier: Loaded campus: ${campus.name}');
          state = campus;
        } else {
          // Fallback to static data
          final staticCampus = CampusData.getCampusById(campusId);
          if (staticCampus != null) {
            print('🔄 FilterCampusNotifier: Using static campus: ${staticCampus.name}');
            state = staticCampus;
          }
        }
      }
    } catch (e) {
      print('❌ FilterCampusNotifier: Error loading campus: $e');
      // If loading fails, keep default campus
    }
  }

  Future<void> selectFilterCampus(CampusModel campus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_filterCampusKey, campus.id);
      state = campus;
    } catch (e) {
      // Handle error - maybe show snackbar
      throw Exception('Failed to save filter campus selection');
    }
  }

  Future<void> clearFilterSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_filterCampusKey);
      state = CampusData.defaultCampus;
    } catch (e) {
      // Handle error
    }
  }

  // DEPRECATED: Use selectFilterCampus instead
  Future<void> selectCampus(CampusModel campus) async {
    await selectFilterCampus(campus);
  }

  // DEPRECATED: Use clearFilterSelection instead
  Future<void> clearSelection() async {
    await clearFilterSelection();
  }
}

// DEPRECATED class - kept for backward compatibility
class SelectedCampusNotifier extends FilterCampusNotifier {}