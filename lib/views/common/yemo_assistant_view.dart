import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/services/common/assistant_service.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import 'package:yemis/viewmodels/common/yemo_assistant_viewmodel.dart';
import 'package:yemis/models/business/business_listing_model.dart';
import 'package:yemis/models/food/food_listing.dart';
import 'package:yemis/widgets/food/food_listing_card.dart';

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
  int _lastMessageCount = 0;
  bool _lastLoadingState = false;


  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scheduleScrollIfNeeded(YemoAssistantViewModel vm) {
    final shouldScroll =
        vm.messages.length != _lastMessageCount ||
        vm.isLoading != _lastLoadingState;

    if (!shouldScroll) return;

    _lastMessageCount = vm.messages.length;
    _lastLoadingState = vm.isLoading;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToBottom();
    });
  }

  Future<void> _handleAssistantAction(AssistantActionModel action) async {
    final route = _resolveAssistantRoute(action);
    if (route == null) return;

    Object? arguments;
    if (route == AppRoutes.location) {
      arguments = {'moduleType': widget.moduleType};
    } else if (route == AppRoutes.addresses) {
      arguments = widget.moduleType;
    }

    await Navigator.pushNamed(context, route, arguments: arguments);
  }

  String? _resolveAssistantRoute(AssistantActionModel action) {
    final route = action.route?.trim();
    final topic = action.topic?.trim().toLowerCase();

    switch (route) {
      case '/food-home':
        return AppRoutes.foodHome;
      case '/location':
        return AppRoutes.location;
      case '/volunteer/listings':
        return topic == 'my_volunteer_tasks'
            ? AppRoutes.volunteerListings
            : AppRoutes.volunteerHome;
      case '/business-add-order':
        return AppRoutes.businessAddOrder;
      case '/business/listings':
        return AppRoutes.businessListings;
      case '/addresses':
        return AppRoutes.addresses;
      case '/food-reserve':
        return AppRoutes.foodHome;
    }

    switch (topic) {
      case 'find_food':
      case 'reserve':
      case 'ai_suggestions':
        return AppRoutes.foodHome;
      case 'select_region':
        return AppRoutes.location;
      case 'volunteer_listings':
      case 'become_volunteer':
        return AppRoutes.volunteerHome;
      case 'my_volunteer_tasks':
        return AppRoutes.volunteerListings;
      case 'add_order':
        return AppRoutes.businessAddOrder;
      case 'business_listings':
        return AppRoutes.businessListings;
      case 'addresses':
        return AppRoutes.addresses;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<YemoAssistantViewModel>();
    final isVolunteer = widget.moduleType == AppModuleType.volunteer;
    final themeColor = isVolunteer
        ? AppColors.volunteerColor
        : AppColors.primaryColor;
    final titleImage = isVolunteer
        ? 'assets/common/yemo_volunteer_title.png'
        : 'assets/common/yemo_food_business_title.png';

    _scheduleScrollIfNeeded(vm);

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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    if (!vm.isChatStarted) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: Image.asset(
                          'assets/foodIcon/yemo.png',
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Image.asset(
                          titleImage,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                    if (vm.messages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...vm.messages.map(
                        (msg) => _buildChatMessage(msg, themeColor, vm),
                      ),
                      if (vm.isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              onSubmitted: vm.sendMessage,
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

  Widget _buildChatMessage(ChatMessage msg, Color themeColor, YemoAssistantViewModel vm) {
    final isUser = msg.isUser;

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
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                if (!isUser && msg.nearbyListings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.72,
                    child: Column(
                      children: msg.nearbyListings.map((rawItem) {
                        try {
                          final businessModel = BusinessListingModel.fromJson(rawItem);
                          final listing = businessModel.toFoodListing();
                          final distance = rawItem['distance'];
                          final locationStr = distance != null 
                              ? '${distance.toString()} km'
                              : listing.location;
                          final updatedListing = listing.copyWith(location: locationStr);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FoodListingCard(
                              listing: updatedListing,
                              width: double.infinity,
                              onFavoriteTap: () {},
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.foodDetail,
                                  arguments: updatedListing,
                                );
                              },
                            ),
                          );
                        } catch (e) {
                          debugPrint('Error mapping nearby listing card: $e');
                          return const SizedBox();
                        }
                      }).toList(),
                    ),
                  ),
                ],
                if (!isUser && msg.topic == 'become_volunteer') ...[
                  _buildVolunteerModeCard(themeColor),
                ],
                if (!isUser && msg.actions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  (() {
                    final hasShareLocation = msg.actions.any((action) => action.topic == 'share_location');
                    if (hasShareLocation) {
                      return _buildLocationRequestButtons(msg.actions, themeColor, vm);
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: msg.actions
                          .map(
                            (action) => _buildActionChip(
                              action: action,
                              themeColor: themeColor,
                            ),
                          )
                          .toList(),
                    );
                  })(),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildLocationRequestButtons(List<AssistantActionModel> actions, Color themeColor, YemoAssistantViewModel vm) {
    final shareAction = actions.firstWhere((a) => a.topic == 'share_location', orElse: () => const AssistantActionModel(label: 'Konumumu paylaş'));
    final selectAction = actions.firstWhere((a) => a.topic == 'select_region', orElse: () => const AssistantActionModel(label: 'Elle seç'));

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.72,
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => vm.shareLocation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
            label: Text(
              shareAction.label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _handleAssistantAction(selectAction),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selectAction.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerModeCard(Color themeColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.72,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.favorite, color: themeColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'GÖNÜLLÜLÜK MODU',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Destek ol, birlikte daha az israf edelim. 🌱',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  themeColor,
                  themeColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Stack(
              children: [
                Positioned(
                  right: 12,
                  bottom: -15,
                  child: Icon(
                    Icons.volunteer_activism,
                    size: 80,
                    color: Colors.white12,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Gönüllü olarak\nfark yaratabilirsin.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildVolunteerTile(
            icon: Icons.restaurant,
            title: 'Yemek paylaşımı yap',
            subtitle: 'Fazla yemeklerini paylaş',
            themeColor: themeColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.volunteerAddListing);
            },
          ),
          const Divider(height: 1, indent: 56, endIndent: 12),
          _buildVolunteerTile(
            icon: Icons.local_shipping,
            title: 'Dağıtıma destek ol',
            subtitle: 'Yemeklerin ihtiyaç sahiplerine ulaşmasına yardımcı ol',
            themeColor: themeColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.volunteerHome);
            },
          ),
          const Divider(height: 1, indent: 56, endIndent: 12),
          _buildVolunteerTile(
            icon: Icons.groups,
            title: 'Etkinliklere katıl',
            subtitle: 'Gönüllü etkinlikleri keşfet',
            themeColor: themeColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.volunteerHome);
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                'Birlikte daha az israf, daha çok iyilik! 💚',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color themeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: themeColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required AssistantActionModel action,
    required Color themeColor,
  }) {
    final canNavigate = _resolveAssistantRoute(action) != null;

    return GestureDetector(
      onTap: canNavigate ? () => _handleAssistantAction(action) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: canNavigate
              ? themeColor.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: canNavigate
                ? themeColor.withValues(alpha: 0.25)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              action.label,
              style: TextStyle(
                color: canNavigate ? themeColor : Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (canNavigate) ...[
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 16, color: themeColor),
            ],
          ],
        ),
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
