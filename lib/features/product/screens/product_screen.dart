import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:listin/features/home/models/listin.dart';
import 'package:listin/features/product/helpers/product_order_enum.dart';
import 'package:listin/features/product/models/product.dart';
import 'package:listin/features/product/services/product_service.dart';
import 'package:listin/features/product/widgets/product_list_tile.dart';
import 'package:uuid/uuid.dart';

class ProductScreen extends StatefulWidget {
  final Listin listin;
  const ProductScreen({super.key, required this.listin});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> plannedProducts = [];
  List<Product> purchasedProducts = [];

  ProductService productService = ProductService();

  ProductOrder order = ProductOrder.name;
  bool isDescending = false;

  late StreamSubscription listener;

  @override
  void initState() {
    setupListeners();
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(widget.listin.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: ProductOrder.name,
                  child: Text("Order by name"),
                ),
                const PopupMenuItem(
                  value: ProductOrder.amount,
                  child: Text("Order by amount"),
                ),
                const PopupMenuItem(
                  value: ProductOrder.price,
                  child: Text("Order by price"),
                ),
              ];
            },
            onSelected: (value) {
              setState(() {
                if (order == value) {
                  isDescending = !isDescending;
                } else {
                  order = value;
                  isDescending = false;
                }
              });
              refresh();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return refresh();
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "\$${calculatePurchasedPrice().toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 42),
                  ),
                  const Text(
                    "total expected for this purchase",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Planned Products",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              children: List.generate(plannedProducts.length, (index) {
                Product product = plannedProducts[index];
                return ProductListTile(
                  listinId: widget.listin.id,
                  product: product,
                  isPurchased: false,
                  showModal: showFormModal,
                  iconClick: productService.togglePurchased,
                  trailClick: removeProduct,
                );
              }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Purchased Products",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              children: List.generate(purchasedProducts.length, (index) {
                Product product = purchasedProducts[index];
                return ProductListTile(
                  listinId: widget.listin.id,
                  product: product,
                  isPurchased: true,
                  showModal: showFormModal,
                  iconClick: productService.togglePurchased,
                  trailClick: removeProduct,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  showFormModal({Product? model}) {
    // Labels to be shown in the Modal
    String labelTitle = "Add Product";
    String labelConfirmationButton = "Save";
    String labelSkipButton = "Cancel";

    // Controllers for product fields
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isPurchased = false;

    // If editing
    if (model != null) {
      labelTitle = "Editing ${model.name}";
      nameController.text = model.name;

      if (model.price != null) {
        priceController.text = model.price.toString();
      }

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      isPurchased = model.isPurchased;
    }

    // Flutter function that shows the modal on the screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Set vertical borders to be rounded
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),

          // Form with Title, Field, and Buttons
          child: ListView(
            children: [
              Text(
                labelTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Product Name*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Amount"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Price"),
                  icon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Create a Product object with the info
                      Product product = Product(
                        id: const Uuid().v1(),
                        name: nameController.text,
                        isPurchased: isPurchased,
                      );

                      // Use id from model
                      if (model != null) {
                        product.id = model.id;
                      }

                      if (amountController.text != "") {
                        product.amount = double.parse(amountController.text);
                      }

                      if (priceController.text != "") {
                        product.price = double.parse(priceController.text);
                      }

                      // Save to Firestore
                      productService.addProduct(
                        listinId: widget.listin.id,
                        product: product,
                      );

                      // Close the Modal
                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Product> fetchedProducts = await productService.readProducts(
      isDescending: isDescending,
      listinId: widget.listin.id,
      order: order,
      snapshot: snapshot,
    );

    if (snapshot != null) {
      checkChange(snapshot);
    }

    filterProducts(fetchedProducts);
  }


  filterProducts(List<Product> productList) {
    List<Product> tempPlanned = [];
    List<Product> tempPurchased = [];

    for (var product in productList) {
      if (product.isPurchased) {
        tempPurchased.add(product);
      } else {
        tempPlanned.add(product);
      }
    }

    setState(() {
      plannedProducts = tempPlanned;
      purchasedProducts = tempPurchased;
    });
  }


  setupListeners() {
    listener = productService.connectStream(
      onChange: refresh,
      listinId: widget.listin.id,
      order: order,
      isDescending: isDescending,
    );
  }


  removeProduct(Product product) async {
    await productService.removeProduct(
      product: product,
      listinId: widget.listin.id,
    );
  }


  double calculatePurchasedPrice() {
    double total = 0;
    for (Product product in purchasedProducts) {
      if (product.amount != null && product.price != null) {
        total += (product.amount! * product.price!);
      }
    }
    return total;
  }

  checkChange(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.length == 1) {
      for (DocumentChange docChange in snapshot.docChanges) {
        String type = "";
        Color color = Colors.black;
        switch (docChange.type) {
          case DocumentChangeType.added:
            type = "New Product";
            color = Colors.green;
            break;
          case DocumentChangeType.modified:
            type = "Product updated";
            color = Colors.orange;
            break;
          case DocumentChangeType.removed:
            type = "Product removed";
            color = Colors.red;
            break;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: color,
            content: Text(
              "$type: ${Product.fromMap(docChange.doc.data() as Map<String, dynamic>).name}",
            ),
          ),
        );
      }
    }
  }
}
