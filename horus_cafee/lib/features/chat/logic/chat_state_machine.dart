enum ChatState {
  initial,
  selectingType,
  selectingProduct,
  selectingSugar,
  selectingQty,
  selectingOfficeBoy,
  selectingRoom,
  confirming,
  completed,
}

class ChatStateMachine {
  ChatState _currentState = ChatState.initial;

  String? _selectedType;
  String? _selectedProduct;
  String? _sugarLevel;
  int? _qty;
  String? _selectedOfficeBoy;
  String? _room;

  final List<String> _officeBoys = ['Ahmed', 'John', 'Suresh'];

  List<String> getCurrentOptions() {
    switch (_currentState) {
      case ChatState.initial:
      case ChatState.selectingType:
        return ['Drink ☕', 'Food 🍔'];
      case ChatState.selectingProduct:
        return _selectedType == 'Drink ☕'
            ? ['Tea', 'Coffee', 'Juice']
            : ['Sandwich', 'Biscuit'];
      case ChatState.selectingSugar:
        return ['سادة', 'ع الريحة', 'مظبوط', 'زيادة'];
      case ChatState.selectingQty:
        return ['1', '2', '3', '4'];
      case ChatState.selectingOfficeBoy:
        return _officeBoys;
      case ChatState.selectingRoom:
        return ['Office 101', 'Meeting Room A', 'Reception'];
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
        // Check if item needs sugar selection
        if (_selectedType == 'Drink ☕' &&
            (_selectedProduct == 'Tea' || _selectedProduct == 'Coffee')) {
          _currentState = ChatState.selectingSugar;
          return "How much sugar should I add?";
        }
        // Default sugar to N/A for food/juice/water
        _sugarLevel = "N/A";
        _currentState = ChatState.selectingQty;
        return "Got it. How many would you like?";

      case ChatState.selectingSugar:
        _sugarLevel = input;
        _currentState = ChatState.selectingQty;
        return "Noted. How many?";

      case ChatState.selectingQty:
        _qty = int.tryParse(input) ?? 1;
        _currentState = ChatState.selectingOfficeBoy;
        return "Which office boy should deliver this?";

      case ChatState.selectingOfficeBoy:
        _selectedOfficeBoy = input;
        _currentState = ChatState.selectingRoom;
        return "And which room should it be delivered to?";

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
          return "Order cancelled. What else can I get you?";
        }

      case ChatState.completed:
        reset();
        return "Starting a new order. Drink or Food?";

      default:
        return "I'm processing your request...";
    }
  }

  String _generateSummary() {
    // Logic: Only show sugar if it's relevant (not N/A and not null)
    String sugarLine = (_sugarLevel != null && _sugarLevel != "N/A")
        ? "• Sugar: $_sugarLevel\n"
        : "";

    return "📝 **ORDER SUMMARY**\n"
        "• Item: $_selectedProduct\n"
        "$sugarLine"
        "• Quantity: $_qty\n"
        "• Delivered by: $_selectedOfficeBoy\n"
        "• Room: $_room\n\n"
        "Confirm this order?";
  }

  Map<String, dynamic> toJson(String staffName, String staffId) {
    // Safety check: ensure office boy index is valid
    int boyId = _officeBoys.indexOf(_selectedOfficeBoy ?? "") + 1;

    return {
      "staff_name": staffName,
      "staff_id": staffId,
      "delivery_room": _room ?? "Unknown",
      "office_boy_id": boyId > 0 ? boyId : 1, // Fallback to first boy
      "notes":
          "Sugar: ${_sugarLevel ?? 'N/A'}. Delivery by ${_selectedOfficeBoy ?? 'Staff'}",
      "items": [
        {"name": _selectedProduct ?? "Unknown", "qty": _qty ?? 1, "price": 0.0},
      ],
    };
  }

  void reset() {
    _currentState = ChatState.initial;
    _selectedType = null;
    _selectedProduct = null;
    _sugarLevel = null;
    _qty = null;
    _selectedOfficeBoy = null;
    _room = null;
  }

  ChatState get currentState => _currentState;
}
