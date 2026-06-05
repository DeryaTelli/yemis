import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/home/volunteer_home_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/review/review_star_input.dart';

class VolunteerReviewView extends StatefulWidget {
  const VolunteerReviewView({
    super.key,
    required this.viewModel,
    required this.task,
  });

  final VolunteerHomeViewModel viewModel;
  final VolunteerListing task;

  @override
  State<VolunteerReviewView> createState() => _VolunteerReviewViewState();
}

class _VolunteerReviewViewState extends State<VolunteerReviewView> {
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  int _rating = 0;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 3 || _isSubmitting) return;
    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (!mounted || image == null) return;
    setState(() {
      _selectedImages.add(image);
      _errorText = null;
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _ImageSourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'Kameradan Çek',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _ImageSourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Galeriden Seç',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (_rating == 0) {
      setState(() => _errorText = 'Lütfen bir puan seçin.');
      return;
    }
    if (comment.length < 15) {
      setState(() => _errorText = 'Yorum en az 15 karakter olmalı.');
      return;
    }
    if (_selectedImages.isEmpty) {
      setState(() => _errorText = 'En az 1 fotoğraf eklemelisiniz.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final success = await widget.viewModel.submitVolunteerReview(
      widget.task.taskId!,
      rating: _rating,
      comment: comment,
      imagePaths: _selectedImages.map((image) => image.path).toList(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorText = 'Yorum gönderilemedi. Lütfen tekrar deneyin.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: LoadingOverlay(
        isLoading: _isSubmitting,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Yorum Yap'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _TaskHeader(task: widget.task),
              const SizedBox(height: 12),
              Text(
                'Deneyiminizi değerlendirin',
                style: CustomTextStyles.semiBold16DarkGreyCompact,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              ReviewStarInput(
                rating: _rating,
                color: AppColors.volunteerColor,
                size: 42,
                onChanged: (rating) => setState(() {
                  _rating = rating;
                  _errorText = null;
                }),
              ),
              const SizedBox(height: 12),
              const Divider(
                color: Color.fromARGB(95, 34, 176, 91),
                thickness: 1,
              ),
              // const SizedBox(height: 4),
              const _FieldLabel('Fotoğraf Ekle'),
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
                '${_selectedImages.length}/3 fotoğraf seçildi. En az 1 fotoğraf zorunludur.',
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedImages.isEmpty
                      ? Colors.redAccent
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(
                color: Color.fromARGB(95, 34, 176, 91),
                thickness: 1,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _commentController,
                hintText: 'Gönüllülük deneyiminizi paylaşın',
                minLines: 4,
                maxLines: 6,
                maxLength: 500,
                // fillColor: const Color.fromARGB(
                //   19,
                //   34,slkjdfl;
                //   176,
                //   91,
                // ).withValues(alpha: 0.18),
                borderColor: Colors.transparent,
                borderRadius: 18,
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const Divider(
                color: Color.fromARGB(95, 34, 176, 91),
                thickness: 1,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Gönder',
                width: double.infinity,
                height: 54,
                borderRadius: 14,
                gradient: AppColors.volunteerBackgroundGradient,
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader({required this.task});

  final VolunteerListing task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.volunteerColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.volunteerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: task.isNetworkImage
                ? Image.network(
                    task.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _ImagePlaceholder(),
                  )
                : Image.asset(
                    task.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _ImagePlaceholder(),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.semiBold16DarkGreyCompact.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  task.shelterName ?? task.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.semiBold14DarkGrey,
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
      color: AppColors.volunteerColor.withValues(alpha: 0.12),
      child: const Icon(
        Icons.volunteer_activism,
        color: AppColors.volunteerColor,
      ),
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
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
          color: Color(0x8022B05A),
          borderRadius: 10,
          dashWidth: 6,
          dashSpace: 4,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 92,
          child: Center(
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.volunteerColor.withValues(alpha: 0.8),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
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
          borderRadius: BorderRadius.circular(4),
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
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.volunteerColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.volunteerColor),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.volunteerColor,
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
