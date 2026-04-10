import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Generic CRUD operations
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }
  
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }
  
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }
  
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }
  
  Stream<QuerySnapshot> getCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }
  
  Stream<DocumentSnapshot> getDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }
  
  Future<QuerySnapshot> queryCollection(
    String collection, {
    String? field,
    dynamic isEqualTo,
    dynamic isGreaterThan,
    dynamic isLessThan,
  }) async {
    Query query = _firestore.collection(collection);
    
    if (field != null) {
      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
    }
    
    return await query.get();
  }

  Stream<QuerySnapshot> getSubcollection(String collection, String docId, String subcollection) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .collection(subcollection)
        .snapshots();
  }

  Future<void> addToSubcollection(
    String collection,
    String docId,
    String subcollection,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(collection)
        .doc(docId)
        .collection(subcollection)
        .add(data);
  }

  Future<QuerySnapshot> querySubcollection(
    String collection,
    String docId,
    String subcollection, {
    String? field,
    dynamic isEqualTo,
    String? orderBy,
    bool descending = false,
  }) async {
    Query query = _firestore
        .collection(collection)
        .doc(docId)
        .collection(subcollection);

    if (field != null && isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    return await query.get();
  }
}
