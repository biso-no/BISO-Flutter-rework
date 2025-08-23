import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/campus_data_model.dart';
import '../../data/services/campus_service.dart';
import 'campus_provider.dart';

// Provider to fetch campus data for a specific campus ID
final campusDataProvider = FutureProvider.family<CampusDataModel?, String>((ref, campusId) async {
  final campusService = CampusService();
  try {
    // Fetch campus data using the campus ID
    final campusData = await campusService.getCampusData(campusId);
    return campusData;
  } catch (e) {
    return null;
  }
});

// Provider to get the current campus data based on the filter campus
final currentCampusDataProvider = Provider<AsyncValue<CampusDataModel?>>((ref) {
  final campusId = ref.watch(filterCampusProvider).id;
  if (campusId.isEmpty) {
    return const AsyncValue.data(null);
  }
  return ref.watch(campusDataProvider(campusId));
});
