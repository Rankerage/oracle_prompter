import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../models/journal_entry.dart';

/// 📖 기록 탭 — 자동 일기장 + 세션 관리
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();
    // 데모 데이터
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final journal = context.read<JournalProvider>();
      if (journal.entries.isEmpty) {
        journal.createSession('오늘의 대화');
        journal.addEntry(JournalEntry(
          id: 'demo_1',
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          title: '팀 미팅 — 프로젝트 방향 논의',
          summary: 'AI 에이전트의 실시간 코칭 가능성에 대한 팀 논의. 다언증 문제와 심리적 접근법이 주요 화두.',
          keywords: ['AI', '코칭', '심리', '통화', '마인드그래프'],
          locations: [LocationPoint(latitude: 37.5665, longitude: 126.9780, name: '강남구', timestamp: DateTime.now().subtract(const Duration(hours: 2)))],
          mood: 'productive',
        ));
        journal.addEntry(JournalEntry(
          id: 'demo_2',
          startTime: DateTime.now().subtract(const Duration(hours: 5)),
          endTime: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
          title: '카페에서 — Oracle 컨설팅 세션',
          summary: 'OraclePrompter 앱 설계에 대한 1:1 컨설팅. 마인드그래프 시각화와 역할 스위칭 기능 추가 결정.',
          keywords: ['앱설계', 'Oracle', '마인드그래프', 'UX'],
          locations: [LocationPoint(latitude: 37.5545, longitude: 126.9706, name: '서울역 카페', timestamp: DateTime.now().subtract(const Duration(hours: 5)))],
          mood: 'inspired',
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단: 세션 선택 + 새 세션
        _buildSessionBar(journal),
        // 일기장 타임라인
        Expanded(
          child: journal.entries.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: journal.entries.length,
                  itemBuilder: (context, i) => _buildEntryCard(journal.entries[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildSessionBar(JournalProvider journal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(Icons.menu_book, color: const Color(0xFFD4A574).withAlpha(180), size: 20),
          const SizedBox(width: 8),
          Text('대화 일지', style: TextStyle(
            color: Colors.grey.shade300, fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          // 새 세션
          GestureDetector(
            onTap: () {
              journal.createSession('세션 ${journal.sessions.length + 1}');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A574).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14, color: const Color(0xFFD4A574)),
                  const SizedBox(width: 4),
                  Text('새 세션', style: TextStyle(
                    color: const Color(0xFFD4A574), fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return GestureDetector(
      onTap: () => _showEntryDetail(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 시간 + 위치
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${entry.startTime.hour}:${entry.startTime.minute.toString().padLeft(2, '0')}'
                  ' - ${entry.endTime?.hour ?? '?'}:${entry.endTime?.minute.toString().padLeft(2, '0') ?? '?'}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                if (entry.locations.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.location_on, size: 12, color: const Color(0xFF6AC9D4).withAlpha(180)),
                  const SizedBox(width: 4),
                  Text(entry.locations.first.name ?? '',
                    style: TextStyle(color: const Color(0xFF6AC9D4).withAlpha(180), fontSize: 11)),
                ],
                const Spacer(),
                if (entry.mood != null)
                  _moodIcon(entry.mood!),
              ],
            ),
            const SizedBox(height: 8),
            // 제목
            Text(entry.title, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            // 요약
            Text(entry.summary, style: TextStyle(
              color: Colors.grey.shade500, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            // 키워드
            Wrap(
              spacing: 6, runSpacing: 4,
              children: entry.keywords.map((kw) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574).withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('#$kw', style: TextStyle(
                  color: const Color(0xFFD4A574).withAlpha(200), fontSize: 10)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodIcon(String mood) {
    final icons = {
      'productive': '⚡',
      'inspired': '💡',
      'happy': '😊',
      'calm': '😌',
      'tense': '😤',
    };
    return Text(icons[mood] ?? '', style: const TextStyle(fontSize: 16));
  }

  void _showEntryDetail(JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(entry.title, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 8),
            Text(entry.summary, style: TextStyle(
              color: Colors.grey.shade400, fontSize: 13, height: 1.5)),
            const SizedBox(height: 16),
            if (entry.locations.isNotEmpty)
              Row(children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFF6AC9D4)),
                const SizedBox(width: 6),
                Text(entry.locations.map((l) => l.name ?? '이동').join(' → '),
                  style: const TextStyle(color: Color(0xFF6AC9D4), fontSize: 12)),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book, size: 64, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          Text('대화를 시작하면\n자동으로 일기가 생성됩니다',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }
}
