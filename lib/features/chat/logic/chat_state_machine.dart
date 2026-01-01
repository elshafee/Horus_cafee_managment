enum ChatState {
  initial,
  selectingType,
  selectingProduct,
  selectingQty,
  selectingSugarLoop, // New: Loops for each drink
  anythingElse, // New: Bridge to add more or finish
  selectingOfficeBoy,
  selectingRoom,
  confirming,
  completed,
}

// Internal helper to store items in the 'Cart'
class OrderItem {
  String name;
  int qty;
  List<String> sugarLevels; // Stores sugar for each cup
  OrderItem({required this.name, required this.qty, required this.sugarLevels});
}

class ChatStateMachine {
  ChatState _currentState = ChatState.initial;

  // Order Data Storage
  final List<OrderItem> _cart = [];
  String? _selectedType;
  String? _selectedProduct;
  int _tempQty = 0;
  int _sugarCount = 0; // Tracks which cup we are asking about

  String? _selectedOfficeBoy;
  String? _room;

  final List<String> _officeBoys = [
    'Ragaa',
    'Safaa Elmorshedy',
    'Nariman Tarek',
    'Fatheia Saied',
  ];

  List<String> getCurrentOptions() {
    switch (_currentState) {
      case ChatState.initial:
      case ChatState.selectingType:
        return ['Drink ☕', 'Food 🍔'];
      case ChatState.selectingProduct:
        return _selectedType == 'Drink ☕'
            ? ['Tea', 'Tea with milk', 'Coffee', 'Coffee with milk', 'Lemon']
            : ['Biscuit'];
      case ChatState.selectingQty:
        return ['1', '2', '3', '4'];
      case ChatState.selectingSugarLoop:
        return ['سادة', 'ع الريحة', 'مظبوط', 'زيادة'];
      case ChatState.anythingElse:
        return ['Add More ➕', 'Finish Order 🛒', 'Cancel ❌'];
      case ChatState.selectingOfficeBoy:
        return _officeBoys;
      case ChatState.selectingRoom:
        return [
          'E322',
          'E326',
          'E310',
          'E314',
          'E325',
          'E304',
          'E428',
          'E412',
          'E216',
        ];
      case ChatState.confirming:
        return ['Confirm Order ✅', 'Cancel ❌'];
      case ChatState.completed:
        return ['Start New Order 🔄'];
      default:
        return [];
    }
  }

