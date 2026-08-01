import 'package:flutter/material.dart';
import '../widgets/conversation_card.dart';

/// ⭐ Follow Service — 관심 인물 추적
///
/// 사용자가 지정한 인물의 뉴스·일정·SNS를 추적.
/// 카드로 팔로우/언팔로우 관리.
class FollowService {
  static final FollowService _i = FollowService._();
  factory FollowService() => _i;
  FollowService._();

  final Map<String, List<FollowedPerson>> _follows = {
    '정치인': [],
    '스포츠인': [],
    '방송문화인': [],
  };

  List<FollowedPerson> get all => _follows.values.expand((e) => e).toList();
  Map<String, List<FollowedPerson>> get follows => _follows;

  /// Add a person to follow
  void follow(String category, String name, {String? keyword, String? twitterHandle}) {
    _follows.update(category, (list) {
      if (list.any((p) => p.name == name)) return list;
      list.add(FollowedPerson(name: name, category: category, keyword: keyword ?? name, twitterHandle: twitterHandle));
      return list;
    }, ifAbsent: () => [FollowedPerson(name: name, category: category, keyword: keyword ?? name)]);
  }

  void unfollow(String name) {
    for (final list in _follows.values) {
      list.removeWhere((p) => p.name == name);
    }
  }

  bool isFollowing(String name) => all.any((p) => p.name == name);

  // ─── Card-based setup ──────────────────────────

  static void askCategory(BuildContext ctx) {
    showCard(ctx, type: CardType.preference,
      statement: '관심 있는 인물의\n분야를 알려주세요.',
      backAnswer: '정치인·스포츠인·방송문화인 중\n관심 있는 분야를 선택해주세요.',
      pos: '선택하기', neg: '나중에');
  }

  /// Show categorized list
  static void showList(BuildContext ctx, String category) {
    // Would show chip-based selection with common names
  }

  // ─── Example suggestions per category ──────────

  static const _suggestions = {
    '정치인': ['윤석열', '이재명', '한동훈', '이준석', '조국', '트럼프', '바이든'],
    '스포츠인': ['손흥민', '류현진', '김연아', '메시', '호날두', '오타니'],
    '방송문화인': ['유재석', '아이유', 'BTS', '블랙핑크', '봉준호', '박찬욱'],
  };

  static List<String> suggestionsFor(String category) => _suggestions[category] ?? [];
}

class FollowedPerson {
  final String name;
  final String category;
  final String keyword; // 검색 키워드
  final String? twitterHandle;

  const FollowedPerson({
    required this.name, required this.category,
    required this.keyword, this.twitterHandle,
  });
}
