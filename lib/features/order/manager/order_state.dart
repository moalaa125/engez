import 'package:engez/features/order/models/order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;
  OrderLoaded(this.orders);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

class OrderCreateSuccess extends OrderState {}

class OrderCreateLoading extends OrderState {}

class OrderCreateError extends OrderState {
  final String message;
  OrderCreateError(this.message);
}
