import 'package:engez/features/admin/models/admin_request_model.dart';

abstract class AdminRequestsState {}

class AdminRequestsInitial extends AdminRequestsState {}

class AdminRequestsLoading extends AdminRequestsState {}

class AdminRequestsLoaded extends AdminRequestsState {
  final List<AdminRequestModel> requests;
  AdminRequestsLoaded(this.requests);
}

class AdminRequestsError extends AdminRequestsState {
  final String message;
  AdminRequestsError(this.message);
}
