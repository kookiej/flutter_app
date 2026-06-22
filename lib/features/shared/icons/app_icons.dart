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

  static Widget bookmark({bool filled = false, Color? color}) => SvgPicture.string(
    '<svg width="22" height="22" viewBox="0 0 24 24" fill="${filled ? _hex(color ?? const Color(0xFFa78bfa)) : "none"}" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z" stroke="${_hex(color ?? (filled ? const Color(0xFFa78bfa) : const Color(0x80FFFFFF)))}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
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

  // 응원봉(lightstick) — 프로토타입 FanchantIcon 그대로. 회전(-30°)·글로우는 호출부에서 처리.
  static Widget fanchant({Color? color}) => SvgPicture.string(
    '<svg width="25" height="25" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M7.7 13.09 A5.4 5.4 0 1 1 11.3 13.09 L11.2 19.9 Q11.1 21.4 9.55 21.4 L9.45 21.4 Q7.9 21.4 7.8 19.9 Z" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.7" stroke-linejoin="round" stroke-linecap="round" fill="none"/>'
    '<line x1="9.5" y1="15.6" x2="9.5" y2="18.1" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.7" stroke-linecap="round"/>'
    '</svg>',
    width: 25, height: 25,
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

  static Widget naver() => SvgPicture.string(
    '<svg width="16" height="16" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M3.6 3.6h4.4l4 6.2V3.6h4.4v12.8h-4.4l-4-6.2v6.2H3.6V3.6z" fill="#03C75A"/>'
    '</svg>',
    width: 16, height: 16,
  );

  static Widget apple() => SvgPicture.string(
    '<svg width="17" height="20" viewBox="0 0 24 24" fill="white" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09zM12 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>'
    '</svg>',
    width: 17, height: 20,
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

  static Widget pencil({Color? color}) => SvgPicture.string(
    '<svg width="19" height="19" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 013 3L7 19l-4 1 1-4 12.5-12.5z" stroke="${_hex(color ?? const Color(0xFFA78BFA))}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 19, height: 19,
  );

  static Widget camera({Color? color}) => SvgPicture.string(
    '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" stroke="${_hex(color ?? Colors.white)}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
    '<circle cx="12" cy="13" r="4" stroke="${_hex(color ?? Colors.white)}" stroke-width="2"/>'
    '</svg>',
    width: 15, height: 15,
  );

  static Widget logout({Color? color}) => SvgPicture.string(
    '<svg width="17" height="17" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 17, height: 17,
  );

  // 더보기 메뉴 — 아티스트 채널
  static Widget artistChannel({Color? color}) => SvgPicture.string(
    '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8z" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>',
    width: 20, height: 20,
  );

  // 더보기 메뉴 — 앨범(비닐)
  static Widget albumDisc({Color? color}) => SvgPicture.string(
    '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<circle cx="12" cy="12" r="9" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8"/>'
    '<circle cx="12" cy="12" r="2.5" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8"/>'
    '</svg>',
    width: 20, height: 20,
  );

  // 더보기 메뉴 — 응원법 영상
  static Widget fanchantVideo({Color? color}) => SvgPicture.string(
    '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<rect x="3" y="5" width="18" height="14" rx="3" stroke="${_hex(color ?? Colors.white)}" stroke-width="1.8"/>'
    '<path d="M10 9l5 3-5 3V9z" fill="${_hex(color ?? Colors.white)}"/>'
    '</svg>',
    width: 20, height: 20,
  );

  static String _hex(Color c) {
    return '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
