class PushSubscription {
  final String? userId;
  final String? pushToken;
  final String? playerId;
  final bool isSubscribed;
  final Map<String, String>? tags;

  PushSubscription({
    this.userId,
    this.pushToken,
    this.playerId,
    required this.isSubscribed,
    this.tags,
  });
}
