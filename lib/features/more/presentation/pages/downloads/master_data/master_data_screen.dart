import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/master_data/master_data_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/master_data/master_data_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({Key? key, required this.onChanged, this.isSelectAll = false, this.refresh = false})
    : super(key: key);

  final void Function(AppSyncLog table, bool isSelected)? onChanged;
  final bool isSelectAll;
  final bool refresh;

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
  final screenCubit = MasterDataCubit();
  final ValueNotifier<Set<int>> selectedIndices = ValueNotifier({});

  @override
  void initState() {
    screenCubit.fetchMasterDataTables();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MasterDataScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelectAll != oldWidget.isSelectAll) {
      if (widget.isSelectAll) {
        selectedIndices.value = Set.from(List.generate(screenCubit.state.records?.length ?? 0, (index) => index));
      } else {
        selectedIndices.value = {};
      }
    }

    if (widget.refresh != oldWidget.refresh) {
      selectedIndices.value = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: BlocBuilder<MasterDataCubit, MasterDataState>(
        bloc: screenCubit,
        builder: (BuildContext context, MasterDataState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          final records = state.records ?? [];

          return buildBody(records);
        },
      ),
    );
  }

  Widget buildBody(List<AppSyncLog> records) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return _buildRow(records[index], index);
      },
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: appSpace),
      separatorBuilder: (context, index) => Helpers.buildDivider(),
      itemCount: records.length,
    );
  }

  Widget _buildRow(AppSyncLog record, int index) {
    return ValueListenableBuilder(
      valueListenable: selectedIndices,
      builder: (context, selected, child) {
        return CheckboxListTile(
          key: ValueKey(record.tableName),
          checkboxScaleFactor: scaleFontSize(1.2),
          selectedTileColor: primary,
          activeColor: primary,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.scale),
          side: const BorderSide(color: grey),
          checkColor: white,
          checkboxShape: const CircleBorder(side: BorderSide(color: primary)),
          title: TextWidget(
            text: record.displayName ?? "",
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: "${greeting("number_of_records")}: ${record.total}",
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              TextWidget(
                text: "${greeting("last_download")}: ${record.lastSynchedDatetime}",
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ],
          ),
          value: selected.contains(index),
          onChanged: (value) {
            if (value == null) return;

            final newSelected = Set<int>.from(selected);

            if (value) {
              newSelected.add(index);
            } else {
              newSelected.remove(index);
            }
            selectedIndices.value = newSelected;

            widget.onChanged?.call(record, value);
          },
        );
      },
    );
  }
}
