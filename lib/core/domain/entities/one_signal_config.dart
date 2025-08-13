class OneSignalConfig {
  final String appId;
  final bool enableInAppAlerts;
  final bool enableNotificationExtension;
  final bool requiresUserPrivacyConsent;
  final Map<String, String>? customTags;

  OneSignalConfig({
    required this.appId,
    this.enableInAppAlerts = true,
    this.enableNotificationExtension = true,
    this.requiresUserPrivacyConsent = false,
    this.customTags,
  });
}
