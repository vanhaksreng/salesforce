class NotificationArg {
  final List<NotificationModel> notifications;
  final int countNotification;

  NotificationArg({
    required this.notifications,
    required this.countNotification,
  });
}

class NotificationModel {
  final String title;
  final String description;
  final String date;
  final String documentType;
  final String documentNo;
  final String imgUrl;

  NotificationModel({
    required this.title,
    required this.description,
    required this.date,
    required this.documentType,
    required this.documentNo,
    required this.imgUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        date: json["date"] ?? "",
        documentType: json["documentType"] ?? "",
        documentNo: json["documentNo"] ?? "",
        imgUrl: json["imgUrl"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "date": date,
        "documentType": documentType,
        "documentNo": documentNo,
        "imgUrl": imgUrl,
      };
}
