class OrderModel {
  final int id;
  final String staffName;
  final String status;
  final String notes;
  final String deliveryRoom;
  final DateTime createdAt;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.staffName,
    required this.status,
    required this.notes,
    required this.deliveryRoom,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Access the nested 'order' object
    final orderData = json['order'];
    // Access the 'items' list
    final List<dynamic> itemsData = json['items'] ?? [];

    return OrderModel(
      id: orderData['id'],
      staffName: orderData['staff_name'],
      status: orderData['status'],
      notes: orderData['notes'],
      deliveryRoom: orderData['delivery_room'],
      // PARSING THE DATE: Ensure it handles the ISO format from Flask
      createdAt: DateTime.parse(orderData['created_at']),
      items: itemsData.map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}

class OrderItem {
  final String productName;
  final int quantity;

  OrderItem({required this.productName, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'],
      quantity: json['quantity'],
    );
  }
}
