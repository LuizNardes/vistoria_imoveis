import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define a fonte padrão como 'Inter'
  static final String? _fontFamily = GoogleFonts.inter().fontFamily;

  static final ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.brandBlue, // Azul corporativo sólido
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      
      // Arredondamento consistente de 12px (Moderno, mas não "bolha")
      defaultRadius: 12.0, 
      elevatedButtonSchemeColor: SchemeColor.primary,
      elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
      
      // Inputs modernos
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 12.0,
    ),
    visualDensity: VisualDensity.comfortable,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: _fontFamily,
  );

  static final ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.brandBlue,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 12.0,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 12.0,
    ),
    visualDensity: VisualDensity.comfortable,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: _fontFamily,
  );
}