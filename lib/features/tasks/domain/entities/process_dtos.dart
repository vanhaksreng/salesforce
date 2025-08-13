abstract class ProcessArgs {}

class ProcessDtos {
  final String icon;
  final String title;
  final String subTitle;
  final String? routeName;
  final ProcessArgs? args;
  final int countNumber;
  final String? permissionCode;
  final bool show;
  final String type;

  const ProcessDtos({
    required this.icon,
    required this.title,
    required this.subTitle,
    this.permissionCode,
    this.routeName,
    this.args,
    this.countNumber = 0,
    this.show = true,
    this.type = "",
  });
}
