import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedult/team_schedult_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedult/team_schedult_state.dart';

class TeamSchedultScreen extends StatefulWidget {
  const TeamSchedultScreen({Key? key}) : super(key: key);

  @override
  State<TeamSchedultScreen> createState() => _TeamSchedultScreenState();
}

class _TeamSchedultScreenState extends State<TeamSchedultScreen> {
  final screenCubit = TeamSchedultCubit();

  @override
  void initState() {
    screenCubit.loadInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TeamSchedultCubit, TeamSchedultState>(
        bloc: screenCubit,
        listener: (BuildContext context, TeamSchedultState state) {},
        builder: (BuildContext context, TeamSchedultState state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(TeamSchedultState state) {
    return ListView(
      children: [
        // TODO your code here
      ],
    );
  }
}
