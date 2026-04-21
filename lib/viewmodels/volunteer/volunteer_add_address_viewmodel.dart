import 'package:flutter/material.dart';

/// İl → İlçe → Mahalle hiyerarşik adres ViewModel'i.
/// Türkiye'deki gerçek il / ilçe / mahalle verileriyle çalışır (örnek veri seti).
class VolunteerAddAddressViewModel extends ChangeNotifier {
  // ─── Controllers ────────────────────────────────
  final TextEditingController adresController = TextEditingController();
  final TextEditingController baslikController = TextEditingController();

  // ─── Seçili değerler ────────────────────────────
  String? selectedIl;
  String? selectedIlce;
  String? selectedMahalle;

  // ─── Veri ───────────────────────────────────────

  /// İl listesi
  List<String> get iller => _data.keys.toList()..sort();

  /// Seçili ile göre ilçeler
  List<String> get ilceler {
    if (selectedIl == null) return [];
    final keys = _data[selectedIl]?.keys.toList() ?? [];
    return keys..sort();
  }

  /// Seçili ilçeye göre mahalleler
  List<String> get mahalleler {
    if (selectedIl == null || selectedIlce == null) return [];
    final list = _data[selectedIl]?[selectedIlce]?.toList() ?? [];
    return list..sort();
  }

  // ─── Seçim işlemleri ────────────────────────────

  void selectIl(String? il) {
    if (selectedIl == il) return;
    selectedIl = il;
    selectedIlce = null;
    selectedMahalle = null;
    notifyListeners();
  }

  void selectIlce(String? ilce) {
    if (selectedIlce == ilce) return;
    selectedIlce = ilce;
    selectedMahalle = null;
    notifyListeners();
  }

  void selectMahalle(String? mahalle) {
    if (selectedMahalle == mahalle) return;
    selectedMahalle = mahalle;
    notifyListeners();
  }

  /// Form çıktısı: "İstanbul / Kadıköy / Moda Mah. — Açık Adres"
  String get formattedAddress {
    final parts = [
      if (selectedIl != null) selectedIl!,
      if (selectedIlce != null) selectedIlce!,
      if (selectedMahalle != null) selectedMahalle!,
      if (adresController.text.trim().isNotEmpty) adresController.text.trim(),
    ];
    return parts.join(' / ');
  }

  bool get isValid =>
      selectedIl != null &&
      selectedIlce != null &&
      selectedMahalle != null &&
      adresController.text.trim().isNotEmpty;

  @override
  void dispose() {
    adresController.dispose();
    baslikController.dispose();
    super.dispose();
  }

