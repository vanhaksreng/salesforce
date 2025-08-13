import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/competitor_promotion/competitor_promotion_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/competitor_promotion_line/competitor_promotion_line_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CompetitorPromotionScreen extends StatefulWidget {
  const CompetitorPromotionScreen({super.key, required this.arg});
  static const String routeName = "competitor_promotion";
  final ItemPosmAndMerchandiseArg arg;

  @override
  State<CompetitorPromotionScreen> createState() => _CompetitorPromotionScreenState();
}

class _CompetitorPromotionScreenState extends State<CompetitorPromotionScreen> {
  final _cubit = CompetitorPromotionCubit();

  void _navigateToPromotionLine(CompetitorPromtionHeader header) {
    Navigator.pushNamed(context, CompetitorPromotionLineScreen.routeName, arguments: header);
  }

  @override
  void initState() {
    _cubit.getCompetitorHeader(param: {"competitor_no": widget.arg.competitor?.no});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("competitor_promotion"),
        heightBottom: heightBottomSearch,
        bottom: const SearchWidget(),
      ),
      body: BlocBuilder<CompetitorPromotionCubit, CompetitorPromotionState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }
          final completitors = state.completitorHeader ?? [];
          if (completitors.isEmpty) {
            return const EmptyScreen();
          }
          return _buildBody(completitors);
        },
      ),
    );
  }

  Widget _buildBody(List<CompetitorPromtionHeader> headers) {
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
                        ChipWidget(
                          label: header.promotionType ?? "",
                          bgColor: primary.withValues(alpha: 0.1),
                          colorText: primary,
                        ),
                        SizedBox(
                          width: 120.scale,
                          child: BtnWidget(
                            gradient: linearGradient,
                            size: BtnSize.small,
                            title: greeting("Add to cart"),
                            onPressed: () => _navigateToPromotionLine(header),
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
