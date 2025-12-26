import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// VFX Manager for Roguelike Puzzle Dungeon (MG-0005)
/// Puzzle + Roguelike 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();

  final Random _random = Random();

  // ============================================================
  // Puzzle Effects
  // ============================================================

  /// 퍼즐 매치 성공
  void showPuzzleMatch(Vector2 position, Color matchColor, {int matchSize = 3}) {
    final intensity = matchSize / 3;
    gameRef.add(
      _createBurstEffect(
        position: position,
        color: matchColor,
        count: (15 * intensity).toInt(),
        speed: 70 * intensity,
        lifespan: 0.5,
      ),
    );
  }

  /// 퍼즐 콤보
  void showPuzzleCombo(Vector2 position, int comboCount) {
    gameRef.add(_ComboText(position: position, combo: comboCount));

    if (comboCount >= 3) {
      gameRef.add(
        _createSparkleEffect(position: position, color: Colors.amber, count: 12),
      );
    }
  }

  /// 퍼즐 클리어 (스테이지 완료)
  void showPuzzleClear(Vector2 centerPosition) {
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isMounted) return;
        final offset = Vector2(
          (_random.nextDouble() - 0.5) * 150,
          (_random.nextDouble() - 0.5) * 100,
        );
        gameRef.add(
          _createExplosionEffect(
            position: centerPosition + offset,
            color: [Colors.yellow, Colors.orange, Colors.purple][i % 3],
            count: 25,
            radius: 60,
          ),
        );
      });
    }
    _triggerScreenShake(intensity: 4, duration: 0.4);
  }

  // ============================================================
  // Roguelike/Dungeon Effects
  // ============================================================

  /// 던전 입장 포탈
  void showDungeonPortal(Vector2 position) {
    gameRef.add(_PortalEffect(position: position));
  }

  /// 몬스터 스폰
  void showMonsterSpawn(Vector2 position) {
    gameRef.add(
      _createSmokeEffect(position: position, count: 12, color: Colors.purple.shade900),
    );
    gameRef.add(
      _createConvergeEffect(position: position, color: Colors.purple),
    );
  }

  /// 몬스터 피격
  void showMonsterHit(Vector2 position, {bool isCritical = false}) {
    gameRef.add(
      _createHitEffect(position: position, isCritical: isCritical),
    );
  }

  /// 몬스터 처치
  void showMonsterDeath(Vector2 position) {
    gameRef.add(
      _createExplosionEffect(
        position: position,
        color: Colors.red,
        count: 20,
        radius: 50,
      ),
    );
    gameRef.add(
      _createSmokeEffect(position: position, count: 6, color: Colors.grey),
    );
  }

  /// 보스 처치
  void showBossDeath(Vector2 position) {
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!isMounted) return;
        final offset = Vector2(
          (_random.nextDouble() - 0.5) * 60,
          (_random.nextDouble() - 0.5) * 60,
        );
        gameRef.add(
          _createExplosionEffect(
            position: position + offset,
            color: i % 2 == 0 ? Colors.orange : Colors.red,
            count: 35,
            radius: 70,
          ),
        );
      });
    }
    _triggerScreenShake(intensity: 12, duration: 1.0);
  }

  /// 데미지 숫자
  void showDamageNumber(Vector2 position, int damage, {bool isCritical = false}) {
    gameRef.add(
      _DamageNumber(position: position, damage: damage, isCritical: isCritical),
    );
  }

  // ============================================================
  // Item/Skill Effects
  // ============================================================

  /// 아이템 획득
  void showItemPickup(Vector2 position, {bool isRare = false}) {
    final color = isRare ? Colors.purple : Colors.blue;
    gameRef.add(
      _createSparkleEffect(position: position, color: color, count: isRare ? 15 : 10),
    );
    if (isRare) {
      gameRef.add(_createGroundCircle(position: position, color: Colors.purple));
    }
  }

  /// 스킬 획득/업그레이드
  void showSkillAcquire(Vector2 position, Color skillColor) {
    gameRef.add(
      _createRisingEffect(position: position, color: skillColor, count: 15, speed: 80),
    );
    gameRef.add(
      _createGroundCircle(position: position, color: skillColor),
    );
    gameRef.add(_SkillAcquireText(position: position));
  }

  /// 스킬 사용
  void showSkillUse(Vector2 position, Color skillColor) {
    gameRef.add(
      _createBurstEffect(
        position: position,
        color: skillColor,
        count: 20,
        speed: 100,
        lifespan: 0.4,
      ),
    );
  }

  /// 힐 효과
  void showHeal(Vector2 position, int amount) {
    gameRef.add(
      _createRisingEffect(position: position, color: Colors.green, count: 12, speed: 50),
    );
    showNumberPopup(position, '+$amount', color: Colors.green);
  }

  // ============================================================
  // Progression Effects
  // ============================================================

  /// 레벨업
  void showLevelUp(Vector2 position) {
    gameRef.add(
      _createExplosionEffect(
        position: position,
        color: Colors.amber,
        count: 40,
        radius: 80,
      ),
    );
    gameRef.add(_LevelUpText(position: position));
  }

  /// 골드 획득
  void showGoldGain(Vector2 position, int amount) {
    gameRef.add(
      _createCoinEffect(position: position, count: (amount / 20).clamp(5, 15).toInt()),
    );
  }

  /// 게임오버/사망
  void showPlayerDeath(Vector2 position) {
    gameRef.add(
      _createExplosionEffect(position: position, color: Colors.red, count: 50, radius: 100),
    );
    _triggerScreenShake(intensity: 15, duration: 0.8);
  }

  // ============================================================
  // Utility
  // ============================================================

  void showNumberPopup(Vector2 position, String text, {Color color = Colors.white}) {
    gameRef.add(_NumberPopup(position: position, text: text, color: color));
  }

  void _triggerScreenShake({double intensity = 5, double duration = 0.3}) {
    if (gameRef.camera.viewfinder.children.isNotEmpty) {
      gameRef.camera.viewfinder.add(
        MoveByEffect(
          Vector2(intensity, 0),
          EffectController(
            duration: duration / 10,
            repeatCount: (duration * 10).toInt(),
            alternate: true,
          ),
        ),
      );
    }
  }

  // ============================================================
  // Private Effect Generators
  // ============================================================

  ParticleSystemComponent _createBurstEffect({
    required Vector2 position,
    required Color color,
    required int count,
    required double speed,
    required double lifespan,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: lifespan,
        generator: (i) {
          final angle = (i / count) * 2 * pi;
          final velocity = Vector2(cos(angle), sin(angle)) *
              (speed * (0.5 + _random.nextDouble() * 0.5));

          return AcceleratedParticle(
            position: position.clone(),
            speed: velocity,
            acceleration: Vector2(0, 150),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final size = 4 * (1.0 - progress * 0.5);

                canvas.drawCircle(Offset.zero, size, Paint()..color = color.withOpacity(opacity));
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createExplosionEffect({
    required Vector2 position,
    required Color color,
    required int count,
    required double radius,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.7,
        generator: (i) {
          final angle = _random.nextDouble() * 2 * pi;
          final speed = radius * (0.4 + _random.nextDouble() * 0.6);
          final velocity = Vector2(cos(angle), sin(angle)) * speed;

          return AcceleratedParticle(
            position: position.clone(),
            speed: velocity,
            acceleration: Vector2(0, 100),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final size = 5 * (1.0 - progress * 0.3);

                canvas.drawCircle(Offset.zero, size, Paint()..color = color.withOpacity(opacity));
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createHitEffect({required Vector2 position, required bool isCritical}) {
    final count = isCritical ? 18 : 10;
    final speed = isCritical ? 120.0 : 80.0;
    final color = isCritical ? Colors.yellow : Colors.white;

    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.4,
        generator: (i) {
          final angle = (i / count) * 2 * pi;
          final velocity = Vector2(cos(angle), sin(angle)) * (speed * (0.5 + _random.nextDouble() * 0.5));

          return AcceleratedParticle(
            position: position.clone(),
            speed: velocity,
            acceleration: Vector2(0, 200),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final size = (isCritical ? 5 : 3) * (1.0 - progress * 0.5);

                canvas.drawCircle(Offset.zero, size, Paint()..color = color.withOpacity(opacity));
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createConvergeEffect({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 12,
        lifespan: 0.5,
        generator: (i) {
          final startAngle = (i / 12) * 2 * pi;
          final startPos = Vector2(cos(startAngle), sin(startAngle)) * 40;

          return MovingParticle(
            from: position + startPos,
            to: position.clone(),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final opacity = (1.0 - particle.progress * 0.5).clamp(0.0, 1.0);
                canvas.drawCircle(Offset.zero, 4, Paint()..color = color.withOpacity(opacity));
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createSparkleEffect({required Vector2 position, required Color color, required int count}) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.5,
        generator: (i) {
          final angle = _random.nextDouble() * 2 * pi;
          final speed = 50 + _random.nextDouble() * 40;
          final velocity = Vector2(cos(angle), sin(angle)) * speed;

          return AcceleratedParticle(
            position: position.clone(),
            speed: velocity,
            acceleration: Vector2(0, 40),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
                final size = 3 * (1.0 - particle.progress * 0.5);

                final path = Path();
                for (int j = 0; j < 4; j++) {
                  final a = (j * pi / 2);
                  if (j == 0) path.moveTo(cos(a) * size, sin(a) * size);
                  else path.lineTo(cos(a) * size, sin(a) * size);
                }
                path.close();
                canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createRisingEffect({required Vector2 position, required Color color, required int count, required double speed}) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.8,
        generator: (i) {
          final spreadX = (_random.nextDouble() - 0.5) * 30;
          return AcceleratedParticle(
            position: position.clone() + Vector2(spreadX, 0),
            speed: Vector2(0, -speed),
            acceleration: Vector2(0, -20),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
                canvas.drawCircle(Offset.zero, 3, Paint()..color = color.withOpacity(opacity));
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createSmokeEffect({required Vector2 position, required int count, required Color color}) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.8,
        generator: (i) {
          final spreadX = (_random.nextDouble() - 0.5) * 25;
          return AcceleratedParticle(
            position: position.clone() + Vector2(spreadX, 0),
            speed: Vector2((_random.nextDouble() - 0.5) * 15, -30 - _random.nextDouble() * 20),
            acceleration: Vector2(0, -10),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final opacity = (0.5 - progress * 0.5).clamp(0.0, 1.0);
                final size = 6 + progress * 10;
                canvas.drawCircle(Offset.zero, size, Paint()..color = color.withOpacity(opacity));
              },
            ),
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createGroundCircle({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 1,
        lifespan: 0.6,
        generator: (i) {
          return ComputedParticle(
            renderer: (canvas, particle) {
              final progress = particle.progress;
              final opacity = (1.0 - progress).clamp(0.0, 1.0);
              final radius = 15 + progress * 30;
              canvas.drawCircle(
                Offset(position.x, position.y),
                radius,
                Paint()
                  ..color = color.withOpacity(opacity * 0.4)
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2,
              );
            },
          );
        },
      ),
    );
  }

  ParticleSystemComponent _createCoinEffect({required Vector2 position, required int count}) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.7,
        generator: (i) {
          final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi / 4;
          final speed = 130 + _random.nextDouble() * 80;
          final velocity = Vector2(cos(angle), sin(angle)) * speed;

          return AcceleratedParticle(
            position: position.clone(),
            speed: velocity,
            acceleration: Vector2(0, 350),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final opacity = (1.0 - particle.progress * 0.2).clamp(0.0, 1.0);
                final rotation = particle.progress * 3 * pi;
                canvas.save();
                canvas.rotate(rotation);
                canvas.drawOval(const Rect.fromLTWH(-3, -2, 6, 4), Paint()..color = Colors.amber.withOpacity(opacity));
                canvas.restore();
              },
            ),
          );
        },
      ),
    );
  }
}

/// 포탈 이펙트
class _PortalEffect extends PositionComponent {
  _PortalEffect({required Vector2 position}) : super(position: position, anchor: Anchor.center);

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_time > 2.0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final progress = (_time / 2.0).clamp(0.0, 1.0);
    final opacity = progress < 0.5 ? progress * 2 : (1.0 - progress) * 2;

    for (int i = 0; i < 3; i++) {
      final radius = 20 + i * 15 + sin(_time * 3 + i) * 5;
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = Colors.purple.withOpacity(opacity * (0.5 - i * 0.15))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }
}

class _DamageNumber extends TextComponent {
  _DamageNumber({required Vector2 position, required int damage, required bool isCritical})
      : super(
          text: '$damage',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: isCritical ? 26 : 18,
              fontWeight: FontWeight.bold,
              color: isCritical ? Colors.yellow : Colors.white,
              shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(MoveByEffect(Vector2(0, -40), EffectController(duration: 0.7, curve: Curves.easeOut)));
    add(OpacityEffect.fadeOut(EffectController(duration: 0.7, startDelay: 0.2)));
    add(RemoveEffect(delay: 0.9));
  }
}

class _ComboText extends TextComponent {
  _ComboText({required Vector2 position, required int combo})
      : super(
          text: '$combo COMBO!',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 18 + combo.clamp(0, 10).toDouble(),
              fontWeight: FontWeight.bold,
              color: combo >= 5 ? Colors.orange : Colors.yellow,
              shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    scale = Vector2.all(0.5);
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.2, curve: Curves.elasticOut)));
    add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.8, curve: Curves.easeOut)));
    add(OpacityEffect.fadeOut(EffectController(duration: 0.8, startDelay: 0.3)));
    add(RemoveEffect(delay: 1.0));
  }
}

class _LevelUpText extends TextComponent {
  _LevelUpText({required Vector2 position})
      : super(
          text: 'LEVEL UP!',
          position: position + Vector2(0, -40),
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              letterSpacing: 2,
              shadows: [Shadow(color: Colors.orange, blurRadius: 8), Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    scale = Vector2.all(0.5);
    add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.3, curve: Curves.elasticOut)));
    add(MoveByEffect(Vector2(0, -25), EffectController(duration: 1.2, curve: Curves.easeOut)));
    add(OpacityEffect.fadeOut(EffectController(duration: 1.2, startDelay: 0.5)));
    add(RemoveEffect(delay: 1.7));
  }
}

class _SkillAcquireText extends TextComponent {
  _SkillAcquireText({required Vector2 position})
      : super(
          text: 'NEW SKILL!',
          position: position + Vector2(0, -35),
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
              shadows: [Shadow(color: Colors.blue, blurRadius: 8), Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    scale = Vector2.all(0.5);
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut)));
    add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.0, curve: Curves.easeOut)));
    add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.4)));
    add(RemoveEffect(delay: 1.4));
  }
}

class _NumberPopup extends TextComponent {
  _NumberPopup({required Vector2 position, required String text, required Color color})
      : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.6, curve: Curves.easeOut)));
    add(OpacityEffect.fadeOut(EffectController(duration: 0.6, startDelay: 0.2)));
    add(RemoveEffect(delay: 0.8));
  }
}
