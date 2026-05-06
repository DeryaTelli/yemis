import 'package:flutter/material.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/utils/constants/app_colors.dart';

class YemoAssistantView extends StatelessWidget {
  final AppModuleType moduleType;

  const YemoAssistantView({
    super.key,
    required this.moduleType,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVolunteer = moduleType == AppModuleType.volunteer;
    final bool isBusiness = moduleType == AppModuleType.business;
    final Color themeColor = isVolunteer ? AppColors.volunteerColor : AppColors.primaryColor;
    final String titleImage = isVolunteer
        ? 'assets/common/yemo_volunteer_title.png'
        : 'assets/common/yemo_food_business_title.png';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: themeColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
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
                    
                    // Cards based on moduleType
                    if (moduleType == AppModuleType.food) ...[
                      _buildActionCard(
                        icon: Icons.location_on,
                        iconColor: themeColor,
                        title: 'Yakınında yemek bul',
                        subtitle: 'En yakın ve uygun yemekleri keşfet',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.shopping_basket,
                        iconColor: themeColor,
                        title: 'Sipariş ver',
                        subtitle: 'İhtiyacın olan yemeği rezerve et',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.auto_awesome,
                        iconColor: themeColor,
                        title: 'Yapay zeka önerileri',
                        subtitle: 'Sana özel yemek önerileri al',
                        onTap: () {},
                      ),
                    ] else if (moduleType == AppModuleType.business) ...[
                      _buildActionCard(
                        icon: Icons.bar_chart,
                        iconColor: themeColor,
                        title: 'Satışları takip et',
                        subtitle: 'Satış verilerini anlık olarak gör',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.add_box,
                        iconColor: themeColor,
                        title: 'Sipariş ekle',
                        subtitle: 'Yeni bir yemek ilanı oluştur',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.eco,
                        iconColor: themeColor,
                        title: 'CO2 Etkisi',
                        subtitle: 'Doğaya katkını hemen incele',
                        onTap: () {},
                      ),
                    ] else ...[
                      _buildActionCard(
                        icon: Icons.volunteer_activism,
                        iconColor: themeColor,
                        title: 'İlanları gör',
                        subtitle: 'Yardım edebileceğin yerleri keşfet',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.favorite,
                        iconColor: themeColor,
                        title: 'Gönüllü ol',
                        subtitle: 'Destek ol, fark yarat',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.map,
                        iconColor: themeColor,
                        title: 'Bölgeni seç',
                        subtitle: 'Yardım etmek istediğin bölgeyi bul',
                        onTap: () {},
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildActionCard(
                      icon: Icons.chat_bubble,
                      iconColor: themeColor,
                      title: 'Sorularını sor',
                      subtitle: 'Merak ettiğin her şeyi sorabilirsin',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Bottom Input Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Yemo'ya bir şey sor...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          Icon(Icons.mic_none, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
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
}