  // ─── Türkiye Veri Seti (seçili iller + ilçeleri + mahalleler) ─────────────
  // Format: { 'İl': { 'İlçe': ['Mahalle1', 'Mahalle2', ...] } }
  static const Map<String, Map<String, List<String>>> _data = {
    'İstanbul': {
      'Kadıköy': ['Moda Mah.', 'Caferağa Mah.', 'Fenerbahçe Mah.', 'Göztepe Mah.', 'Kozyatağı Mah.', 'Bostancı Mah.'],
      'Beşiktaş': ['Sinanpaşa Mah.', 'Etiler Mah.', 'Levent Mah.', 'Abbasağa Mah.', 'Kuruçeşme Mah.'],
      'Şişli': ['Mecidiyeköy Mah.', 'Fulya Mah.', 'Bozkurt Mah.', 'Halaskargazi Mah.', 'Nişantaşı Mah.'],
      'Üsküdar': ['Selimiye Mah.', 'Kuzguncuk Mah.', 'Beylerbeyi Mah.', 'Çengelköy Mah.', 'Acıbadem Mah.'],
      'Fatih': ['Sultanahmet Mah.', 'Aksaray Mah.', 'Koca Mustafapaşa Mah.', 'Zeyrek Mah.', 'Balat Mah.'],
      'Pendik': ['Yenişehir Mah.', 'Kurtdoğmuş Mah.', 'Kavakpınar Mah.', 'Şeyhli Mah.'],
      'Ümraniye': ['Alemdağ Mah.', 'Armağanevler Mah.', 'Çakmak Mah.', 'Esentepe Mah.'],
      'Maltepe': ['Bağlarbaşı Mah.', 'Altıntepe Mah.', 'Cevizli Mah.', 'Fındıklı Mah.'],
    },
    'Ankara': {
      'Çankaya': ['Kavaklıdere Mah.', 'Kızılay Mah.', 'Çukurambar Mah.', 'Bahçelievler Mah.', 'Ayrancı Mah.'],
      'Keçiören': ['Etlik Mah.', 'Kalaba Mah.', 'Bağlum Mah.', 'Pınarbaşı Mah.'],
      'Mamak': ['Şahintepe Mah.', 'Karaağaç Mah.', 'Turgut Reis Mah.', 'Misket Bağları Mah.'],
      'Altındağ': ['Atıfbey Mah.', 'Hamamönü Mah.', 'Ulus Mah.', 'Hacettepe Mah.'],
      'Sincan': ['Atatürk Mah.', 'Fatih Mah.', 'Yunus Emre Mah.', 'Özgür Mah.'],
      'Etimesgut': ['Elvankent Mah.', 'Bağlıca Mah.', 'Söğütözü Mah.', 'Şehit Ahmet Özsoy Mah.'],
    },
    'İzmir': {
      'Bornova': ['Kazımdirik Mah.', 'Çiğli Mah.', 'Erzene Mah.', 'Yeşilova Mah.', 'Doğanlar Mah.'],
      'Karşıyaka': ['Mavişehir Mah.', 'Cumhuriyet Mah.', 'Bostanlı Mah.', 'Yalı Mah.'],
      'Konak': ['Alsancak Mah.', 'Basmane Mah.', 'Çankaya Mah.', 'Kahramanlar Mah.'],
      'Bayraklı': ['Manavkuyu Mah.', 'Mansuroğlu Mah.', 'Çiçekli Mah.', 'Osmangazi Mah.'],
      'Buca': ['Kaynaklar Mah.', 'Yaylacık Mah.', 'Kozağaç Mah.', 'Seyrek Mah.'],
    },
    'Bursa': {
      'Nilüfer': ['İhsaniye Mah.', 'Beşevler Mah.', 'Görükle Mah.', 'Fethiye Mah.'],
      'Osmangazi': ['Soğanlı Mah.', 'Yeşiltepe Mah.', 'Çekirge Mah.', 'Kükürtlü Mah.'],
      'Yıldırım': ['Millet Mah.', 'Esenevler Mah.', 'Panayır Mah.', 'Güneştepe Mah.'],
      'Mudanya': ['Güzelyalı Mah.', 'Burgaz Mah.', 'Kumyaka Mah.'],
    },
    'Antalya': {
      'Muratpaşa': ['Konyaaltı Mah.', 'Fener Mah.', 'Meltem Mah.', 'Gençlik Mah.'],
      'Kepez': ['Altınsaç Mah.', 'Varsak Mah.', 'Ege Mah.', 'Haşimişcan Mah.'],
      'Konyaaltı': ['Hurma Mah.', 'Liman Mah.', 'Sarısu Mah.', 'Siteler Mah.'],
      'Alanya': ['Oba Mah.', 'Kestel Mah.', 'Mahmutlar Mah.', 'Tosmur Mah.'],
    },
    'Adana': {
      'Seyhan': ['Çınarlı Mah.', 'Döşeme Mah.', 'Yenikent Mah.', 'Denizli Mah.'],
      'Yüreğir': ['Huzurevleri Mah.', 'Güzelyurt Mah.', 'Mahfesığmaz Mah.'],
      'Çukurova': ['Bağcılar Mah.', 'Sarıçam Mah.', 'Toros Mah.'],
    },
    'Kocaeli': {
      'İzmit': ['Körfez Mah.', 'Plajyolu Mah.', 'Yenidoğan Mah.', 'Akmeşe Mah.'],
      'Gebze': ['Güzeller Mah.', 'Pelitli Mah.', 'Eskihisar Mah.', 'Namazgâh Mah.'],
      'Darıca': ['Bağlarbaşı Mah.', 'Osmangazi Mah.', 'Cumhuriyet Mah.'],
    },
    'Karabük': {
      'Merkez': ['Yenişehir Mah.', 'Cumhuriyet Mah.', 'Beşpınar Mah.', 'Ereğli Mah.', 'Kışla Mah.', 'Bülent Ecevit Mah.'],
      'Safranbolu': ['Çarşı Mah.', 'Bağlar Mah.', 'Gümüştepe Mah.', 'Köprüaltı Mah.'],
      'Eflani': ['Ilıca Mah.', 'Sofular Mah.'],
      'Eskipazar': ['Yukarı Mah.', 'Aşağı Mah.', 'Çayüstü Mah.'],
    },
    'Samsun': {
      'Atakum': ['Denizevleri Mah.', 'Harikalar Mah.', 'Uğur Mumcu Mah.'],
      'İlkadım': ['Kılıçdede Mah.', 'Gazi Mah.', 'Çiftlik Mah.', 'Kadıköy Mah.'],
      'Canik': ['Esenevler Mah.', 'Gülbahçe Mah.', 'Yükseliş Mah.'],
    },
    'Konya': {
      'Selçuklu': ['Musalla Bağları Mah.', 'Büyükkayacık Mah.', 'Sille Mah.'],
      'Meram': ['Hasanköy Mah.', 'Gödene Mah.', 'Yeşilova Mah.'],
      'Karatay': ['Fevzi Çakmak Mah.', 'Nakipoğlu Mah.', 'Saraçoğlu Mah.'],
    },
    'Mersin': {
      'Yenişehir': ['Bahçe Mah.', 'Fuat Morel Mah.', 'Çankaya Mah.'],
      'Akdeniz': ['Demirtaş Mah.', 'Güneyyurt Mah.', 'Töngel Mah.'],
      'Mezitli': ['Davultepe Mah.', 'Kuyuluk Mah.', 'Tevfikiye Mah.'],
    },
    'Diyarbakır': {
      'Kayapınar': ['Bağcılar Mah.', 'Diclekent Mah.', 'Fırat Mah.'],
      'Bağlar': ['Bağcılar Mah.', 'Gürdoğan Mah.', 'Şehitlik Mah.'],
      'Sur': ['Alipaşa Mah.', 'Cevatpaşa Mah.', 'Hasanpaşa Mah.'],
    },
    'Gaziantep': {
      'Şahinbey': ['İncilipınar Mah.', 'Bağlarbaşı Mah.', 'Çamlıca Mah.'],
      'Şehitkamil': ['Güneykent Mah.', 'Beylerbeyi Mah.', 'Kozanlı Mah.'],
    },
  };
}
