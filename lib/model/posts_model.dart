class Post {
  String? id;
  String? title;
  String? description;
  String? type;
  String? location;
  String? rate;
  String? ownerId;

  Post({
    this.id,
    this.title,
    this.description,
    this.type,
    this.location,
    this.rate,
    this.ownerId,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      location: map['location'],
      rate: map['rate'],
      ownerId: map['ownerId'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'location': location,
      'rate': rate,
    };
  }

}