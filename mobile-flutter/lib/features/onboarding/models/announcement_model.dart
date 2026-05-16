class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String type;
  final String author;
  final String createdAt;
  final String? dateHuman;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.author,
    required this.createdAt,
    this.dateHuman,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      author: json['author']?.toString() ?? 'Admin',
      createdAt: json['created_at']?.toString() ?? '',
      dateHuman: json['date_human']?.toString(),
    );
  }
}
