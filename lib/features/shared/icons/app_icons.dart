import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static Widget home({bool active = false, Color? color}) => SvgPicture.string(
    '<svg width="22" height="22" viewBox="0 0 24 24" fill="${active ? (color != null ? _hex(color) : "#a78bfa") : "none"}" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z" stroke="${_hex(color ?? (active ? const Color(0xFFa78bfa) : const Color(0x4DFFFFFF)))}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<polyline points="9 22 9 12 15 12 15 22" stroke="${_hex(color ?? (active ? const Color(0xFFa78bfa) : const Color(0x4DFFFFFF)))}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" fill="none"/>'
    '</svg>',
    width: 22, height: 22,
  );

  static Widget search({Color? color}) => SvgPicture.string(
    '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<circle cx="11" cy="11" r="8" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8"/>'
    '<line x1="21" y1="21" x2="16.65" y2="16.65" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>',
    width: 22, height: 22,
  );

  static Widget library({Color? color}) => SvgPicture.string(
    '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M4 19.5A2.5 2.5 0 016.5 17H20" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 22, height: 22,
  );

  static Widget profile({bool active = false, Color? color}) => SvgPicture.string(
    '<svg width="22" height="22" viewBox="0 0 24 24" fill="${active ? _hex(color ?? const Color(0xFFa78bfa)) : "none"}" fill-opacity="${active ? "0.15" : "0"}" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" stroke="${_hex(color ?? (active ? const Color(0xFFa78bfa) : const Color(0x4DFFFFFF)))}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<circle cx="12" cy="7" r="4" stroke="${_hex(color ?? (active ? const Color(0xFFa78bfa) : const Color(0x4DFFFFFF)))}" stroke-width="1.8"/>'
    '</svg>',
    width: 22, height: 22,
  );

  static Widget play({Color? color}) => SvgPicture.string(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="${_hex(color ?? Colors.white)}" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M8 5.14v14l11-7-11-7z"/>'
    '</svg>',
    width: 24, height: 24,
  );

  static Widget pause({Color? color}) => SvgPicture.string(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="${_hex(color ?? Colors.white)}" xmlns="http://www.w3.org/2000/svg">'
    '<rect x="6" y="4" width="4" height="16" rx="1"/>'
    '<rect x="14" y="4" width="4" height="16" rx="1"/>'
    '</svg>',
    width: 24, height: 24,
  );

  static Widget playLarge({Color? color}) => SvgPicture.string(
    '<svg width="32" height="32" viewBox="0 0 24 24" fill="${_hex(color ?? Colors.white)}" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M8 5.14v14l11-7-11-7z"/>'
    '</svg>',
    width: 32, height: 32,
  );

  static Widget pauseLarge({Color? color}) => SvgPicture.string(
    '<svg width="32" height="32" viewBox="0 0 24 24" fill="${_hex(color ?? Colors.white)}" xmlns="http://www.w3.org/2000/svg">'
    '<rect x="6" y="4" width="4" height="16" rx="1"/>'
    '<rect x="14" y="4" width="4" height="16" rx="1"/>'
    '</svg>',
    width: 32, height: 32,
  );

  static Widget prevSm({Color? color}) => SvgPicture.string(
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M19 20L9 12l10-8v16z" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" fill="${_hex(color ?? Colors.white)}"/>'
    '<line x1="5" y1="4" x2="5" y2="20" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>',
    width: 18, height: 18,
  );

  static Widget nextSm({Color? color}) => SvgPicture.string(
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M5 4l10 8-10 8V4z" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" fill="${_hex(color ?? Colors.white)}"/>'
    '<line x1="19" y1="4" x2="19" y2="20" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>',
    width: 18, height: 18,
  );

  static Widget prev({Color? color}) => SvgPicture.string(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M19 20L9 12l10-8v16z" fill="${_hex(color ?? Colors.white)}" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>'
    '<line x1="5" y1="4" x2="5" y2="20" stroke="${_hex(color ?? Colors.white)}" stroke-width="2" stroke-linecap="round"/>'
    '</svg>',
    width: 24, height: 24,
  );

  static Widget next({Color? color}) => SvgPicture.string(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M5 4l10 8-10 8V4z" fill="${_hex(color ?? Colors.white)}" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>'
    '<line x1="19" y1="4" x2="19" y2="20" stroke="${_hex(color ?? Colors.white)}" stroke-width="2" stroke-linecap="round"/>'
    '</svg>',
    width: 24, height: 24,
  );

  static Widget shuffle({Color? color}) => SvgPicture.string(
    '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<polyline points="16 3 21 3 21 8" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<line x1="4" y1="20" x2="21" y2="3" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '<polyline points="21 16 21 21 16 21" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<line x1="15" y1="15" x2="21" y2="21" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '<line x1="4" y1="4" x2="9" y2="9" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>',
    width: 20, height: 20,
  );

  static Widget repeat({Color? color}) => SvgPicture.string(
    '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<polyline points="17 1 21 5 17 9" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M3 11V9a4 4 0 014-4h14" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<polyline points="7 23 3 19 7 15" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M21 13v2a4 4 0 01-4 4H3" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 20, height: 20,
  );

  static Widget heart({bool filled = false, Color? color}) => SvgPicture.string(
    '<svg width="22" height="22" viewBox="0 0 24 24" fill="${filled ? _hex(color ?? const Color(0xFFa78bfa)) : "none"}" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z" stroke="${_hex(color ?? (filled ? const Color(0xFFa78bfa) : const Color(0x80FFFFFF)))}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 22, height: 22,
  );

  static Widget queue({Color? color}) => SvgPicture.string(
    '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="3" y1="6" x2="21" y2="6" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '<line x1="3" y1="12" x2="21" y2="12" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '<line x1="3" y1="18" x2="21" y2="18" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>',
    width: 22, height: 22,
  );

  static Widget fanchant({Color? color}) => SvgPicture.string(
    '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M12 2c-1.7 0-3 1.2-3 2.6 0 .7.3 1.3.7 1.8L12 9l2.3-2.6c.4-.5.7-1.1.7-1.8C15 3.2 13.7 2 12 2z" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M12 9v13" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '<path d="M8 13H4l1 9h14l1-9h-4" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 22, height: 22,
  );

  static Widget chevronDown({Color? color}) => SvgPicture.string(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M6 9l6 6 6-6" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 24, height: 24,
  );

  static Widget chevronRight({Color? color}) => SvgPicture.string(
    '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M9 18l6-6-6-6" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 16, height: 16,
  );

  static Widget more({Color? color}) => SvgPicture.string(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="${_hex(color ?? Colors.white)}" xmlns="http://www.w3.org/2000/svg">'
    '<circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/>'
    '</svg>',
    width: 24, height: 24,
  );

  static Widget close({Color? color}) => SvgPicture.string(
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="18" y1="6" x2="6" y2="18" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '<line x1="6" y1="6" x2="18" y2="18" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>',
    width: 18, height: 18,
  );

  static Widget clock({Color? color}) => SvgPicture.string(
    '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<circle cx="12" cy="12" r="10" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8"/>'
    '<polyline points="12 6 12 12 16 14" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 16, height: 16,
  );

  static Widget bell({Color? color}) => SvgPicture.string(
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M13.73 21a2 2 0 01-3.46 0" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 18, height: 18,
  );

  static Widget settings({Color? color}) => SvgPicture.string(
    '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<circle cx="12" cy="12" r="3" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8"/>'
    '<path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-2 2 2 2 0 01-2-2v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 01-2-2 2 2 0 012-2h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 012-2 2 2 0 012 2v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 012 2 2 2 0 01-2 2h-.09a1.65 1.65 0 00-1.51 1z" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8"/>'
    '</svg>',
    width: 20, height: 20,
  );

  static Widget eyeOpen({Color? color}) => SvgPicture.string(
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<circle cx="12" cy="12" r="3" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8"/>'
    '</svg>',
    width: 18, height: 18,
  );

  static Widget eyeClosed({Color? color}) => SvgPicture.string(
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19m-6.72-1.07a3 3 0 11-4.24-4.24" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<line x1="1" y1="1" x2="23" y2="23" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>',
    width: 18, height: 18,
  );

  static Widget kakao() => SvgPicture.string(
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="#191919" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M12 3C6.477 3 2 6.477 2 10.8c0 2.712 1.67 5.1 4.2 6.54l-1.07 3.96 4.63-3.06c.73.1 1.49.16 2.24.16 5.523 0 10-3.477 10-7.8S17.523 3 12 3z"/>'
    '</svg>',
    width: 18, height: 18,
  );

  static Widget apple() => SvgPicture.string(
    '<svg width="16" height="18" viewBox="0 0 814 1000" fill="white" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76 0-103.7 40.8-165.9 40.8s-105-57.8-155.5-127.4C46 680.4 0 600.5 0 524.5c0-195.6 132.7-299.1 263.3-299.1 69.6 0 127.5 45.9 170.9 45.9 41.4 0 106.1-48.3 183.1-48.3 68.2 0 135.4 31.7 181.7 83.2zm-289.7-111c-16.7 19.7-46.3 35.2-75.9 35.2-3.5 0-7-.3-10.4-.9-1-3.7-1.4-7.5-1.4-11.6 0-41.5 24.1-83.7 57.9-109.1 16.2-12.5 48.3-29.2 74.8-31.6.9 3.7 1.2 7.5 1.2 11.3 0 43.3-22.6 83.8-46.2 106.7z"/>'
    '</svg>',
    width: 16, height: 18,
  );

  static Widget drag({Color? color}) => SvgPicture.string(
    '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<line x1="4" y1="8" x2="20" y2="8" stroke="${_hex(color ?? const Color(0x40FFFFFF))}" stroke-width="1.5" stroke-linecap="round"/>'
    '<line x1="4" y1="12" x2="20" y2="12" stroke="${_hex(color ?? const Color(0x40FFFFFF))}" stroke-width="1.5" stroke-linecap="round"/>'
    '<line x1="4" y1="16" x2="20" y2="16" stroke="${_hex(color ?? const Color(0x40FFFFFF))}" stroke-width="1.5" stroke-linecap="round"/>'
    '</svg>',
    width: 18, height: 18,
  );

  static Widget check({Color? color}) => SvgPicture.string(
    '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<polyline points="20 6 9 17 4 12" stroke="${_hex(color ?? Colors.white)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 14, height: 14,
  );

  static String _hex(Color c) {
    return '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
