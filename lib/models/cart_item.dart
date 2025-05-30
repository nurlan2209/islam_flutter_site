class CartItem {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final String selectedSize;
  final String selectedColor;
  
  // Өнім туралы толық ақпарат (қосымша)
  final String? productName;
  final double? productPrice;
  final String? productImageUrl;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    this.productName,
    this.productPrice,
    this.productImageUrl,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      selectedSize: map['selected_size'],
      selectedColor: map['selected_color'],
      productName: map['product_name'],
      productPrice: map['product_price'],
      productImageUrl: map['product_image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'selected_size': selectedSize,
      'selected_color': selectedColor,
    };

    // Деректер базасына сақтау кезінде қосымша өрістерді қоспаймыз
    return map;
  }

  // Жалпы баға есептеу
  double get totalPrice => (productPrice ?? 0) * quantity;

  CartItem copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    String? productName,
    double? productPrice,
    String? productImageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
    );
  }
}