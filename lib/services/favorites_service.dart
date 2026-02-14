import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Manages user favorites in Firestore
class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get _favoritesCollection {
    return _firestore.collection('users').doc(_userId).collection('favorites');
  }

  // Stream all favorite names as a Set
  static Stream<Set<String>> favoritesStream() {
    if (_userId == null) return Stream.value({});
    return _favoritesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  static Future<void> addFavorite(String hairstyleName) async {
    if (_userId == null) return;
    await _favoritesCollection.doc(hairstyleName).set({
      'name': hairstyleName,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeFavorite(String hairstyleName) async {
    if (_userId == null) return;
    await _favoritesCollection.doc(hairstyleName).delete();
  }

  static Future<void> toggleFavorite(
    String hairstyleName,
    bool isFavorite,
  ) async {
    if (isFavorite) {
      await removeFavorite(hairstyleName);
    } else {
      await addFavorite(hairstyleName);
    }
  }
}
