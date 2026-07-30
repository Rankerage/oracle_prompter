/// 🧩 TikiTaka Plugin — 모든 확장 에이전트의 기본 인터페이스
///
/// TikiTaka는 플랫폼. 플러그인은 확장.
/// 각 플러그인은 고유한 capability 집합으로 등록된다.
abstract class TikiTakaPlugin {
  String get name;
  String get description;
  List<String> get capabilities; // e.g. ["coach", "record", "graph"]
  bool get isEnabled;

  Future<void> init();
  Future<String?> handle(String task, Map<String, dynamic> context);
  Future<void> dispose();
}

/// 🧠 OraclePrompter Plugin — 코칭·기록·마인드그래프
class OraclePrompterPlugin extends TikiTakaPlugin {
  @override String get name => 'OraclePrompter';
  @override String get description => 'AI 대화 코칭, 음성 녹음, 마인드그래프 시각화';
  @override List<String> get capabilities => ['coach', 'record', 'graph', 'journal'];
  bool _enabled = false;

  @override bool get isEnabled => _enabled;

  @override Future<void> init() async { _enabled = true; }

  @override Future<String?> handle(String task, Map<String, dynamic> context) async {
    return switch (task) {
      'coach' => '(코칭 활성화)',
      'record' => '(녹음 시작)',
      'graph' => '(그래프 업데이트)',
      _ => null,
    };
  }

  @override Future<void> dispose() async { _enabled = false; }
}

/// 🔌 Plugin Registry — TikiTaka에 연결된 모든 플러그인 관리
class PluginRegistry {
  static final PluginRegistry _i = PluginRegistry._();
  factory PluginRegistry() => _i;
  PluginRegistry._();

  final Map<String, TikiTakaPlugin> _plugins = {};

  void register(TikiTakaPlugin plugin) {
    _plugins[plugin.name] = plugin;
  }

  T? get<T extends TikiTakaPlugin>() =>
      _plugins.values.whereType<T>().firstOrNull;

  List<TikiTakaPlugin> get enabled =>
      _plugins.values.where((p) => p.isEnabled).toList();

  List<String> get availableNames => _plugins.keys.toList();

  /// Route task to best-matching plugin
  Future<String?> route(String task, Map<String, dynamic> context) async {
    for (final p in _plugins.values) {
      if (p.isEnabled && p.capabilities.any((c) => task.contains(c))) {
        return p.handle(task, context);
      }
    }
    return null;
  }
}
