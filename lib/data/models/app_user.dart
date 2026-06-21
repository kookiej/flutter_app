class AppUser {
  final String id;
  final String spotifyUserId;
  final String? displayName;
  final int profileColor; // 아바타 색상 인덱스 (kAvatarPalette)
  final String? pfpUrl;
  final bool isPremium;

  const AppUser({
    required this.id,
    required this.spotifyUserId,
    this.displayName,
    this.profileColor = 0,
    this.pfpUrl,
    this.isPremium = false,
  });

  AppUser copyWith({
    String? displayName,
    int? profileColor,
    String? pfpUrl,
    bool clearPfpUrl = false,
  }) =>
      AppUser(
        id: id,
        spotifyUserId: spotifyUserId,
        displayName: displayName ?? this.displayName,
        profileColor: profileColor ?? this.profileColor,
        pfpUrl: clearPfpUrl ? null : (pfpUrl ?? this.pfpUrl),
        isPremium: isPremium,
      );

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        spotifyUserId: json['spotifyUserId'] as String,
        displayName: json['displayName'] as String?,
        profileColor: json['profileColor'] as int? ?? 0,
        pfpUrl: json['pfpUrl'] as String?,
        isPremium: json['isPremium'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'spotifyUserId': spotifyUserId,
        'displayName': displayName,
        'profileColor': profileColor,
        'pfpUrl': pfpUrl,
        'isPremium': isPremium,
      };
}
