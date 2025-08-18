class CategoryModel {
  final int? id;
  final String name;
  final String icon;

  CategoryModel({this.id, required this.name, this.icon = '💡'});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: (map['icon'] ?? '💡') as String,
    );
  }
}