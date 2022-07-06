import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  User(
      {required this.id,
      required this.name,
      required this.age,
      required this.gender});
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  String gender;

  static User fromJson(json) =>
      User(id: json['id'], name: json['name'], age: -1, gender: '');
}
