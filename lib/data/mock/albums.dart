import 'package:flutter/material.dart';
import '../models/album.dart';

/// 앨범 메타. 수록곡은 (artist, name) 매칭으로 kSongs에서 파생한다.
/// coverGradient/coverAccent 는 해당 앨범 곡들의 팔레트와 동일하게 맞춘다.
final List<Album> kAlbums = [
  Album(
    name: "BE", artist: "BTS", type: AlbumType.regular,
    releaseDate: DateTime(2020, 11, 20),
    coverGradient: [Color(0xFF1a0a2e), Color(0xFF4a2fa0), Color(0xFF7c3aed)],
    coverAccent: Color(0xFF7c3aed),
    titleTracks: ["Dynamite"],
  ),
  Album(
    name: "Butter", artist: "BTS", type: AlbumType.single,
    releaseDate: DateTime(2021, 5, 21),
    coverGradient: [Color(0xFF1a150a), Color(0xFF92400e), Color(0xFFd97706)],
    coverAccent: Color(0xFFd97706),
    titleTracks: ["Butter"],
  ),
  Album(
    name: "ARIRANG", artist: "BTS", type: AlbumType.single,
    releaseDate: DateTime(2023, 8, 18),
    coverGradient: [Color(0xFF1a150a), Color(0xFF92400e), Color(0xFFd97706)],
    coverAccent: Color(0xFFd97706),
    titleTracks: ["2.0"],
  ),
  Album(
    name: "LILAC", artist: "IU", type: AlbumType.regular,
    releaseDate: DateTime(2021, 3, 25),
    coverGradient: [Color(0xFF1a0e2e), Color(0xFF7b2d8b), Color(0xFFc026d3)],
    coverAccent: Color(0xFFc026d3),
    titleTracks: ["LILAC", "Celebrity"],
  ),
  Album(
    name: "After Like", artist: "IVE", type: AlbumType.single,
    releaseDate: DateTime(2022, 8, 22),
    coverGradient: [Color(0xFF0a1a0a), Color(0xFF166534), Color(0xFF16a34a)],
    coverAccent: Color(0xFF16a34a),
    titleTracks: ["After LIKE"],
  ),
  Album(
    name: "LOVE DIVE", artist: "IVE", type: AlbumType.single,
    releaseDate: DateTime(2022, 4, 5),
    coverGradient: [Color(0xFF0a0a1a), Color(0xFF1e1b4b), Color(0xFF4338ca)],
    coverAccent: Color(0xFF4338ca),
    titleTracks: ["LOVE DIVE"],
  ),
  Album(
    name: "NewJeans", artist: "NewJeans", type: AlbumType.mini,
    releaseDate: DateTime(2022, 8, 1),
    coverGradient: [Color(0xFF0a0f1a), Color(0xFF1e3a5f), Color(0xFF2563eb)],
    coverAccent: Color(0xFF2563eb),
    titleTracks: ["Hype Boy", "Attention"],
  ),
  Album(
    name: "I love", artist: "(G)I-DLE", type: AlbumType.mini,
    releaseDate: DateTime(2022, 10, 17),
    coverGradient: [Color(0xFF1a0a08), Color(0xFF7c2d12), Color(0xFFea580c)],
    coverAccent: Color(0xFFea580c),
    titleTracks: ["Nxde"],
  ),
  Album(
    name: "I feel", artist: "(G)I-DLE", type: AlbumType.mini,
    releaseDate: DateTime(2023, 5, 15),
    coverGradient: [Color(0xFF1a0a14), Color(0xFF831843), Color(0xFFdb2777)],
    coverAccent: Color(0xFFdb2777),
    titleTracks: ["Queencard"],
  ),
  Album(
    name: "ANTIFRAGILE", artist: "LE SSERAFIM", type: AlbumType.mini,
    releaseDate: DateTime(2022, 10, 17),
    coverGradient: [Color(0xFF1a1a0a), Color(0xFF713f12), Color(0xFFca8a04)],
    coverAccent: Color(0xFFca8a04),
    titleTracks: ["ANTIFRAGILE"],
  ),
  Album(
    name: "Savage", artist: "aespa", type: AlbumType.mini,
    releaseDate: DateTime(2021, 10, 5),
    coverGradient: [Color(0xFF0a1a1a), Color(0xFF134e4a), Color(0xFF0d9488)],
    coverAccent: Color(0xFF0d9488),
    titleTracks: ["Savage"],
  ),
  Album(
    name: "GOLDEN HOUR : Part.4", artist: "ATEEZ", type: AlbumType.single,
    releaseDate: DateTime(2024, 11, 15),
    coverGradient: [Color(0xFF0a0a1a), Color(0xFF1e1b4b), Color(0xFF4338ca)],
    coverAccent: Color(0xFF4338ca),
    titleTracks: ["Adrenaline"],
  ),
];
