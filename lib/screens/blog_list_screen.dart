import 'package:assignment_app/widgets/blog_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blog_provider.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _isAddingPost = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final blogProvider = Provider.of<BlogProvider>(context);
    final highlightedId = blogProvider.highlightedPostId;

    if (highlightedId != null && !blogProvider.isLoading) {
      final index = blogProvider.getIndexById(highlightedId);
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              index * 300.0, // Approximate height of each item
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  Future<void> addBlogPost({
    required String title,
    required String summary,
    required String content,
    required String imageURL,
  }) async {
    if (_isAddingPost) return; // Prevent multiple submission

    setState(() {
      _isAddingPost = true;
    });

    try {
      // Generate a new document reference
      final docRef = FirebaseFirestore.instance.collection('blogPosts').doc();

      // Create the blog post data
      final blogData = {
        'title': title,
        'summary': summary,
        'content': content,
        'imageURL': imageURL,
        'deeplink': 'https://google.com/blog/${docRef.id}',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      await docRef.set(blogData);

      // Show success message
      _showSnackBar('Blog post added successfully!', Colors.green);

      // Refresh the blog list
      if (mounted) {
        Provider.of<BlogProvider>(context, listen: false).fetchBlogPosts();
      }
    } catch (e) {
      // Show error message
      _showSnackBar('Error adding blog post: ${e.toString()}', Colors.red);
      print('Error adding blog post: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAddingPost = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAddBlogDialog() {
    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    final contentController = TextEditingController();
    final imageURLController = TextEditingController();

    // Pre-fill with sample data for testing
    imageURLController.text = "";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Blog Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageURLController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (imageURLController.text.isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageURLController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stackTrace) => const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                      loadingBuilder: (ctx, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  summaryController.text.isEmpty ||
                  contentController.text.isEmpty ||
                  imageURLController.text.isEmpty) {
                _showSnackBar('Please fill all fields', Colors.orange);
                return;
              }

              Navigator.of(ctx).pop();
              addBlogPost(
                title: titleController.text,
                summary: summaryController.text,
                content: contentController.text,
                imageURL: imageURLController.text,
              );
            },
            child: const Text('Add Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Trending Blogs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<BlogProvider>(context, listen: false)
                  .fetchBlogPosts();
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: _showAddBlogDialog,
          // ),
        ],
      ),
      body: Consumer<BlogProvider>(
        builder: (context, blogProvider, child) {
          if (blogProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (blogProvider.blogPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No blog posts available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddBlogDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Blog Post'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: blogProvider.blogPosts.length,
            itemBuilder: (context, index) {
              final blogPost = blogProvider.blogPosts[index];
              final isHighlighted =
                  blogPost.id == blogProvider.highlightedPostId;

              return BlogItem(
                blogPost: blogPost,
                isHighlighted: isHighlighted,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBlogDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
