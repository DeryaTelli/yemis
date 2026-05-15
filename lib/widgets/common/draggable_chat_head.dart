import 'package:flutter/material.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/utils/routes/app_routes.dart';

class DraggableChatHead extends StatefulWidget {
  final AppModuleType moduleType;

  const DraggableChatHead({super.key, required this.moduleType});

  @override
  State<DraggableChatHead> createState() => _DraggableChatHeadState();
}

class _DraggableChatHeadState extends State<DraggableChatHead> {
  Offset position = const Offset(20, 20); // Default position
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      // Set initial position safely within the screen bounds
      final size = MediaQuery.of(context).size;
      position = Offset(size.width - 85, size.height - 180);
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              (position.dx + details.delta.dx).clamp(0.0, size.width - 70.0),
              (position.dy + details.delta.dy).clamp(0.0, size.height - 140.0),
            );
          });
        },
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.yemoAssistant,
            arguments: widget.moduleType,
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/foodIcon/yemo.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
