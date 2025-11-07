class GameSession {
  GameSession._();
  static final GameSession I = GameSession._();

  double maxLife = 100;
  double? _life;

  double get life => (_life ?? maxLife).clamp(0, maxLife);
  void setLife(double v) => _life = v.clamp(0, maxLife);

  void resetLife() => _life = maxLife;
}