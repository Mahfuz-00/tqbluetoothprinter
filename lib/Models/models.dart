class Company {
  final String name;
  final String email;
  final String address;
  final String logo;

  Company({
    required this.name,
    required this.email,
    required this.address,
    required this.logo,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      email: json['email'],
      address: json['address'],
      logo: json['logo'],
    );
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
}

class Category {
  final int id;
  final String nameEn;
  final String nameBn;

  Category({
    required this.id,
    required this.nameEn,
    required this.nameBn,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nameEn: json['name_en'],
      nameBn: json['name_bn'],
    );
  }
}