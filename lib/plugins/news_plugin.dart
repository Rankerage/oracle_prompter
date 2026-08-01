import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 📰 News Plugin — RSS 뉴스를 카드로
///
/// 앱을 떠나지 않고 뉴스 소비.
/// 각 뉴스는 카드 앞면(제목) + 뒷면(요약+링크).
/// '더 보기'는 인앱 WebView.
class NewsPlugin {
  static final NewsPlugin _i = NewsPlugin._();
  factory NewsPlugin() => _i;
  NewsPlugin._();

  final List<NewsCard> _cards = [];
  bool _loading = false;

  // ─── Fetch ────────────────────────────────────

  Future<List<NewsCard>> fetch({String topic = 'top'}) async {
    _loading = true;

    // Use free RSS feeds (no API key needed)
    final feeds = {
      'top': 'https://feeds.bbci.co.uk/news/rss.xml',
      'tech': 'https://feeds.bbci.co.uk/news/technology/rss.xml',
      'world': 'https://feeds.bbci.co.uk/news/world/rss.xml',
    };

    try {
      final url = feeds[topic] ?? feeds['top']!;
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return _fallbackNews(topic);

      // Simple RSS parsing (no XML package needed)
      final body = res.body;
      final items = _parseRssItems(body);

      _cards.clear();
      for (final item in items.take(10)) {
        _cards.add(NewsCard(
          title: item['title'] ?? '',
          summary: item['description'] ?? '',
          link: item['link'] ?? '',
          imageUrl: _extractImage(item['description'] ?? ''),
        ));
      }
    } catch (_) {
      _cards.setAll(0, _fallbackNews(topic));
    }

    _loading = false;
    return _cards;
  }

  // ─── Simple RSS parser ────────────────────────

  List<Map<String, String>> _parseRssItems(String xml) {
    final items = <Map<String, String>>[];
    final itemRegex = RegExp(r'<item>(.*?)</item>', dotAll: true);
    for (final match in itemRegex.allMatches(xml)) {
      final content = match.group(1)!;
      items.add({
        'title': _tagContent(content, 'title'),
        'description': _cleanHtml(_tagContent(content, 'description')),
        'link': _tagContent(content, 'link'),
      });
    }
    return items;
  }

  String _tagContent(String xml, String tag) {
    final m = RegExp('<$tag.*?>(.*?)</$tag>', dotAll: true).firstMatch(xml);
    return m?.group(1)?.trim() ?? '';
  }

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  String _extractImage(String html) {
    final m = RegExp(r'<img[^>]*src="([^"]*)"').firstMatch(html);
    return m?.group(1) ?? '';
  }

  // ─── Fallback (when RSS fails) ────────────────

  List<NewsCard> _fallbackNews(String topic) => [
    NewsCard(title: '오늘의 주요 뉴스를 불러오는 중이에요.',
        summary: '인터넷 연결을 확인해주세요. 잠시 후 다시 시도할게요.',
        link: '', imageUrl: ''),
  ];

  // ─── Show as cards ────────────────────────────

  void showAsCards(BuildContext ctx) {
    for (final card in _cards) {
      _showNewsCard(ctx, card);
    }
  }

  void _showNewsCard(BuildContext ctx, NewsCard card) {
    // Would show as ConversationCard with image support
  }
}

class NewsCard {
  final String title, summary, link, imageUrl;
  const NewsCard({
    required this.title, required this.summary,
    required this.link, required this.imageUrl,
  });
}
