import 'package:engez/features/offer/models/offer_model.dart';

abstract class OfferState {}

class OfferInitial extends OfferState {}

class OfferLoading extends OfferState {}

class OfferLoaded extends OfferState {
  final List<OfferModel> offers;
  OfferLoaded(this.offers);
}

class OfferError extends OfferState {
  final String message;
  OfferError(this.message);
}
