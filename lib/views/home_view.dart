import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_module_type.dart';
import '../models/auth/user_model.dart';
import '../services/auth/user_session.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/common/app_bottom_nav_bar.dart';
import '../widgets/home/ad_banner_section.dart';
import '../widgets/home/home_card.dart';

/// Home ekranı — giriş tipine göre (Food / Business) farklı kartlar gösterir.
///
/// [HomeViewModel] oluşturulur ve ağacın altına sağlanır.
/// Tüm UI mantığı widget'lara, iş mantığı ViewModel'e delege edilir.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final userType = context.read<UserSession>().userType;

    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(userType: userType),
      child: const _HomeBody(),
    );
  }
}

/// Scaffold + layout — HomeViewModel'i dinler.
class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeViewModel>().startAutoScroll();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Banner Slider ─────────────────────────────
            const AdBannerSection(),

            const SizedBox(height: 60),

            // ── Navigasyon Kartları ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: vm.cards.asMap().entries.map((entry) {
                  final i = entry.key;
                  final card = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 16),
                    child: SizedBox(
                      height: 140,
                      child: HomeCard(
                        item: card,
                        onTap: () => Navigator.pushNamed(context, card.route),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
