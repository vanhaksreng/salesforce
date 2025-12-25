class AppVersion {
  final String? appVersion;
  final String? isUpDate;
  final String? forceUpdate;
  final String? title;
  final String? description;
  final String? appUrl;

  AppVersion({
    this.appVersion,
    this.isUpDate,
    this.forceUpdate,
    this.title,
    this.description,
    this.appUrl,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
      appVersion: json["appVersion"] as String?,
      isUpDate: json["isUpdate"] as String?,
      forceUpdate: json["forceUpdate"] as String?,
      title: json["title"] as String?,
      description: json["description"] as String?,
      appUrl: json["app_url"] as String?);
}
