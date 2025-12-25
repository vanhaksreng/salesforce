import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/competitor_promotion/competitor_promotion_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_merchandising/item_merchandising_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_posm/item_pom_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_and_merchanding_competitor/posm_and_merchanding_competitor_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class PosmAndMerchandingCompetitorScreen extends StatefulWidget {
  const PosmAndMerchandingCompetitorScreen({super.key, required this.args});
  static const String routeName = "posm_screen";
  final PosmAndMerchandingCompetitorArg args;

  @override
  State<PosmAndMerchandingCompetitorScreen> createState() => _PosmAndMerchandingCompetitorScreenState();
}

class _PosmAndMerchandingCompetitorScreenState extends State<PosmAndMerchandingCompetitorScreen> {
  final _posm = PosmMerchandingType.psom;
  final _merChanding = PosmMerchandingType.merchanding;
  final _cubit = PosmAndMerchandingCompetitorCubit();

  PosmMerchandingType? type;

  @override
  void initState() {
    super.initState();
    type = widget.args.posmMerchandingType;
    _cubit.getCompletitors();
    _getSalesPersonScheduleMerchandise();
  }

  String typeMerchandize() {
    if (type == _posm) {
      return kPOSM;
    } else if (type == _merChanding) {
      return kMerchandize;
    }
    return kCompetitor;
  }

  String routeName() {
    if (type == _posm) {
      return ItemPosmScreen.routeName;
    } else if (type == _merChanding) {
      return ItemMerchandisingScreen.routeName;
    }
    return CompetitorPromotionScreen.routeName;
  }

  void _pushNavigtorScreen(BuildContext context, Competitor competitor) {
    Navigator.pushNamed(
      context,
      routeName(),
      arguments: ItemPosmAndMerchandiseArg(
        schedule: widget.args.schedule,
        competitor: competitor,
        posmMerchandType: widget.args.posmMerchandingType,
      ),
    ).then((value) {
      _getSalesPersonScheduleMerchandise();
    });
  }

  void _getSalesPersonScheduleMerchandise() {
    _cubit.getSPSM(param: {"visit_no": widget.args.schedule.id, "merchandise_option": typeMerchandize()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting(typeMerchandize())),
      body: BlocBuilder<PosmAndMerchandingCompetitorCubit, PosmAndMerchandingCompetitorState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          final completitors = state.completitor ?? [];
          if (completitors.isEmpty) {
            return const EmptyScreen();
          }

          return _buildBody(completitors);
        },
      ),
    );
  }

  Widget _buildBody(List<Competitor> completitors) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: completitors.length,
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      itemBuilder: (context, index) {
        final competitor = completitors[index];
        final matching = _cubit.state.spsms.where((entry) {
          return entry.competitorNo == competitor.no && entry.visitNo?.toString() == widget.args.schedule.id;
        }).toList();

        final checkStatus = matching.where((e) => e.status == "Open").toList(growable: true);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: scaleFontSize(4)),
          child: listTile(context, index, competitor, checkStatus.length),
        );
      },
    );
  }

  ListTitleWidget listTile(BuildContext context, int index, Competitor competitor, int countNum) {
    return ListTitleWidget(
      key: ValueKey(competitor.no),
      onTap: () => _pushNavigtorScreen(context, competitor),
      leading: ImageNetWorkWidget(
        key: ValueKey("image${competitor.no}"),
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        isSide: true,
        sideColor: grey20,
        sideWidth: 1,
        imageUrl: competitor.logo ?? "",
      ),
      label: competitor.name ?? "",
      subTitle: competitor.no,
      countNumber: countNum,
    );
  }

  Widget conditionWidget(String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return TextWidget(text: value, color: textColor50);
  }
}
