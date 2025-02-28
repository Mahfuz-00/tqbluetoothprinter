class Company {
  final String name;

  Company({
    required this.name,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
    );
  }
}
//If want to send data to API
/*  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'address': address,
      'logo': logo,
    };
  }*/

class Category {
  final int id;
  final String nameEn;
  final String nameBn;
  final String? DocBn;
  final String? DocEn;
  final String? DocDesignation;
  final String? DocRoom;

  Category({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    this.DocBn,
    this.DocEn,
    this.DocDesignation,
    this.DocRoom,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameBn: json['name_bn'] ?? '',
      DocBn: json['doctor_name_bn'] ?? '',
      DocEn: json['doctor_name_en'] ?? '',
      DocDesignation: json['doctor_designation'] ?? '',
      DocRoom: json['doctor_room_no'] ?? '',
    );
  }
}