class PostingDateModel {
  final String fromDate;
  final String endDate;

  PostingDateModel({
    required this.fromDate,
    required this.endDate,
  });

  factory PostingDateModel.fromJson(Map<String, dynamic> json) =>
      PostingDateModel(
        fromDate: json["from_date"],
        endDate: json["to_date"],
      );

  Map<String, dynamic> toJson() => {
        "from_date": fromDate,
        "to_date": endDate,
      };
}
