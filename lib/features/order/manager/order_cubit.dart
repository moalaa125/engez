import 'dart:async';
import 'package:engez/features/order/manager/order_state.dart';
import 'package:engez/features/order/models/order_model.dart';
import 'package:engez/features/order/repositories/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;
  StreamSubscription? _ordersSubscription;

  OrderCubit(this._repository) : super(OrderInitial());

  void fetchCustomerOrders(String customerId) {
    emit(OrderLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository.getCustomerOrders(customerId).listen(
      (orders) {
        emit(OrderLoaded(orders));
      },
      onError: (error) {
        emit(OrderError(error.toString()));
      },
    );
  }

  void fetchPlaceOrders(String placeId) {
    emit(OrderLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository.getPlaceOrders(placeId).listen(
      (orders) {
        emit(OrderLoaded(orders));
      },
      onError: (error) {
        emit(OrderError(error.toString()));
      },
    );
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      emit(OrderCreateLoading());
      await _repository.createOrder(order);
      emit(OrderCreateSuccess());
    } catch (e) {
      emit(OrderCreateError(e.toString()));
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _repository.updateOrderStatus(orderId, newStatus);
    } catch (e) {
      // Handle error quietly
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
