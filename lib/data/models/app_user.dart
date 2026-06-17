class AppUser {
  final String id;
  final String spotifyUserId;
  final String? displayName;
  final String? pfpUrl;
  final bool isPremium;

  const AppUser({
    required this.id,
    required this.spotifyUserId,
    this.displayName,
    this.pfpUrl,
    this.isPremium = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        spotifyUserId: json['spotifyUserId'] as String,
        displayName: json['displayName'] as String?,
        pfpUrl: json['pfpUrl'] as String?,
        isPremium: json['isPremium'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'spotifyUserId': spotifyUserId,
        'displayName': displayName,
        'pfpUrl': pfpUrl,
        'isPremium': isPremium,
      };
}
