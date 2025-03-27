class Violation {
  final String id;
  final String licensePlate;
  final String violationType;
  final String location;
  final DateTime date;
  final double fine;
  final String imageUrl;

  Violation({
    required this.id,
    required this.licensePlate,
    required this.violationType,
    required this.location,
    required this.date,
    required this.fine,
    this.imageUrl = '',
  });

  factory Violation.fromJson(Map<String, dynamic> json) {
    return Violation(
      id: json['id'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      violationType: json['violationType'] ?? '',
      location: json['location'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      fine: (json['fine'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'violationType': violationType,
      'location': location,
      'date': date.toIso8601String(),
      'fine': fine,
      'imageUrl': imageUrl,
    };
  }
} 