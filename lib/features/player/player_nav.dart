import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../album/album_page.dart';
import '../artist/artist_page.dart';

/// 현재 재생곡의 아티스트 채널 라우트. (context는 await 이전에 동기적으로 사용)
Route<void> artistRouteForCurrentSong(BuildContext context) {
  final catalog = context.read<CatalogProvider>();
  final song = catalog.songs[context.read<PlayerProvider>().songIdx];
  return ArtistPage.route(catalog.artistByName(song.artist));
}

/// 현재 재생곡이 속한 앨범 라우트. 매칭 앨범이 없으면 null.
Route<void>? albumRouteForCurrentSong(BuildContext context) {
  final catalog = context.read<CatalogProvider>();
  final song = catalog.songs[context.read<PlayerProvider>().songIdx];
  final album = catalog.albumFor(song);
  return album == null ? null : AlbumPage.route(album);
}
