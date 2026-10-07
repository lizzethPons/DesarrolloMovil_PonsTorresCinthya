class TeamModel {
  final String id;
  final String name;
  final String? logo;

  TeamModel({required this.id, required this.name, this.logo});

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final logos = json['logos'];
    return TeamModel(
      id: json['id'].toString(),
      name: json['displayName'].toString(),
      logo: (logos is List && logos.isNotEmpty)
          ? logos.first['href']?.toString()
          : null,
    );
  }
}