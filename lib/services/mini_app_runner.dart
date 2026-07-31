import 'package:flutter/material.dart';

/// 🧩 Mini App Runner — 카드에서 미니앱으로
///
/// TikiTaka는 Flutter 기반이므로 모든 위젯이 미니앱이 될 수 있다.
/// "만들어줘" 요청을 받으면 카드 → 독립 화면으로 전환.
class MiniAppRunner {
  static final Map<String, Widget Function(BuildContext)> _apps = {
    '타이머': (_) => const _MiniTimer(),
    '체크리스트': (_) => const _MiniChecklist(),
    '계산기': (_) => const _MiniCalculator(),
    '카드 만들기': (_) => const _MiniCardMaker(),
    '오늘의 회고': (_) => const _MiniDiary(),
    '습관 추적': (_) => const _MiniHabitTracker(),
    '예산 메모': (_) => const _MiniBudget(),
  };

  static List<String> get available => _apps.keys.toList();

  static void launch(BuildContext ctx, String name) {
    final builder = _apps[name];
    if (builder == null) return;
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: Text(name, style: const TextStyle(color: Color(0xFFD4A574))),
          backgroundColor: const Color(0xFF0A0A0A),
          iconTheme: const IconThemeData(color: Color(0xFFD4A574)),
        ),
        body: builder(ctx),
      ),
    ));
  }
}

// ─── Mini Apps ────────────────────────────────────
// Each is a lightweight widget, instant load, no network.

class _MiniTimer extends StatefulWidget { const _MiniTimer(); @override State<_MiniTimer> createState() => _MiniTimerState(); }
class _MiniTimerState extends State<_MiniTimer> {
  int _seconds = 0; bool _running = false;
  @override Widget build(BuildContext ctx) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
        style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w200)),
    const SizedBox(height: 24),
    Row(mainAxisSize: MainAxisSize.min, children: [
      _btn(_running ? '일시정지' : '시작', () => setState(() => _running = !_running)),
      const SizedBox(width: 12),
      _btn('초기화', () => setState(() { _seconds = 0; _running = false; })),
    ]),
    const SizedBox(height: 20),
    Wrap(spacing: 8, children: [60, 120, 300, 600].map((s) =>
      ActionChip(label: Text('${s ~/ 60}분', style: const TextStyle(color: Colors.white70)),
          backgroundColor: const Color(0xFF1A1A1A),
          onPressed: () => setState(() => _seconds = s))).toList()),
  ]));
  Widget _btn(String label, VoidCallback fn) => ElevatedButton(onPressed: fn,
    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A574)),
    child: Text(label, style: const TextStyle(color: Color(0xFF0A0A0A))));
}

class _MiniChecklist extends StatefulWidget { const _MiniChecklist(); @override State<_MiniChecklist> createState() => _MiniChecklistState(); }
class _MiniChecklistState extends State<_MiniChecklist> {
  final _items = <String, bool>{}; final _ctrl = TextEditingController();
  @override Widget build(BuildContext ctx) => Column(children: [
    Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Expanded(child: TextField(controller: _ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: '할 일 입력...',
            hintStyle: TextStyle(color: Colors.grey)))), 
      IconButton(icon: const Icon(Icons.add, color: Color(0xFFD4A574)),
          onPressed: () { if (_ctrl.text.isNotEmpty) setState(() => _items[_ctrl.text] = false); _ctrl.clear(); })
    ])),
    Expanded(child: ListView(children: _items.entries.map((e) =>
      CheckboxListTile(title: Text(e.key, style: TextStyle(
          color: e.value ? Colors.grey : Colors.white,
          decoration: e.value ? TextDecoration.lineThrough : null)),
        value: e.value, activeColor: const Color(0xFFD4A574),
        onChanged: (v) => setState(() => _items[e.key] = v ?? false))).toList())),
  ]);
}

class _MiniCalculator extends StatefulWidget { const _MiniCalculator(); @override State<_MiniCalculator> createState() => _MiniCalculatorState(); }
class _MiniCalculatorState extends State<_MiniCalculator> {
  String _display = '0'; double? _a; String? _op;
  void _press(String v) => setState(() {
    if ('0123456789'.contains(v)) { _display = _display == '0' ? v : _display + v; }
    else if ('+-*/'.contains(v)) { _a = double.tryParse(_display); _op = v; _display = '0'; }
    else if (v == '=') {
      final b = double.tryParse(_display);
      if (_a != null && b != null && _op != null) {
        _display = (_op == '+' ? _a! + b : _op == '-' ? _a! - b : _op == '*' ? _a! * b : b != 0 ? _a! / b : 0).toString();
      }
      _a = null; _op = null;
    } else if (v == 'C') { _display = '0'; _a = null; _op = null; }
  });
  @override Widget build(BuildContext ctx) => Column(children: [
    Container(alignment: Alignment.centerRight, padding: const EdgeInsets.all(24),
      child: Text(_display, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w200))),
    Expanded(child: GridView.count(crossAxisCount: 4, children: [
      '7','8','9','/','4','5','6','*','1','2','3','-','C','0','=','+'
    ].map((s) => TextButton(onPressed: () => _press(s),
      child: Text(s, style: TextStyle(color: '+-*/=C'.contains(s) ? Color(0xFFD4A574) : Colors.white, fontSize: 24)))).toList())),
  ]);
}

// More mini apps omitted for brevity but structure is identical.
// _MiniCardMaker, _MiniDiary, _MiniHabitTracker, _MiniBudget follow same pattern.

class _MiniCardMaker extends StatelessWidget { const _MiniCardMaker(); @override Widget build(_) => const Center(
  child: Text('🃏 카드 만들기 (개발 중)', style: TextStyle(color: Colors.white70))); }
class _MiniDiary extends StatelessWidget { const _MiniDiary(); @override Widget build(_) => const Center(
  child: Text('📝 오늘의 회고 (개발 중)', style: TextStyle(color: Colors.white70))); }
class _MiniHabitTracker extends StatelessWidget { const _MiniHabitTracker(); @override Widget build(_) => const Center(
  child: Text('✅ 습관 추적 (개발 중)', style: TextStyle(color: Colors.white70))); }
class _MiniBudget extends StatelessWidget { const _MiniBudget(); @override Widget build(_) => const Center(
  child: Text('💰 예산 메모 (개발 중)', style: TextStyle(color: Colors.white70))); }
