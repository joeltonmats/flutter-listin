import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listin/features/product/helpers/product_order_enum.dart';
import 'package:listin/features/product/models/product.dart';

class ProductService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  addProduct({required String listinId, required Product product}) {
    firestore
        .collection(uid)
        .doc(listinId)
        .collection("products")
        .doc(product.id)
        .set(product.toMap());
  }


  Future<List<Product>> readProducts({
    required String listinId,
    required ProductOrder order,
    required bool isDescending,
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  }) async {
    List<Product> temp = [];

    snapshot ??= await firestore
        .collection(uid)
        .doc(listinId)
        .collection("products")
        .orderBy(order.name, descending: isDescending)
        .get();

    for (var doc in snapshot.docs) {
      Product product = Product.fromMap(doc.data());
      temp.add(product);
    }

    return temp;
  }


  togglePurchased({required Product product, required String listinId}) async {
    product.isPurchased = !product.isPurchased;

    await firestore
        .collection(uid)
        .doc(listinId)
        .collection("products")
        .doc(product.id)
        .update({"isPurchased": product.isPurchased});
  }


  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> connectStream({
    required Function onChange,
    required String listinId,
    required ProductOrder order,
    required bool isDescending,
  }) {
    return firestore
        .collection(uid)
        .doc(listinId)
        .collection("products")
        .orderBy(order.name, descending: isDescending)
        .snapshots()
        .listen((snapshot) {
          onChange(snapshot: snapshot);
        });
  }

  Future<void> removeProduct({
    required Product product,
    required String listinId,
  }) async {
    return await firestore
        .collection(uid)
        .doc(listinId)
        .collection("products")
        .doc(product.id)
        .delete();
  }
}