  String nextState(String input) {
    switch (_currentState) {
      case ChatState.initial:
      case ChatState.selectingType:
        _selectedType = input;
        _currentState = ChatState.selectingProduct;
        return "Which item would you like?";

      case ChatState.selectingProduct:
        _selectedProduct = input;
        _currentState = ChatState.selectingQty;
        return "How many $_selectedProduct would you like?";

      case ChatState.selectingQty:
        _tempQty = int.tryParse(input) ?? 1;

        // Check if we need sugar for these items
        if (_selectedType == 'Drink ☕' &&
            (_selectedProduct!.contains('Tea') ||
                _selectedProduct!.contains('Coffee'))) {
          _currentState = ChatState.selectingSugarLoop;
          _sugarCount = 1;
          _cart.add(
            OrderItem(name: _selectedProduct!, qty: _tempQty, sugarLevels: []),
          );
          return "For the 1st $_selectedProduct, how much sugar?";
        } else {
          // No sugar needed (Food or Lemon)
          _cart.add(
            OrderItem(name: _selectedProduct!, qty: _tempQty, sugarLevels: []),
          );
          _currentState = ChatState.anythingElse;
          return "Added $_tempQty $_selectedProduct. Anything else to add?";
        }

      case ChatState.selectingSugarLoop:
        _cart.last.sugarLevels.add(input);
        if (_sugarCount < _tempQty) {
          _sugarCount++;
          return "And for the ${_sugarCount == 2
              ? '2nd'
              : _sugarCount == 3
              ? '3rd'
              : '4th'} one?";
        } else {
          _currentState = ChatState.anythingElse;
          return "Got it. Anything else to add to the order?";
        }

      case ChatState.anythingElse:
        if (input == 'Add More ➕') {
          _currentState = ChatState.selectingType;
          return "What else would you like? Drink or Food?";
        } else if (input == 'Finish Order 🛒') {
          _currentState = ChatState.selectingOfficeBoy;
          return "Which office boy should deliver this?";
        } else {
          reset();
          return "Order cancelled. Starting over...";
        }

      case ChatState.selectingOfficeBoy:
        _selectedOfficeBoy = input;
        _currentState = ChatState.selectingRoom;
        return "Which room should it be delivered to?";

      case ChatState.selectingRoom:
        _room = input;
        _currentState = ChatState.confirming;
        return _generateSummary();

      case ChatState.confirming:
        if (input.contains('Confirm')) {
          _currentState = ChatState.completed;
          return "Order sent to the kitchen! 🚀";
        } else {
          reset();
          return "Order cancelled.";
        }

      default:
        reset();
        return "Starting new order. Drink or Food?";
    }
  }

  String _generateSummary() {
    String itemsList = "";
    for (var item in _cart) {
      itemsList += "• ${item.qty}x ${item.name}";
      if (item.sugarLevels.isNotEmpty) {
        itemsList += " (${item.sugarLevels.join(', ')})";
      }
      itemsList += "\n";
    }

    return "📝 **ORDER SUMMARY**\n"
        "$itemsList"
        "• Delivered by: $_selectedOfficeBoy\n"
        "• Room: $_room\n\n"
        "Confirm this order?";
  }

  Map<String, dynamic> toJson(String staffName, String staffId) {
    int boyId = _officeBoys.indexOf(_selectedOfficeBoy ?? "") + 1;
    String globalNotes = _cart
        .map((item) {
          if (item.sugarLevels.isEmpty) return "${item.name}: N/A";
          return "${item.name} Sugar: (${item.sugarLevels.join(' | ')})";
        })
        .join(", ");

    return {
      "staff_name": staffName,
      "staff_id": staffId,
      "delivery_room": _room ?? "Unknown",
      "office_boy_id": boyId > 0 ? boyId : 1,
      // FIX: Use the constructed globalNotes instead of the old _sugarLevel variable
      "notes": "$globalNotes. Delivered by $_selectedOfficeBoy",
      "items": _cart
          .map(
            (item) => {
              "name": item.name,
              "qty": item.qty,
              "price": 0.0,
              // FIX: Ensure specific notes are attached to each item
              "notes": item.sugarLevels.isNotEmpty
                  ? "Sugar: ${item.sugarLevels.join('|')}"
                  : "N/A",
            },
          )
          .toList(),
    };
  }

  void reset() {
    _currentState = ChatState.initial;
    _cart.clear();
    _sugarCount = 0;
    _selectedType = null;
    _selectedProduct = null;
    _selectedOfficeBoy = null;
    _room = null;
  }

  ChatState get currentState => _currentState;
}

