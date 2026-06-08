class BusinessInsightModel {
  final String source;
  final String summary;
  final List<String> recommendations;
  final DateTime? generatedAt;

  BusinessInsightModel({
    required this.source,
    required this.summary,
    required this.recommendations,
    this.generatedAt,
  });

  factory BusinessInsightModel.fromJson(Map<String, dynamic> json) {
    return BusinessInsightModel(
      source: (json['source'] as String?) ?? 'rules',
      summary: (json['summary'] as String?) ?? '',
      recommendations: _parseRecommendations(json['recommendations']),
      generatedAt: DateTime.tryParse((json['generated_at'] as String?) ?? ''),
    );
  }

  static List<String> _parseRecommendations(dynamic data) {
    if (data is List) {
      return data
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }
}
