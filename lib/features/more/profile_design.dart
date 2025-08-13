import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class TransitionAppBar extends StatelessWidget {
  const TransitionAppBar({
    required this.avatar,
    required this.title,
    this.subtitle = "",
    this.onTap,
    this.extent = 120,
    Key? key,
  }) : super(key: key);

  final Widget avatar;
  final double extent;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TransitionAppBarDelegate(
        avatar: avatar,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        extent: extent > scaleFontSize(160) ? extent : scaleFontSize(160),
      ),
    );
  }
}

class _TransitionAppBarDelegate extends SliverPersistentHeaderDelegate {
  _TransitionAppBarDelegate({
    required this.avatar,
    required this.title,
    this.extent = 160,
    this.onTap,
    this.subtitle = "",
  }) : assert(extent >= scaleFontSize(160), '');

  final Widget avatar;
  final double extent;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  final _avatarAlignTween = AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topLeft);

  final _avatarMarginTween = EdgeInsetsTween(
    begin: EdgeInsets.only(left: 16.scale, bottom: 16.scale),
    end: EdgeInsets.only(left: 16.scale, top: 40.scale),
  );

  final _titleMarginTween = EdgeInsetsTween(
    begin: EdgeInsets.only(left: 120.scale, bottom: 0.scale, top: 80.scale, right: scaleFontSize(appSpace)),
    end: EdgeInsets.only(left: 90.scale, top: 55.scale, right: scaleFontSize(appSpace)),
  );

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => scaleFontSize(120);

  @override
  bool shouldRebuild(_TransitionAppBarDelegate oldDelegate) {
    return avatar != oldDelegate.avatar || title != oldDelegate.title;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final tempVal = maxExtent * scaleFontSize(0.30);
    final progress = shrinkOffset > tempVal ? 1.0 : shrinkOffset / tempVal;

    final avatarMargin = _avatarMarginTween.lerp(progress);
    final titleMargin = _titleMarginTween.lerp(progress);
    final avatarAlign = _avatarAlignTween.lerp(progress);
    final avatarSize = (1 - progress) * scaleFontSize(18) + scaleFontSize(60);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(decoration: const BoxDecoration(gradient: linearGradient)),
        _buildAvtar(avatarMargin, avatarAlign, avatarSize),
        buildInfo(titleMargin, progress),
      ],
    );
  }

  Padding _buildAvtar(EdgeInsets avatarMargin, Alignment avatarAlign, double avatarSize) {
    return Padding(
      padding: avatarMargin,
      child: Align(
        alignment: avatarAlign,
        child: Hero(
          tag: 'profile_avatar',
          child: ClipOval(
            child: SizedBox(width: avatarSize, height: avatarSize, child: avatar),
          ),
        ),
      ),
    );
  }

  Padding buildInfo(EdgeInsets titleMargin, double progress) {
    return Padding(
      padding: titleMargin,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              spacing: 6.scale,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: title,
                  color: progress > scaleFontSize(0.95) ? Colors.white : Colors.white,
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 22 - (6 * progress), // 22 -> 14
                ),
                TextWidget(
                  text: subtitle,
                  color: progress > 0.95 ? Colors.white : Colors.white,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 18 - (4 * progress), // 22 -> 14
                ),
              ],
            ),
            BoxWidget(
              onPress: onTap,
              rounding: 6,
              color: grey20.withValues(alpha: 0.2),
              isBoxShadow: false,
              padding: EdgeInsets.all(scaleFontSize(4)),
              child: Row(
                spacing: 4.scale,
                children: [
                  TextWidget(fontSize: 16, text: greeting("Edit"), color: white),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
