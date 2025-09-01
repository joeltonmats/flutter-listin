import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listin/features/home/models/listin.dart';

class ListinService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addListin({required Listin listin}) async {
    return firestore.collection(uid).doc(listin.id).set(listin.toMap());
  }

  Future<List<Listin>> readListins() async {
    List<Listin> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection(uid)
        .get();

    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }

    return temp;
  }

  Future<void> removeListin({required String listinId}) async {
    return firestore.collection(uid).doc(listinId).delete();
  }
}