// enum ChatState {
//   initial,
//   selectingType,
//   selectingProduct,
//   selectingSugar,
//   selectingQty,
//   selectingOfficeBoy,
//   selectingRoom,
//   confirming,
//   completed,
// }
//
// class ChatStateMachine {
//   ChatState _currentState = ChatState.initial;
//
//   String? _selectedType;
//   String? _selectedProduct;
//   String? _sugarLevel;
//   int? _qty;
//   String? _selectedOfficeBoy;
//   String? _room;
//
//   final List<String> _officeBoys = [
//     'Ragaa',
//     'Safaa Elmorshedy',
//     'Nariman Tarek',
//     'Fatheia Saied',
//   ];
//
//   List<String> getCurrentOptions() {
//     switch (_currentState) {
//       case ChatState.initial:
//       case ChatState.selectingType:
//         return ['Drink ☕', 'Food 🍔'];
//       case ChatState.selectingProduct:
//         return _selectedType == 'Drink ☕'
//             ? ['Tea', 'Tea with milk', 'Coffee', 'Coffee with milk', 'Lemon']
//             : ['Biscuit'];
//       case ChatState.selectingSugar:
//         return ['سادة', 'ع الريحة', 'مظبوط', 'زيادة'];
//       case ChatState.selectingQty:
//         return ['1', '2', '3', '4'];
//       case ChatState.selectingOfficeBoy:
//         return _officeBoys;
//       case ChatState.selectingRoom:
//         return [
//           'E322',
//           'E326',
//           'E310',
//           'E314',
//           'E325',
//           'E304',
//           'E428',
//           'E412',
//           'E216',
//         ];
//       case ChatState.confirming:
//         return ['Confirm Order ✅', 'Cancel ❌'];
//       case ChatState.completed:
//         return ['Start New Order 🔄'];
//       default:
//         return [];
//     }
//   }
//
//   String nextState(String input) {
//     switch (_currentState) {
//       case ChatState.initial:
//       case ChatState.selectingType:
//         _selectedType = input;
//         _currentState = ChatState.selectingProduct;
//         return "Which item would you like?";
//
//       case ChatState.selectingProduct:
//         _selectedProduct = input;
//         // Check if item needs sugar selection
//         if (_selectedType == 'Drink ☕' &&
//             (_selectedProduct == 'Tea' || _selectedProduct == 'Coffee')) {
//           _currentState = ChatState.selectingSugar;
//           return "How much sugar should I add?";
//         }
//         // Default sugar to N/A for food/juice/water
//         _sugarLevel = "N/A";
//         _currentState = ChatState.selectingQty;
//         return "Got it. How many would you like?";
//
//       case ChatState.selectingSugar:
//         _sugarLevel = input;
//         _currentState = ChatState.selectingQty;
//         return "Noted. How many?";
//
//       case ChatState.selectingQty:
//         _qty = int.tryParse(input) ?? 1;
//         _currentState = ChatState.selectingOfficeBoy;
//         return "Which office boy should deliver this?";
//
//       case ChatState.selectingOfficeBoy:
//         _selectedOfficeBoy = input;
//         _currentState = ChatState.selectingRoom;
//         return "And which room should it be delivered to?";
//
//       case ChatState.selectingRoom:
//         _room = input;
//         _currentState = ChatState.confirming;
//         return _generateSummary();
//
//       case ChatState.confirming:
//         if (input.contains('Confirm')) {
//           _currentState = ChatState.completed;
//
//           return "Order sent to the kitchen! 🚀";
//         } else {
//           reset();
//           return "Order cancelled. What else can I get you?";
//         }
//
//       case ChatState.completed:
//         reset();
//         return "Starting a new order. Drink or Food?";
//
//       default:
//         return "I'm processing your request...";
//     }
//   }
//
//   String _generateSummary() {
//     // Logic: Only show sugar if it's relevant (not N/A and not null)
//     String sugarLine = (_sugarLevel != null && _sugarLevel != "N/A")
//         ? "• Sugar: $_sugarLevel\n"
//         : "";
//
//     return "📝 **ORDER SUMMARY**\n"
//         "• Item: $_selectedProduct\n"
//         "$sugarLine"
//         "• Quantity: $_qty\n"
//         "• Delivered by: $_selectedOfficeBoy\n"
//         "• Room: $_room\n\n"
//         "Confirm this order?";
//   }
//
//   Map<String, dynamic> toJson(String staffName, String staffId) {
//     // Safety check: ensure office boy index is valid
//     int boyId = _officeBoys.indexOf(_selectedOfficeBoy ?? "") + 1;
//
//     return {
//       "staff_name": staffName,
//       "staff_id": staffId,
//       "delivery_room": _room ?? "Unknown",
//       "office_boy_id": boyId > 0 ? boyId : 1, // Fallback to first boy
//       "notes":
//           "Sugar: ${_sugarLevel ?? 'N/A'}. Delivery by ${_selectedOfficeBoy ?? 'Staff'}",
//       "items": [
//         {"name": _selectedProduct ?? "Unknown", "qty": _qty ?? 1, "price": 0.0},
//       ],
//     };
//   }
//
//   void reset() {
//     _currentState = ChatState.initial;
//     _selectedType = null;
//     _selectedProduct = null;
//     _sugarLevel = null;
//     _qty = null;
//     _selectedOfficeBoy = null;
//     _room = null;
//   }
//
//   ChatState get currentState => _currentState;
// }
