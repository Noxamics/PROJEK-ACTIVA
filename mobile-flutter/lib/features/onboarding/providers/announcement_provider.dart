import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/announcement_model.dart';

final announcementProvider = FutureProvider<List<AnnouncementModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  
  try {
    final response = await apiClient.get(ApiEndpoints.announcements);
    final List<dynamic> data = response.data['data'] ?? [];
    
    return data.map((json) => AnnouncementModel.fromJson(json)).toList();
  } catch (e) {
    // Return empty list if fails or handle error accordingly
    return [];
  }
});
