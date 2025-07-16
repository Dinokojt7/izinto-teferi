class RecommendedSpecialtyModel {
  String? id;
  String? name;
  String? description;
  List<Stores> stores;

  RecommendedSpecialtyModel(
      {this.id, this.name, this.description, required this.stores});

  RecommendedSpecialtyModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        stores = (json['stores'] as List)
            .map((dynamic e) => Stores.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stores != null) {
      data['Stores'] = this.stores.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stores {
  String? id;
  String? title;
  String? thumbnail;
  String? displayLogo;
  String? description;
  String? location;
  List<Specialties> specialties;

  Stores(
      {this.id,
      this.title,
      this.thumbnail,
      this.displayLogo,
      this.description,
      this.location,
      required this.specialties});

  Stores.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        thumbnail = json['thumbnail'],
        displayLogo = json['DisplayLogo'],
        description = json['Description'],
        location = json['Location'],
        specialties = (json['specialties'] as List)
            .map((dynamic e) => Specialties.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['thumbnail'] = this.thumbnail;
    data['DisplayLogo'] = this.displayLogo;
    data['Description'] = this.description;
    data['Location'] = this.location;
    if (this.specialties != null) {
      data['Specialties'] = this.specialties.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Specialties {
  int? id;
  String? name;
  String? introduction;
  int? price;
  String? createAt;
  String? turnaroundTime;
  String? img;
  List<double>? location;
  String? type;
  String? material;
  String? provider;
  List<int>? quantity;
  String? time;

  Specialties(
      {this.id,
      this.name,
      this.introduction,
      this.price,
      this.createAt,
      this.turnaroundTime,
      this.img,
      this.location,
      this.type,
      this.material,
      this.provider,
      this.quantity,
      this.time});

  Specialties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    introduction = json['introduction'];
    price = json['price'];
    createAt = json['createAt'];
    turnaroundTime = json['turnaroundTime'];
    img = json['img'];
    location = json['location'].cast<double>();
    type = json['type'];
    material = json['material'];
    provider = json['provider'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['introduction'] = this.introduction;
    data['price'] = this.price;
    data['createAt'] = this.createAt;
    data['turnaroundTime'] = this.turnaroundTime;
    data['img'] = this.img;
    data['location'] = this.location;
    data['type'] = this.type;
    data['material'] = this.material;
    data['provider'] = this.provider;

    data['time'] = this.time;
    return data;
  }
}
