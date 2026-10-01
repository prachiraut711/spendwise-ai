import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';

/// Service managing all Cloud Firestore database interactions for users and expenses.
class StorageService {
  final FirebaseFirestore? _customFirestore;

  StorageService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  /// Checks if Firebase is initialized in the current environment
  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _firestoreInstance {
    if (_customFirestore != null) return _customFirestore;
    if (isFirebaseAvailable) {
      return FirebaseFirestore.instance;
    }
    return null;
  }

  CollectionReference<Map<String, dynamic>>? get _usersRef =>
      _firestoreInstance?.collection('users');

  CollectionReference<Map<String, dynamic>>? get _expensesRef =>
      _firestoreInstance?.collection('expenses');

  /// Creates or updates a user document in `users/{uid}`.
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final ref = _usersRef;
    if (ref == null) {
      debugPrint('[StorageService] Cannot createUserProfile: _usersRef is null.');
      return;
    }

    debugPrint('[StorageService] Creating user profile at users/$uid with email=$email');
    await ref.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    debugPrint('[StorageService] Successfully created user profile at users/$uid');
  }

  /// Fetches a user profile document from Firestore.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final ref = _usersRef;
    if (ref == null) return null;

    final doc = await ref.doc(uid).get();
    return doc.data();
  }

  /// Streams real-time expenses belonging exclusively to [userId], sorted newest first.
  Stream<List<ExpenseModel>> streamUserExpenses(String userId) {
    final ref = _expensesRef;
    if (ref == null) {
      debugPrint('[StorageService] streamUserExpenses: _expensesRef is null. Returning empty stream.');
      return Stream.value(<ExpenseModel>[]);
    }

    debugPrint('[StorageService] Streaming expenses for userId: $userId');
    return ref
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      debugPrint('[StorageService] Received snapshot with ${snapshot.docs.length} docs for userId: $userId');
      final list = snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
      // Sort client-side by date descending to ensure immediate compatibility without requiring composite indices
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// One-time fetch of expenses for [userId].
  Future<List<ExpenseModel>> fetchUserExpenses(String userId) async {
    final ref = _expensesRef;
    if (ref == null) return <ExpenseModel>[];

    final snapshot = await ref.where('userId', isEqualTo: userId).get();
    final list =
        snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Saves a new expense to Firestore under `expenses/{expenseId}`.
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final ref = _expensesRef;
    if (ref == null) {
      debugPrint('[StorageService] addExpense: _expensesRef is null.');
      return expense.copyWith(id: 'local_${DateTime.now().millisecondsSinceEpoch}');
    }

    debugPrint('[StorageService] Adding expense to Firestore: ${expense.note} (userId: ${expense.userId})');
    final docRef = ref.doc();
    final newExpense = expense.copyWith(id: docRef.id);
    await docRef.set(newExpense.toMap());
    debugPrint('[StorageService] Successfully added expense doc: ${docRef.id}');
    return newExpense;
  }

  /// Updates an existing expense document.
  Future<void> updateExpense(ExpenseModel expense) async {
    final ref = _expensesRef;
    if (ref == null) return;
    debugPrint('[StorageService] Updating expense doc: ${expense.id}');
    await ref.doc(expense.id).update(expense.toMap());
    debugPrint('[StorageService] Successfully updated expense doc: ${expense.id}');
  }

  /// Deletes an expense document from Firestore.
  Future<void> deleteExpense(String expenseId) async {
    final ref = _expensesRef;
    if (ref == null) return;
    debugPrint('[StorageService] Deleting expense doc: $expenseId');
    await ref.doc(expenseId).delete();
    debugPrint('[StorageService] Successfully deleted expense doc: $expenseId');
  }
}
