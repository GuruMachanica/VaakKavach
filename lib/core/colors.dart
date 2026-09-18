import 'package:flutter/material.dart';

// ─── Dark Black Noir Palette (Pure Pitch-Black & Cold Titanium) ────────────────

// Backgrounds (True Pitch Noir & Deep Obsidian)
const Color bgPrimary = Color(0xFF000000);        // Absolute Pure Pitch Black
const Color bgSurface = Color(0xFF0A0A0A);        // Deep Obsidian Card Surface
const Color bgSurfaceLight = Color(0xFF141414);   // Cold Charcoal Highlight
const Color bgElevated = Color(0xFF121212);       // Elevated Dark Carbon Fill
const Color bgSurfaceBorder = Color(0xFF222222);   // Razor Precision Noir Border
const Color bgInput = Color(0xFF080808);          // Matte Pitch Input

// Primary Accents (Cold Titanium, Silver & Stealth Monochrome)
const Color accentCyan = Color(0xFFE2E8F0);       // Cold Platinum Silver
const Color accentTeal = Color(0xFFCBD5E1);       // Brushed Titanium Interactive
const Color accentTealDim = Color(0xFF334155);    // Subdued Gunmetal Rim
const Color accentTealDark = Color(0xFF1E293B);   // Deep Graphite Tint
const Color accentEmerald = Color(0xFF10B981);    // Cold Cyber Emerald

// Typography (Stark High-Contrast Monochrome)
const Color textPrimary = Color(0xFFFFFFFF);      // Pure Stark White
const Color textSecondary = Color(0xFFA1A1AA);    // Frosted Titanium Silver
const Color textMuted = Color(0xFF6B7280);        // Cold Steel Charcoal

// Borders & Dividers
const Color inputBorder = Color(0xFF262626);      // Razor Hairline Dark Border
const Color inputBorderFocus = Color(0xFFE2E8F0); // Focused White Glow

// Threat & Risk Indicators (Cinematic Chiaroscuro & Laser Glow)
const Color riskGreen = Color(0xFF10B981);        // Verified Safe
const Color riskYellow = Color(0xFFF59E0B);       // Warning / Caution Amber
const Color riskRed = Color(0xFFEF4444);          // Laser Crimson Critical

// Noir Gradients
const LinearGradient bgGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
);

const RadialGradient shieldGlowGradient = RadialGradient(
  center: Alignment.center,
  radius: 0.8,
  colors: [Color(0xFF171717), Color(0xFF000000)],
);

const LinearGradient cyanGlowGradient = LinearGradient(
  colors: [Color(0xFFFFFFFF), Color(0xFF94A3B8)],
);

const LinearGradient threatGlowGradient = LinearGradient(
  colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
);
