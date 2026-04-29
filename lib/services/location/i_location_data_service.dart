import '../../models/location/location_model.dart';

abstract class ILocationDataService {
  Future<List<LocationModel>> getProvinces();
  Future<List<LocationModel>> getDistricts(int provinceId);
  Future<List<LocationModel>> getNeighborhoods(int districtId);
}
