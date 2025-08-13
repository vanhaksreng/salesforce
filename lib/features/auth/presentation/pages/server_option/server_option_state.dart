import 'package:salesforce/realm/scheme/schemas.dart';

class ServerOptionState {
  final bool isLoading;
  final List<AppServer> servers;
  final AppServer? server;
  final String selectedServerId;

  const ServerOptionState({this.isLoading = false, this.selectedServerId = "", this.servers = const [], this.server});

  ServerOptionState copyWith({bool? isLoading, String? selectedServerId, List<AppServer>? servers, AppServer? server}) {
    return ServerOptionState(
      isLoading: isLoading ?? this.isLoading,
      servers: servers ?? this.servers,
      server: server ?? this.server,
      selectedServerId: selectedServerId ?? this.selectedServerId,
    );
  }
}
