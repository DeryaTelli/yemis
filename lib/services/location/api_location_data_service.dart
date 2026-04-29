import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/location/location_model.dart';
import '../../utils/constants/api_constants.dart';
import 'i_location_data_service.dart';

class ApiLocationDataService implements ILocationDataService {
  @override
  Future<List<LocationModel>> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.provinces}'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'] as List;
          return data.map((e) => LocationModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      // Ignore error for now, could log it
    }
    return [];
  }

  @override
  Future<List<LocationModel>> getDistricts(int provinceId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.districts(provinceId)}'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'] as List;
          return data.map((e) => LocationModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      // Ignore error for now
    }
    return [];
  }

  @override
  Future<List<LocationModel>> getNeighborhoods(int districtId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.neighborhoods(districtId)}'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'] as List;
          return data.map((e) => LocationModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      // Ignore error for now
    }
    return [];
  }
}
