import '../../models/business/business_listing_model.dart';
import '../../models/business/business_dashboard_model.dart';
import '../../models/business/business_order_approval_model.dart';

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

  /// İşletme dashboard istatistiklerini getirir.
  Future<BusinessDashboardModel?> getDashboardStats();

  /// Pending ve arrived durumundaki food siparişlerini getirir.
  Future<List<BusinessOrderApprovalModel>> getOrderApprovals();

  /// Müşteriye teslim edilen siparişi picked_up durumuna geçirir.
  Future<bool> confirmOrderPickup(int orderId);
}
