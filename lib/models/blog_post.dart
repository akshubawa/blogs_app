class BlogPost {
  final String id;
  final String imageURL;
  final String title;
  final String summary;
  final String content;
  final String deepLink;

  BlogPost({
    required this.id,
    required this.imageURL,
    required this.title,
    required this.summary,
    required this.content,
    required this.deepLink,
  });

  factory BlogPost.fromMap(String id, Map<String, dynamic> data) {
    return BlogPost(
      id: id,
      imageURL: data['imageURL'] ?? '',
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      deepLink: data['deeplink'] ?? '',
    );
  }
}