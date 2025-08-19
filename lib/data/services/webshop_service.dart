import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../models/webshop_product_model.dart';
import 'appwrite_service.dart';

class WebshopService {
  Future<List<WebshopProduct>> listWebshopProducts({
    required String campusName,
    String? departmentId,
    int limit = 20,
  }) async {
    final Map<String, dynamic> body = {
      // Function supports both `campus` and `campusId`; we send readable name to satisfy mapping
      'campus': campusName,
      if (departmentId != null) 'departmentId': departmentId,
      'perPage': limit,
    };

    final execution = await functions.createExecution(
      functionId: AppConstants.fnSyncWebshopProductsId,
      body: json.encode(body),
    );

    if (execution.responseStatusCode != 200) {
      throw Exception('Failed to load webshop products: HTTP ${execution.responseStatusCode}');
    }

    final Map<String, dynamic> payload = json.decode(execution.responseBody);
    final List<dynamic> products = payload['products'] as List<dynamic>? ?? const <dynamic>[];
    return products
        .map((e) => WebshopProduct.fromFunctionMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}


