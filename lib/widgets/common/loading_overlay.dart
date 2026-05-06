import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/app_module_type.dart';
import 'draggable_chat_head.dart';

/// Ekranın üzerine şeffaf bir katman ekleyip Lottie animasyonu gösteren widget.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final AppModuleType moduleType;
  final bool showChatHead;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.moduleType = AppModuleType.food,
    this.showChatHead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        child: Stack(
          children: [
            child,
            if (isLoading)
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Container(
                      color: Colors.black.withValues(alpha: 0.3 * value),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5.0 * value,
                            sigmaY: 5.0 * value,
                          ),
                          child: Center(
                            child: Lottie.asset(
                              moduleType == AppModuleType.volunteer
                                  ? 'assets/lottie/loading_volunteer.json'
                                  : 'assets/lottie/loading.json',
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (showChatHead && !isLoading)
              DraggableChatHead(moduleType: moduleType),
          ],
        ),
      ),
    );
  }
}
