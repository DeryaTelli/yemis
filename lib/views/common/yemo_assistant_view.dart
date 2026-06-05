import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/services/common/assistant_service.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/viewmodels/common/yemo_assistant_viewmodel.dart';

class YemoAssistantView extends StatelessWidget {
  final AppModuleType moduleType;

  const YemoAssistantView({super.key, required this.moduleType});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          YemoAssistantViewModel(service: context.read<IAssistantService>()),
      child: _YemoAssistantBody(moduleType: moduleType),
    );
  }
}

class _YemoAssistantBody extends StatefulWidget {
  final AppModuleType moduleType;

  const _YemoAssistantBody({required this.moduleType});

  @override
  State<_YemoAssistantBody> createState() => _YemoAssistantBodyState();
}

class _YemoAssistantBodyState extends State<_YemoAssistantBody> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<YemoAssistantViewModel>();
    final bool isVolunteer = widget.moduleType == AppModuleType.volunteer;
    final Color themeColor = isVolunteer
        ? AppColors.volunteerColor
        : AppColors.primaryColor;
    final String titleImage = isVolunteer
        ? 'assets/common/yemo_volunteer_title.png'
        : 'assets/common/yemo_food_business_title.png';

    // Mesaj geldiğinde aşağı kaydır
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: themeColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: vm.isChatStarted
            ? Image.asset(titleImage, height: 32, fit: BoxFit.contain)
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    if (!vm.isChatStarted) ...[
                      const SizedBox(height: 10),
                      // Yemo Image
                      Center(
                        child: Image.asset(
                          'assets/foodIcon/yemo.png',
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title Image
                      Center(
                        child: Image.asset(
                          titleImage,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      const Text(
                        'Akıllı Asistan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sana yardımcı olmak için buradayım.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Chat Messages
                    if (vm.messages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...vm.messages.map(
                        (msg) => _buildChatMessage(msg, themeColor),
                      ),
                      if (vm.isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  themeColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],

                    // Cards based on moduleType (Only show if chat NOT started)
                    if (!vm.isChatStarted) ...[
                      if (widget.moduleType == AppModuleType.food) ...[
                        _buildActionCard(
                          icon: Icons.location_on,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_foodFindTitle.tr(),
                          subtitle: LocaleKeys.yemoAssistant_foodFindSubtitle
                              .tr(),
                          onTap: () => vm.startGuidance('find_food'),
                        ),
                        const SizedBox(height: 12),
                        _buildActionCard(
                          icon: Icons.shopping_basket,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_foodReserveTitle.tr(),
                          subtitle: LocaleKeys.yemoAssistant_foodReserveSubtitle
                              .tr(),
                          onTap: () => vm.startGuidance('reserve'),
                        ),
                        const SizedBox(height: 12),
                        _buildActionCard(
                          icon: Icons.auto_awesome,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_foodAiTitle.tr(),
                          subtitle: LocaleKeys.yemoAssistant_foodAiSubtitle
                              .tr(),
                          onTap: () => vm.startGuidance('ai_suggestions'),
                        ),
                      ] else if (widget.moduleType ==
                          AppModuleType.business) ...[
                        _buildActionCard(
                          icon: Icons.bar_chart,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_businessSalesTitle
                              .tr(),
                          subtitle: LocaleKeys
                              .yemoAssistant_businessSalesSubtitle
                              .tr(),
                          onTap: () => vm.startGuidance('sales'),
                        ),
                        const SizedBox(height: 12),
                        _buildActionCard(
                          icon: Icons.add_box,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_businessAddOrderTitle
                              .tr(),
                          subtitle: LocaleKeys
                              .yemoAssistant_businessAddOrderSubtitle
                              .tr(),
                          onTap: () => vm.startGuidance('add_order'),
                        ),
                        const SizedBox(height: 12),
                        _buildActionCard(
                          icon: Icons.eco,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_businessCo2Title.tr(),
                          subtitle: LocaleKeys.yemoAssistant_businessCo2Subtitle
                              .tr(),
                          onTap: () => vm.startGuidance('co2'),
                        ),
                      ] else ...[
                        _buildActionCard(
                          icon: Icons.volunteer_activism,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_volunteerListingsTitle
                              .tr(),
                          subtitle: LocaleKeys
                              .yemoAssistant_volunteerListingsSubtitle
                              .tr(),
                          onTap: () => vm.startGuidance('volunteer_listings'),
                        ),
                        const SizedBox(height: 12),
                        _buildActionCard(
                          icon: Icons.favorite,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_volunteerBecomeTitle
                              .tr(),
                          subtitle: LocaleKeys
                              .yemoAssistant_volunteerBecomeSubtitle
                              .tr(),
                          onTap: () => vm.startGuidance('become_volunteer'),
                        ),
                        const SizedBox(height: 12),
                        _buildActionCard(
                          icon: Icons.map,
                          iconColor: themeColor,
                          title: LocaleKeys.yemoAssistant_volunteerRegionTitle
                              .tr(),
                          subtitle: LocaleKeys
                              .yemoAssistant_volunteerRegionSubtitle
                              .tr(),
                          onTap: () => vm.startGuidance('select_region'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.chat_bubble,
                        iconColor: themeColor,
                        title: LocaleKeys.yemoAssistant_commonQuestionsTitle
                            .tr(),
                        subtitle: LocaleKeys
                            .yemoAssistant_commonQuestionsSubtitle
                            .tr(),
                        onTap: () => vm.startGuidance('Sorularını sor'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Input Field
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: vm.messageController,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.yemoAssistant_hintText
                                    .tr(),
                                border: InputBorder.none,
                                hintStyle: const TextStyle(
                                  color: Colors.black38,
                                  fontSize: 15,
                                ),
                              ),
                              onSubmitted: (val) => vm.sendMessage(val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => vm.sendMessage(vm.messageController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage msg, Color themeColor) {
    final bool isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Image.asset(
                    'assets/foodIcon/yemo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isUser ? themeColor : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 12), // User tarafında minimal pay
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
