// class UserModel {
//   String? id;
//   String? username;
//   String? name;
//   String? biography;
//   String? city;
//   String? email;
//   String? mobile;
//   String? dob;
//   List<String>? hobbies;
//   List<String>? interests;
//   String? country;
//
//   UserModel.fromJson(Map<String, dynamic> json)
//       : id = json['id'] as String,
//         username = json['username'] as String,
//         name = json['name'] as String,
//         biography = json['biography'] as String,
//         city = json['city'] as String,
//         email = json['email'] ?? "NA",
//         mobile = json['mobile'] as String,
//         dob = json['dob'] ?? "NA",
//         hobbies = List<String>.from(json['hobbies'] as List),
//         country = json['country'] ?? "NA",
//         interests = List<String>.from(json['interests'] as List);
// }

class UserModel {
  final String id;
  final String username;
  final String name;
  final String biography;
  final String city;
  final String email;
  final String mobile;
  final String dob;
  final List<String> hobbies;
  final String country;
  final List<String> interests;

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String? ?? 'NA',
        username = json['username'] as String? ?? 'NA',
        name = json['name'] as String? ?? 'NA',
        biography = json['bio'] as String? ?? 'NA',
        city = json['city'] as String? ?? 'NA',
        email = json['email'] as String? ?? 'NA',
        mobile = json['mobile'] as String? ?? 'NA',
        dob = json['dob'] as String? ?? 'NA',
        hobbies = json['hobbies'] != null
            ? List<String>.from(json['hobbies'] as List)
            : [],
        country = json['country'] as String? ?? 'NA',
        interests = json['interests'] != null
            ? List<String>.from(json['interests'] as List)
            : [];
}
