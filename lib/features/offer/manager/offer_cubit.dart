import 'dart:async';
import 'package:engez/features/offer/manager/offer_state.dart';
import 'package:engez/features/offer/repositories/offer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _repository;
  StreamSubscription? _subscription;

  OfferCubit(this._repository) : super(OfferInitial());

  void fetchOffers() {
    emit(OfferLoading());
    _subscription?.cancel();
    _subscription = _repository.getOffers().listen(
      (offers) {
        emit(OfferLoaded(offers));
      },
      onError: (error) {
        emit(OfferError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
