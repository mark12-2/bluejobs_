class Post {
  String? id;
  String? title;
  String? description;
  String? type;
  String? location;
  String? ownerId;
  String? startDate;
  String? workingHours;

  Post({
    this.id,
    this.title,
    this.description,
    this.type,
    this.location,
    this.ownerId,
    this.startDate,
    this.workingHours,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      location: map['location'],
      ownerId: map['ownerId'],
      startDate: map['startDate'],
      workingHours: map['workingHours'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'location': location,
      'ownerId': ownerId,
      'startDate': startDate,
      'workingHours': workingHours,
    };
  }
}
