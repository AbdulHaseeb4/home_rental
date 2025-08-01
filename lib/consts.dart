import 'package:flutter/services.dart';

class Amenity {
  final String name;
  bool isSelected;

  Amenity({
    required this.name,
    this.isSelected = false,
  });
}

final List<Amenity> amenities = [
  Amenity(name: 'Gas'),
  Amenity(name: 'Electricity'),
  Amenity(name: 'Water Supply'),
  Amenity(name: 'Cable'),
  Amenity(name: 'Wifi'),
  Amenity(name: 'Great Location'),
];

initializeString()async{
  jsonString = await rootBundle.loadString('assets/chatbot/service-account.json');
  print(jsonString);

}

String? jsonString;