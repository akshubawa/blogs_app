import 'package:assignment_app/services/firestore_services.dart';
import 'package:flutter/foundation.dart';
import '../models/blog_post.dart';

class BlogProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<BlogPost> _blogPosts = [];
  bool _isLoading = true;
  String? _highlightedPostId;

  List<BlogPost> get blogPosts => _blogPosts;
  bool get isLoading => _isLoading;
  String? get highlightedPostId => _highlightedPostId;

  BlogProvider() {
    fetchBlogPosts();
  }

  void fetchBlogPosts() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getBlogPosts().listen((posts) {
      _blogPosts = posts;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print('Error fetching blog posts: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  void setHighlightedPostId(String? id) {
    _highlightedPostId = id;
    notifyListeners();
  }

  Future<BlogPost?> getBlogPostById(String id) async {
    return await _firestoreService.getBlogPostById(id);
  }

  int getIndexById(String id) {
    return _blogPosts.indexWhere((post) => post.id == id);
  }
}
