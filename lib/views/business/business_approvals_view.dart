import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../models/app_module_type.dart';
import '../../models/business/business_order_approval_model.dart';
import '../../services/business/i_business_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/business/business_approvals_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class BusinessApprovalsView extends StatelessWidget {
  const BusinessApprovalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BusinessApprovalsViewModel(
        businessService: ctx.read<IBusinessService>(),
      ),
      child: const _BusinessQrApprovalScreen(),
    );
  }
}

class _BusinessQrApprovalScreen extends StatefulWidget {
  const _BusinessQrApprovalScreen();

  @override
  State<_BusinessQrApprovalScreen> createState() =>
      _BusinessQrApprovalScreenState();
}

class _BusinessQrApprovalScreenState extends State<_BusinessQrApprovalScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handlingScan = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handlingScan || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.trim().isEmpty) return;

    _handlingScan = true;
    final matched = context.read<BusinessApprovalsViewModel>().matchQr(value);
    if (matched) {
      await _scannerController.stop();
    } else {
      await Future<void>.delayed(const Duration(seconds: 2));
      _handlingScan = false;
    }
  }

  Future<void> _resumeScanner() async {
    context.read<BusinessApprovalsViewModel>().clearMatch();
    _handlingScan = false;
    await _scannerController.start();
  }

  Future<void> _confirmPickup() async {
    final vm = context.read<BusinessApprovalsViewModel>();
    final success = await vm.confirmPickup();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Sipariş teslim edildi olarak işaretlendi.'
              : vm.error ?? 'Teslim onaylanamadı.',
        ),
        backgroundColor: success ? const Color(0xFF27AE60) : Colors.red,
      ),
    );
    if (success) await _resumeScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessApprovalsViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF7),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('QR Kod Doğrulama'),
          ),
          body: RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: vm.loadApprovals,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const _IntroCard(),
                const SizedBox(height: 16),
                _ScannerArea(
                  controller: _scannerController,
                  onDetect: _onDetect,
                  isMatched: vm.matchedOrder != null,
                ),
                const SizedBox(height: 18),
                if (vm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                else if (vm.matchedOrder != null)
                  _MatchedOrderPanel(
                    order: vm.matchedOrder!,
                    isConfirming: vm.isConfirming,
                    onConfirm: _confirmPickup,
                    onScanAgain: _resumeScanner,
                  )
                else
                  _ReadyPanel(pendingCount: vm.orders.length, error: vm.error),
              ],
            ),
          ),
          bottomNavigationBar: AppBottomNavBar(
            selectedIndex: vm.selectedIndex,
            onItemSelected: (index) {
              final route = vm.getBottomNavRoute(index);
              if (route == null) {
                vm.onTabSelected(index);
              } else if (index == 2) {
                Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
              } else if (ModalRoute.of(context)?.settings.name != route) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
            moduleType: AppModuleType.business,
          ),
        );
      },
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD8AD)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Color(0xFFFFE8CE),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.primaryColor,
              size: 30,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlan Teslimi İçin QR Onayla',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 5),
                Text(
                  'Teslimatı onaylamak için müşterinin QR kodunu tarayın.',
                  style: TextStyle(color: Color(0xFF666666), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerArea extends StatelessWidget {
  const _ScannerArea({
    required this.controller,
    required this.onDetect,
    required this.isMatched,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final bool isMatched;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isMatched
              ? 'QR kod doğrulandı.'
              : 'QR kodu tarama alanına hizalayın.',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1.15,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(controller: controller, onDetect: onDetect),
                Container(color: Colors.black.withValues(alpha: 0.08)),
                const _ScannerCorners(),
                if (!isMatched)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: .8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScannerCornersPainter());
  }
}

class _ScannerCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const inset = 18.0;
    const length = 44.0;
    final paths = [
      Path()
        ..moveTo(inset, inset + length)
        ..lineTo(inset, inset)
        ..lineTo(inset + length, inset),
      Path()
        ..moveTo(size.width - inset - length, inset)
        ..lineTo(size.width - inset, inset)
        ..lineTo(size.width - inset, inset + length),
      Path()
        ..moveTo(inset, size.height - inset - length)
        ..lineTo(inset, size.height - inset)
        ..lineTo(inset + length, size.height - inset),
      Path()
        ..moveTo(size.width - inset - length, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset - length),
    ];
    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReadyPanel extends StatelessWidget {
  const _ReadyPanel({required this.pendingCount, required this.error});

  final int pendingCount;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFFFF1E1),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'QR Kod Okunmaya Hazır',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            pendingCount == 0
                ? 'Şu anda teslim bekleyen sipariş bulunmuyor.'
                : '$pendingCount sipariş teslim onayı bekliyor.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF666666)),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}

class _MatchedOrderPanel extends StatelessWidget {
  const _MatchedOrderPanel({
    required this.order,
    required this.isConfirming,
    required this.onConfirm,
    required this.onScanAgain,
  });

  final BusinessOrderApprovalModel order;
  final bool isConfirming;
  final VoidCallback onConfirm;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFE8F8EE),
                child: Icon(Icons.check_rounded, color: Color(0xFF27AE60)),
              ),
              SizedBox(width: 10),
              Text(
                'QR Kod Doğrulandı',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE1BE)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: _OrderImage(url: order.imageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.listingTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName ?? order.businessName,
                        style: const TextStyle(color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${order.quantity} Adet',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.primaryButtonGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextButton(
                onPressed: isConfirming ? null : onConfirm,
                child: isConfirming
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Teslimi Onayla',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
          TextButton(
            onPressed: isConfirming ? null : onScanAgain,
            child: const Text(
              'Başka QR Tara',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        width: 76,
        height: 76,
        color: const Color(0xFFFFEEDB),
        child: const Icon(
          Icons.fastfood_rounded,
          color: AppColors.primaryColor,
        ),
      );
    }
    return Image.network(
      url!,
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: 76,
        height: 76,
        color: const Color(0xFFFFEEDB),
        child: const Icon(
          Icons.fastfood_rounded,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
