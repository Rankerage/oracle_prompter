import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/oracle_provider.dart';
import '../providers/app_providers.dart';
import '../providers/ai_config_provider.dart';
import '../providers/power_manager.dart';
import '../services/tts_service.dart';
import '../services/stt_service.dart';
import '../services/audio_effect_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OraclePrompterApp());
}

class OraclePrompterApp extends StatelessWidget {
  const OraclePrompterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OracleProvider()),
        ChangeNotifierProvider(create: (_) => MindGraphProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => AiConfigProvider()),
        ChangeNotifierProvider(create: (_) => PowerManager()),
        Provider(create: (_) => TtsService()),
        Provider(create: (_) => SttService()),
        Provider(create: (_) => AudioEffectService()),
      ],
      child: MaterialApp(
        title: 'OraclePrompter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD4A574),
            brightness: Brightness.dark,
            surface: const Color(0xFF0A0A0A),
            primary: const Color(0xFFD4A574),
            secondary: const Color(0xFFC9A96E),
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0D0D0D),
            selectedItemColor: Color(0xFFD4A574),
            unselectedItemColor: Color(0xFF555555),
            type: BottomNavigationBarType.fixed,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF141414),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withAlpha(20)),
            ),
          ),
        ),
        home: const AppEntry(),
      ),
    );
  }
}

/// 앱 진입점 — 온보딩 or 메인화면
class AppEntry extends StatefulWidget {
  const AppEntry({super.key});
  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _onboardingComplete = prefs.getBool('onboarding_complete') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD4A574))),
      );
    }
    if (!_onboardingComplete!) {
      return OnboardingScreen(onComplete: () {
        setState(() => _onboardingComplete = true);
      });
    }
    return const HomeScreen();
  }
}
