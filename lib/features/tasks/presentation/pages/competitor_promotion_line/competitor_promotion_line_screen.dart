import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/competitor_promotion_line/competitor_promotion_line_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/competitor_promotion_line/competitor_promotion_line_state.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CompetitorPromotionLineScreen extends StatefulWidget {
  const CompetitorPromotionLineScreen({super.key, required this.header});
  final CompetitorPromtionHeader header;
  static const String routeName = "CompetitorPromotionLine";

  @override
  CompetitorPromotionLineScreenState createState() => CompetitorPromotionLineScreenState();
}

class CompetitorPromotionLineScreenState extends State<CompetitorPromotionLineScreen> {
  final _cubit = CompetitorPromotionLineCubit();

  @override
  void initState() {
    _cubit.getCompetitorProLine();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: widget.header.no ?? "Unknow"),
      body: BlocBuilder<CompetitorPromotionLineCubit, CompetitorPromotionLineState>(
        bloc: _cubit,
        builder: (BuildContext context, CompetitorPromotionLineState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(CompetitorPromotionLineState state) {
    final linePros = state.promotionLines;
    return ListView.separated(
      itemCount: linePros.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: appSpace, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return SizedBox(height: 8.scale);
      },
      itemBuilder: (context, lineIndex) {
        final line = linePros[lineIndex];

        return BoxWidget(
          key: ValueKey(line.itemNo),
          isBoxShadow: false,
          borderColor: grey20,
          isBorder: true,
          padding: EdgeInsets.all(8.scale),
          child: Row(
            spacing: 8.scale,
            children: [
              Expanded(
                child: Column(
                  spacing: 8.scale,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextWidget(text: line.description ?? "", fontWeight: FontWeight.bold),
                    Row(
                      spacing: 16.scale,
                      children: [
                        SizedBox(
                          width: 100.scale,
                          child: BtnWidget(
                            // borderColor: grey20.withValues(alpha: 0.2),
                            bgColor: primary20,
                            borderWidth: 0.5,
                            radius: 8,
                            variant: BtnVariant.outline,
                            size: BtnSize.xs,
                            textColor: primary,
                            onPressed: () {},
                            title: Helpers.formatNumber(line.quantity, option: FormatType.quantity),
                            fntSize: 14,
                          ),
                        ),
                        TextWidget(text: line.unitOfMeasureCode ?? ""),
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
