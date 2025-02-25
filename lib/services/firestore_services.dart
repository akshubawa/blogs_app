import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blog_post.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'blogPosts';

  Stream<List<BlogPost>> getBlogPosts() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BlogPost.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<BlogPost?> getBlogPostById(String id) async {
    try {
      final docSnapshot = await _firestore.collection(_collection).doc(id).get();
      if (docSnapshot.exists) {
        return BlogPost.fromMap(docSnapshot.id, docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching blog post: $e');
      return null;
    }
  }
}
