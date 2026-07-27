import 'dart:convert';
import 'dart:io';
import 'tool.dart';

/// ─── Hermes-style Skill 엔진 ───
///
/// 마크다운(.md) 파일로 정의된 재사용 워크플로우.
/// Hermes의 `skill` 시스템을 O.P에 이식.
///
/// 스킬 파일 형식:
/// ```markdown
/// ---
/// name: defense
/// description: 다언증 회피
/// ---
///
/// ## Steps
/// 1. [tool:mic_in] 노이즈 주입 시작
/// 2. [tool:tts_out] "1단계 방어 작동"
/// ```

class Skill {
  final String name;
  final String description;
  final List<SkillStep> steps;

  const Skill({
    required this.name,
    required this.description,
    required this.steps,
  });

  factory Skill.fromMarkdown(String mdContent) {
    final lines = mdContent.split('\n');
    String name = '';
    String description = '';
    final steps = <SkillStep>[];
    bool inFrontmatter = false;
    bool inSteps = false;

    for (final line in lines) {
      if (line.trim() == '---') {
        inFrontmatter = !inFrontmatter;
        continue;
      }
      if (inFrontmatter) {
        if (line.startsWith('name:')) name = line.split(':')[1].trim();
        if (line.startsWith('description:')) description = line.split(':').sublist(1).join(':').trim();
      }
      if (line.contains('## Steps')) {
        inSteps = true;
        continue;
      }
      if (inSteps && line.trim().isNotEmpty) {
        steps.add(SkillStep.parse(line.trim()));
      }
    }

    return Skill(name: name, description: description, steps: steps);
  }

  Future<void> execute(ToolContext ctx) async {
    for (final step in steps) {
      await step.run(ctx);
    }
  }
}

class SkillStep {
  final String toolName;
  final Map<String, dynamic> params;

  const SkillStep({required this.toolName, required this.params});

  factory SkillStep.parse(String line) {
    // [tool:mic_in params={amplitude: 0.3}] 형식
    final toolMatch = RegExp(r'\[tool:(\w+)(?:\s+params=(\{.*?\}))?\]').firstMatch(line);
    if (toolMatch != null) {
      final tool = toolMatch.group(1)!;
      Map<String, dynamic> params = {};
      if (toolMatch.group(2) != null) {
        try {
          params = Map<String, dynamic>.from(
            jsonDecode(toolMatch.group(2)!) as Map);
        } catch (_) {}
      }
      return SkillStep(toolName: tool, params: params);
    }
    // [tool:mic_in] 형식
    final simpleMatch = RegExp(r'\[tool:(\w+)\]').firstMatch(line);
    if (simpleMatch != null) {
      return SkillStep(toolName: simpleMatch.group(1)!, params: {});
    }
    return const SkillStep(toolName: 'unknown', params: {});
  }

  Future<void> run(ToolContext ctx) async {
    await ctx.callTool(toolName, params);
  }
}

/// 스킬 로더 — assets/skills/ 디렉토리에서 .md 파일 로드
class SkillLoader {
  static Future<List<Skill>> loadFromDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    final skills = <Skill>[];
    if (!await dir.exists()) return skills;

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.md')) {
        final content = await entity.readAsString();
        skills.add(Skill.fromMarkdown(content));
      }
    }
    return skills;
  }
}
