class SubmissionModel {
  final int? id;
  final String name;
  final int price;
  final String description;
  final String githubUrl;
  final String? submittedAt;

  SubmissionModel({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.githubUrl,
    this.submittedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'] ?? '',
      price: int.tryParse(json['price']?.toString() ?? '') ?? 0,
      description: json['description'] ?? '',
      githubUrl: json['github_url'] ?? '',
      submittedAt: json['submitted_at'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'github_url': githubUrl,
    };
  }
}
