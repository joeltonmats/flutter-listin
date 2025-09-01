import 'package:flutter/material.dart';
import 'package:listin/features/product/models/product.dart';

class ProductListTile extends StatelessWidget {
  final String listinId;
  final Product product;
  final bool isPurchased;
  final Function showModal;
  final Function iconClick;
  final Function trailClick;

  const ProductListTile({
    super.key,
    required this.listinId,
    required this.product,
    required this.isPurchased,
    required this.showModal,
    required this.iconClick,
    required this.trailClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showModal(model: product);
      },
      leading: IconButton(
        onPressed: () {
          iconClick(product: product, listinId: listinId);
        },
        icon: Icon((isPurchased) ? Icons.shopping_basket : Icons.check),
      ),
      trailing: IconButton(
        onPressed: (() {
          trailClick(product);
        }),
        icon: const Icon(Icons.delete, color: Colors.red),
      ),
      title: Text(
        (product.amount == null)
            ? product.name
            : "${product.name} (x${product.amount!.toInt()})",
      ),
      subtitle: Text(
        (product.price == null) ? "Click to add price" : "\$ ${product.price!}",
      ),
    );
  }
}
