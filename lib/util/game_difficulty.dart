enum GameDifficulty {
  normal,
  hard,
}

extension GameDifficultyX on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.normal:
        return 'Normal';
      case GameDifficulty.hard:
        return 'Difficile';
    }
  }

  double get enemyHpMultiplier {
    switch (this) {
      case GameDifficulty.hard:
        return 2.0; // Les ennemis ont 2 fois plus de vie en mode difficile
      case GameDifficulty.normal:
        return 1.0;
    }
  }
}
