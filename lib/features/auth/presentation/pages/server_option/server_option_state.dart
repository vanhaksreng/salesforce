import 'package:salesforce/realm/scheme/schemas.dart';

class ServerOptionState {
  final bool isLoading;
  final List<AppServer> servers;
  final AppServer? server;
  final String selectedServerId;
  final CompanyInformation? companyInfo;

  const ServerOptionState({
    this.isLoading = false,
    this.selectedServerId = "",
    this.servers = const [],
    this.server,
    this.companyInfo,
  });

  ServerOptionState copyWith({
    bool? isLoading,
    String? selectedServerId,
    List<AppServer>? servers,
    AppServer? server,
    CompanyInformation? companyInfo,
  }) {
    return ServerOptionState(
      isLoading: isLoading ?? this.isLoading,
      servers: servers ?? this.servers,
      server: server ?? this.server,
      selectedServerId: selectedServerId ?? this.selectedServerId,
      companyInfo: companyInfo ?? this.companyInfo,
    );
  }
}
