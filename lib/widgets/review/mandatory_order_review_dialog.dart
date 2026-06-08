import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../models/food/order_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/review/i_review_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/review/review_dialog_viewmodel.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';
import 'review_star_input.dart';

class MandatoryOrderReviewDialog extends StatelessWidget {
  const MandatoryOrderReviewDialog({
    super.key,
    required this.order,
    required this.reviewService,
    this.authService,
  });

  final OrderModel order;
  final IReviewService reviewService;
  final IAuthService? authService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewDialogViewModel(
        reviewService: reviewService,
        orderId: order.id,
        storeName: order.bag?.shopName ?? 'review.business'.tr(),
      ),
      child: _MandatoryOrderReviewPage(
        order: order,
        authService: authService ?? context.read<IAuthService>(),
      ),
    );
  }
}

class _MandatoryOrderReviewPage extends StatefulWidget {
  const _MandatoryOrderReviewPage({
    required this.order,
    required this.authService,
  });

  final OrderModel order;
  final IAuthService authService;

  @override
  State<_MandatoryOrderReviewPage> createState() =>
      _MandatoryOrderReviewPageState();
}

class _MandatoryOrderReviewPageState extends State<_MandatoryOrderReviewPage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  bool _isUploading = false;
  String? _localError;

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 3 || _isUploading) return;
    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (!mounted || image == null) return;
    setState(() {
      _selectedImages.add(image);
      _localError = null;
    });
  }

  void _showImageSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text('common.pickFromCamera'.tr()),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text('common.pickFromGallery'.tr()),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(ReviewDialogViewModel vm) async {
    if (vm.rating == 0) {
      setState(() => _localError = 'review.validation.rating'.tr());
      return;
    }
    if (vm.commentController.text.trim().length < 15) {
      setState(() => _localError = 'review.validation.comment'.tr());
      return;
    }
    if (_selectedImages.isEmpty) {
      setState(() => _localError = 'review.validation.photo'.tr());
      return;
    }

    setState(() {
      _isUploading = true;
      _localError = null;
    });

    final imageUrls = <String>[];
    for (final image in _selectedImages) {
      final url = await widget.authService.uploadImage(image.path);
      if (url == null || url.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isUploading = false;
          _localError = 'review.photoUploadError'.tr();
        });
        return;
      }
      imageUrls.add(url);
    }

    await vm.submit(imageUrls: imageUrls);
    if (!mounted) return;
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewDialogViewModel>();
    final isLoading = vm.isLoading || _isUploading;

    if (vm.isSubmitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop(true);
      });
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('review.title'.tr()),
        ),
        body: AbsorbPointer(
          absorbing: isLoading,
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _OrderHeader(order: widget.order),
                  const SizedBox(height: 18),
                  Text(
                    'review.rateExperience'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ReviewStarInput(
                    rating: vm.rating,
                    color: AppColors.primaryColor,
                    size: 42,
                    onChanged: (rating) {
                      vm.setRating(rating);
                      setState(() => _localError = null);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0x55FE8800)),
                  const SizedBox(height: 8),
                  _FieldLabel('review.addPhoto'.tr()),
                  Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                          child: index < _selectedImages.length
                              ? _SelectedPhoto(
                                  image: _selectedImages[index],
                                  onRemove: () => setState(
                                    () => _selectedImages.removeAt(index),
                                  ),
                                )
                              : _AddPhotoSlot(onTap: _showImageSourcePicker),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'review.photoCount'.tr(
                      namedArgs: {'count': _selectedImages.length.toString()},
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedImages.isEmpty
                          ? Colors.redAccent
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0x55FE8800)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: vm.commentController,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 500,
                    onChanged: (_) => setState(() => _localError = null),
                    hintText: 'review.orderHint'.tr(),
                    fillColor: const Color(0xFFFFF8F0),
                    borderColor: AppColors.primaryColor.withValues(alpha: 0.55),
                    borderRadius: 18,
                  ),
                  if (_localError != null || vm.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _localError ?? vm.errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'review.submit'.tr(),
                    width: double.infinity,
                    height: 54,
                    borderRadius: 14,
                    gradient: AppColors.primaryButtonGradient,
                    onPressed: () => _submit(vm),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              if (isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66FFFFFF),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final bag = order.bag;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bag?.imageUrl != null && bag!.imageUrl!.isNotEmpty
                ? Image.network(
                    bag.imageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bag?.title ?? 'home.surpriseBox'.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  bag?.shopName ?? 'review.business'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.hintTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.primaryColor.withValues(alpha: 0.12),
      child: const Icon(Icons.fastfood_rounded, color: AppColors.primaryColor),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AddPhotoSlot extends StatelessWidget {
  const _AddPhotoSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: const _DashedBorderPainter(
          color: Color(0xAAFE8800),
          borderRadius: 10,
          dashWidth: 6,
          dashSpace: 4,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 92,
          child: const Center(
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primaryColor,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SelectedPhoto extends StatelessWidget {
  const _SelectedPhoto({required this.image, required this.onRemove});

  final XFile image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(image.path),
            width: double.infinity,
            height: 92,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -7,
          right: -7,
          child: InkWell(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
