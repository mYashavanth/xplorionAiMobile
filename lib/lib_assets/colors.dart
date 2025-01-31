import 'package:flutter/material.dart';

const LinearGradient themeGradientColor = LinearGradient(
  begin: Alignment(1.00, -0.06),
  end: Alignment(-1, 0.06),
  colors: [
    Color(0xFF54AB6A),
    Color(0xFF0099FF),
  ],
);
const LinearGradient themeGradientColorReverse = LinearGradient(
  begin: Alignment(1.00, -0.06),
  end: Alignment(-1, 0.06),
  colors: [
    Color(0xFF0099FF),
    Color(0xFF54AB6A),
  ],
);

const LinearGradient noneThemeGradientColor = LinearGradient(
  begin: Alignment(1.00, -0.06),
  end: Alignment(-1, 0.06),
  colors: [
    Colors.transparent,
    Colors.transparent,
  ],
);

const LinearGradient remainCITabGradientColor = LinearGradient(
  colors: [
    Color(0xFFECF2FF),
    Color(0xFFECF2FF),
  ],
);

const themecolor = Colors.black;


 MaterialStateProperty<Color>  getMaterialStateColor() {
    return MaterialStateProperty.all(const Color(0xFFFFFFFF));
  }

  MaterialStateProperty<OutlinedBorder> getMaterialStateShape() {
    return MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }