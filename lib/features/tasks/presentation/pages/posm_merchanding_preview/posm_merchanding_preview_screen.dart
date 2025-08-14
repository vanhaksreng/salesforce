import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_merchanding_preview/posm_merchanding_preview_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_merchanding_preview/posm_merchanding_preview_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class PosmMerchandingPreviewScreen extends StatefulWidget {
  const PosmMerchandingPreviewScreen({super.key, required this.arg});
  static const String routeName = "posmMerchandingPreviewScreen";
  final ItemPosmAndMerchandiseArg arg;

  @override
  PosmMerchandingPreviewScreenState createState() => PosmMerchandingPreviewScreenState();
}

class PosmMerchandingPreviewScreenState extends State<PosmMerchandingPreviewScreen> with MessageMixin {
  final _cubit = PosmMerchandingPreviewCubit();
  final _posm = PosmMerchandingType.psom;
  final _merChanding = PosmMerchandingType.merchanding;
  String title = "";
  PosmMerchandingType? type;

  String typeMerchandize() {
    if (type == _posm) {
      return kPOSM;
    } else if (type == _merChanding) {
      return kMerchandize;
    }
    return kCompetitor;
  }

  @override
  void initState() {
    type = widget.arg.posmMerchandType;
    title = typeMerchandize();
    _cubit.getMerchandiseSchdedule(widget.arg.schedule, typeMerchandize());
    super.initState();
  }

  Future<void> _onSubmitPosm() async {
    final lists = _cubit.state.spsms.where((e) => e.status == kStatusOpen);
    if (lists.isEmpty) {
      showWarningMessage("Nothing to submit");
      return;
    }

    Helpers.showDialogAction(
      context,
      labelAction: greeting("submitt"),
      subtitle: greeting("do_you_want_to_submit_now?"),
      confirm: () {
        _cubit.submitMerchandiseSchdedule();
        Navigator.of(context)
          ..pop()
          ..pop();
      },
    );
  }

  void _ondeleteItem(SalesPersonScheduleMerchandise? record) {
    if (record == null) {
      return;
    }
    Helpers.showDialogAction(
      context,
      labelAction: greeting("Comfirm"),
      subtitle: greeting("Are you sure to delete?"),
      confirm: () {
        Navigator.of(context).pop();
        _cubit.deleteItem(record, widget.arg.schedule);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting(title)),
      body: BlocBuilder<PosmMerchandingPreviewCubit, PosmMerchandingPreviewState>(
        bloc: _cubit,
        builder: (BuildContext context, PosmMerchandingPreviewState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(PosmMerchandingPreviewState state) {
    final spsm = state.spsms;
    if (spsm.isEmpty) {
      return const EmptyScreen();
    }
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace8)),
      child: Column(
        spacing: scaleFontSize(appSpace8),
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: spsm.length,
              itemBuilder: (context, index) {
                final item = spsm[index];
                return BoxWidget(
                  margin: EdgeInsets.only(bottom: scaleFontSize(8)),
                  padding: EdgeInsets.all(scaleFontSize(16)),
                  child: Column(
                    spacing: scaleFontSize(appSpace),
                    children: [headerPart(item), footerPart(item.quantity ?? 0.0)],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: BtnWidget(gradient: linearGradient, onPressed: () => _onSubmitPosm(), title: greeting("submit")),
          ),
        ],
      ),
    );
  }

  Widget headerPart(SalesPersonScheduleMerchandise item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(text: item.merchandiseCode ?? "", fontWeight: FontWeight.bold, fontSize: 16, color: mainColor),
            BtnIconCircleWidget(
              bgColor: error.withValues(alpha: 0.2),
              onPressed: () => _ondeleteItem(item),
              icons: Icon(Icons.delete_forever_rounded, size: 24.scale, color: error),
            ),
          ],
        ),
        TextWidget(text: item.description ?? "", fontWeight: FontWeight.bold, fontSize: 18),
        if ((item.description2 ?? "").isNotEmpty)
          TextWidget(fontWeight: FontWeight.bold, fontSize: 16, text: item.description2 ?? ""),
      ],
    );
  }

  Widget footerPart(double quantity) {
    return BoxWidget(
      isBoxShadow: false,
      color: grey.withValues(alpha: 0.1),
      padding: EdgeInsets.all(scaleFontSize(8)),
      child: Row(
        spacing: scaleFontSize(appSpace),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: TextWidget(text: greeting("quantity").toUpperCase())),
          TextWidget(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: mainColor,
            text: Helpers.formatNumber(quantity, option: FormatType.quantity),
          ),
        ],
      ),
    );
  }
}
