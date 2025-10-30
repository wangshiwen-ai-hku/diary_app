import 'package:hive/hive.dart';

part 'diary.g.dart';

@HiveType(typeId: 0)
class Diary extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String type; // daily, sweet, highlight, quarrel, travel

  @HiveField(3)
  String rawContent; // 用户输入的原始内容

  @HiveField(4)
  String? aiContent; // AI生成的完整日记 (Markdown)

  @HiveField(5)
  String? mood; // happy, sweet, miss, excited, calm, sad, angry

  @HiveField(6)
  String style; // warm, poetic, real, funny

  @HiveField(7)
  List<String> photos; // 照片路径列表

  @HiveField(8)
  String? location; // 地点

  @HiveField(9)
  List<String> tags; // 标签

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime? updatedAt;

  @HiveField(12)
  bool isEdited; // 是否手动编辑过

  Diary({
    required this.id,
    required this.date,
    required this.type,
    required this.rawContent,
    this.aiContent,
    this.mood,
    required this.style,
    this.photos = const [],
    this.location,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
  });

  Diary copyWith({
    String? id,
    DateTime? date,
    String? type,
    String? rawContent,
    String? aiContent,
    String? mood,
    String? style,
    List<String>? photos,
    String? location,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
  }) {
    return Diary(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      rawContent: rawContent ?? this.rawContent,
      aiContent: aiContent ?? this.aiContent,
      mood: mood ?? this.mood,
      style: style ?? this.style,
      photos: photos ?? this.photos,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
