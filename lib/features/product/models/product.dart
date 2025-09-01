class Product {
  String id;
  String name;
  double? price;
  double? amount;
  bool isPurchased;

  Product({
    required this.id,
    required this.name,
    required this.isPurchased,
    this.price,
    this.amount,
  });

  Product.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      name = map["name"],
      isPurchased = map["isPurchased"],
      price = map["price"],
      amount = map["amount"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "isPurchased": isPurchased,
      "price": price,
      "amount": amount,
    };
  }
}
