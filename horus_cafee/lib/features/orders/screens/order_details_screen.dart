import 'package:flutter/material.dart';
import 'package:horus_cafee/features/order/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("Order #${order.id}"),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 20),
            _buildInfoSection("Delivery Room", order.deliveryRoom),
            _buildInfoSection("Notes", order.notes),
            _buildInfoSection(
              "Order Date",
              DateFormat('yyyy-MM-dd – kk:mm').format(order.createdAt),
            ),
            const Divider(color: Colors.white24, height: 40),
            const Text(
              "Items",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...order.items.map((item) => _buildItemTile(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(order.status)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(order.status),
            color: _getStatusColor(order.status),
          ),
          const SizedBox(width: 12),
          Text(
            order.status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(order.status),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(OrderItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        item.productName,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Text(
        "x${item.quantity}",
        style: const TextStyle(color: Color(0xFFBB86FC)),
      ),
    );
  }

  // FIXED: Manual status mapping instead of missing OrderStatus class
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return Icons.check_circle_outline;
      case 'PENDING':
        return Icons.timer_outlined;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
