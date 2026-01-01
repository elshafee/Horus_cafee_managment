import 'package:flutter/material.dart';
import 'package:horus_cafee/core/constants/api_constants.dart';
import 'package:horus_cafee/core/network/dio_client.dart';
import 'package:horus_cafee/features/order/models/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  Future<String> get baseUrl => ApiConstants.getBaseUrl();

  Future<void> fetchOrders(String? staffId) async {
    _isLoading = true;
    _orders = []; // Clear current list so the UI shows fresh data
    notifyListeners();
    final DioClient _dioClient = await DioClient.create();

    try {
      final url = staffId != null
          ? '${ApiConstants.getUserOrders}/$staffId'
          : ApiConstants.getUserOrders;

      final response = await _dioClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // This will now use the nested 'order' and 'items' logic
        _orders = data.map((json) => OrderModel.fromJson(json)).toList();

        // Debug to verify date parsing in terminal
        if (_orders.isNotEmpty) {
          print("First Order Date: ${_orders.first.createdAt}");
          print("First Order Status: ${_orders.first.status}");
        }
      }
    } catch (e) {
      print("Fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrderFromChat(Map<String, dynamic> data) async {
    final DioClient _dioClient = await DioClient.create();

    try {
      final response = await _dioClient.post(
        ApiConstants.createOrder,
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchOrders(data['staff_id']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
