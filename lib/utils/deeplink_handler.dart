import 'package:assignment_app/screens/blog_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blog_provider.dart';

class DeepLinkHandler {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void handleLink(Uri link) {
    final segments = link.pathSegments;
    if (segments.isNotEmpty && segments[0] == 'blog') {
      if (segments.length > 1) {
        final blogId = segments[1];
        _navigateToBlogPost(blogId);
      }
    }
  }

  Future<void> _navigateToBlogPost(String blogId) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final blogProvider = Provider.of<BlogProvider>(context, listen: false);
      final blogPost = await blogProvider.getBlogPostById(blogId);
      
      if (blogPost != null) {
        blogProvider.setHighlightedPostId(blogId);
        
        // Delay to allow animation to complete
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Navigate to blog list and then to detail
        if (context.mounted) {
          if (blogProvider.getIndexById(blogId) != -1) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    BlogDetailScreen(blogPost: blogPost),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: child);
                },
              ),
            );
          }
        }
      }
    }
  }
}