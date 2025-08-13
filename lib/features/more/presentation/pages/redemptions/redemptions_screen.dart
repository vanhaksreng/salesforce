import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/redemptions/redemptions_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/redemptions/redemptions_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_prize_redemption/item_prize_redemption_card_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class RedemptionsScreen extends StatefulWidget {
  const RedemptionsScreen({Key? key}) : super(key: key);
  static const String routeName = "RedemptionScreen";

  @override
  RedemptionsScreenState createState() => RedemptionsScreenState();
}

class RedemptionsScreenState extends State<RedemptionsScreen> {
  final _cubit = RedemptionsCubit();

  @override
  void initState() {
    _initLoad();
    super.initState();
  }

  void _initLoad() async {
    await _cubit.getItemPrizeRedemptionHeader();
    _cubit.getItemPrizeRedemptionLine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("Redemptions")),
      body: BlocBuilder<RedemptionsCubit, RedemptionsState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(RedemptionsState state) {
    if (state.headers.isEmpty) {
      return const EmptyScreen();
    }
    return ListView.builder(
      itemCount: state.headers.length,
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      itemBuilder: (context, index) {
        final header = state.headers[index];

        final lines = state.lines.where((l) => l.promotionNo == header.no).toList();

        return BoxWidget(
          key: ValueKey(header.no),
          margin: EdgeInsets.symmetric(vertical: 8.scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(header),
              Hr(width: double.infinity, vertical: scaleFontSize(6)),
              ItemPrizeRedemptionCardScreen(lines: lines, entries: []),
            ],
          ),
        );
      },
    );
  }

  final boxPadding = const EdgeInsets.symmetric(horizontal: 15, vertical: 15);
  Widget _buildHeader(ItemPrizeRedemptionHeader header) {
    return Container(
      key: ValueKey(header.no),
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.scale), topRight: Radius.circular(10.scale)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: scaleFontSize(8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [TextWidget(text: header.no ?? "", fontSize: 16, fontWeight: FontWeight.bold)],
          ),
          TextWidget(text: header.description ?? ""),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 4.scale,
                children: [
                  Icon(Icons.calendar_month, color: grey, size: 16.scale),
                  TextWidget(text: "${DateTimeExt.parse(header.fromDate).toDateNameString()} -"),
                  TextWidget(text: DateTimeExt.parse(header.toDate).toDateNameString()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
