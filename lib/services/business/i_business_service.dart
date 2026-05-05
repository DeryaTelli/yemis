import '../../models/business/business_listing_model.dart';

abstract class IBusinessService {
  /// Yeni bir sürpriz kutu (bag) oluşturur.
  Future<bool> createBag(Map<String, dynamic> data);

  /// İşletmenin tüm ilanlarını getirir.
  Future<List<BusinessListingModel>> getMyBags();

  /// İşletmenin satılmamış (aktif) ilanlarını getirir.
  Future<List<BusinessListingModel>> getMyUnsoldBags();

  /// İşletmenin satılmış veya süresi dolmuş ilanlarını getirir.
  Future<List<BusinessListingModel>> getMySoldBags();

  /// Belirli bir ilanı siler.
  Future<bool> deleteBag(int id);

  /// Mevcut bir ilanı günceller.
  Future<bool> updateBag(int id, Map<String, dynamic> data);
}
