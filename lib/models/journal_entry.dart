/// 자동 생성된 일기장 엔트리
class JournalEntry {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String title; // 자동 생성된 제목
  final String summary; // AI 요약
  final List<String> keywords;
  final List<LocationPoint> locations;
  final List<String> mindGraphIds; // 연결된 마인드그래프
  final String? mood; // 감정
  final List<String>? mediaPaths; // 첨부 파일

  const JournalEntry({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.title,
    required this.summary,
    this.keywords = const [],
    this.locations = const [],
    this.mindGraphIds = const [],
    this.mood,
    this.mediaPaths,
  });
}

class LocationPoint {
  final double latitude;
  final double longitude;
  final String? name;
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.name,
    required this.timestamp,
  });
}

/// 세션
class Session {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isActive;
  final List<String> journalEntryIds;
  final List<String> mindGraphIds;

  const Session({
    required this.id,
    required this.title,
    required this.createdAt,
    this.lastActiveAt,
    this.isActive = false,
    this.journalEntryIds = const [],
    this.mindGraphIds = const [],
  });
}
