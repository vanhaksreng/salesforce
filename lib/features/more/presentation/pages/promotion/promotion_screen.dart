import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/promotion/promotion_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/promotion/promotion_state.dart';
import 'package:salesforce/features/more/presentation/pages/promotion_detail/promotion_detail_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  static const routeName = "PromotionScreenHisory";

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final _cubit = PromotionCubit();
  @override
  void initState() {
    _cubit.getItemPromotionHeaders();
    super.initState();
  }

  void _navigateToPromotionDetail(ItemPromotionHeader header) {
    Navigator.pushNamed(context, PromotionDetailScreen.routeName, arguments: header);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("promotion")),
      body: BlocBuilder<PromotionCubit, PromotionState>(
        bloc: _cubit,
        builder: (BuildContext context, PromotionState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(PromotionState state) {
    final headers = state.headers;
    if (headers.isEmpty) {
      return const EmptyScreen();
    }

    const boxPadding = EdgeInsets.symmetric(horizontal: 15, vertical: 15);
    return ListView.separated(
      padding: boxPadding,
      separatorBuilder: (_, index) => const SizedBox(height: 15),
      itemCount: headers.length,
      itemBuilder: (_, index) {
        final header = headers[index];

        return BoxWidget(
          key: ValueKey(header.no),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: boxPadding,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  gradient: linearGradient50,
                ),
                child: Column(
                  spacing: 8.scale,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((header.promotionType ?? "").isNotEmpty)
                      ChipWidget(
                        label: header.promotionType ?? "",
                        bgColor: white,
                        colorText: const Color(0xFF667eea),
                        vertical: 6.scale,
                      ),
                    TextWidget(text: header.description ?? '', color: white, fontSize: 16),
                    TextWidget(text: header.remark ?? '', color: white, fontSize: 13),
                  ],
                ),
              ),
              Padding(
                padding: boxPadding,
                child: Column(
                  spacing: 15.scale,
                  children: [
                    Container(
                      padding: boxPadding,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: grey20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6.scale,
                            children: [
                              TextWidget(text: greeting("From Date")),
                              TextWidget(
                                text: DateTimeExt.parse(header.fromDate).toDateNameString(),
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6.scale,
                            children: [
                              TextWidget(text: greeting("To Date")),
                              TextWidget(
                                text: DateTimeExt.parse(header.toDate).toDateNameString(),
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChipWidget(label: "Promotion Mix", bgColor: primary.withValues(alpha: 0.1), colorText: primary),
                        SizedBox(
                          width: 120.scale,
                          child: BtnWidget(
                            gradient: linearGradient,
                            size: BtnSize.small,
                            title: greeting("view_detail"),
                            onPressed: () => _navigateToPromotionDetail(header),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
