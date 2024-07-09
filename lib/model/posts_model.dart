class Post {
  String? id;
  String? title;
  String? description;
  String? type;
  String? location;
  String? rate;
  String? ownerId;
  String? numberOfWorkers;
  String? startDate;
  String? endDate;
  String? workingHours;

  Post({
    this.id,
    this.title,
    this.description,
    this.type,
    this.location,
    this.rate,
    this.ownerId,
    this.numberOfWorkers,
    this.startDate,
    this.endDate,
    this.workingHours,
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
      numberOfWorkers: map['numberOfWorkers'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      workingHours: map['workingHours'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'location': location,
      'rate': rate,
      'ownerId': ownerId,
      'numberOfWorkers': numberOfWorkers,
      'startDate': startDate,
      'endDate': endDate,
      'workingHours': workingHours,
    };
  }
}
