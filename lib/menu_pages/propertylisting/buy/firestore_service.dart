import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to add a new property Buy-residential.
  Future<void> buyresidential({
    required String propertyType,
    required int singleRooms,
    required int doubleRooms,
    required int enSuiteRooms,
    required int bathrooms,
    required double price,
    required String cnic,
    required String propertySize,
    required String sellerType,
    required String location,
    required String description,
    required bool gas,
    required bool elecricity,
    required bool watersupply,
    required bool wifi,
    required bool greatlocation,
    required bool cable,
    required List<String> images, // Base64-encoded images
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      dynamic data = documentSnapshot.data();
      // Generate a unique property ID
      DocumentReference newPropertyRef = _firestore.collection("buyresidential").doc();

      // Property Data
      Map<String, dynamic> propertyData = {
        "propertyType": propertyType,
        "singleRooms": singleRooms,
        "doubleRooms": doubleRooms,
        "enSuiteRooms": enSuiteRooms,
        "bathrooms": bathrooms,
        "price": price,
        "cnic": cnic,
        "propertySize": propertySize,
        "sellerType": sellerType,
        "location": location,
        "description": description,
        "gas": gas,
        "cable": cable,
        "wifi": wifi,
        "elecricity": elecricity,
        "watersupply": watersupply,
        "greatlocation": greatlocation,
        "userId": userId,
        "images": images, // Storing images as Base64
        "createdAt": FieldValue.serverTimestamp(),
        "docId" : newPropertyRef.id,
        "isVerified": false,
        "userFcmToken": data["fcmToken"]
      };

      // Save property in the global collection for Buy/Rent Feed
      await newPropertyRef.set(propertyData);




      print("✅ Property added successfully!");
    } catch (e) {
      print("❌ Error adding property: $e");
      throw e;
    }
  }

  // Function to add a new property Buy-commercial
  Future<void> Buycommercial({
    required String propertyType,
    required double price,
    required String cnic,
    required String propertySize,
    required String sellerType,
    required String location,
    required String tax,
    required String description,
    required bool gas,
    required bool elecricity,
    required bool watersupply,
    required bool wifi,
    required bool greatlocation,
    required bool cable,
    required List<String> images, // Base64-encoded images
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      dynamic data = documentSnapshot.data();

      // Generate a unique property ID
      DocumentReference newPropertyRef = _firestore.collection("buycommercial").doc();

      // Property Data
      Map<String, dynamic> propertyData = {
        "propertyType": propertyType,
        "price": price,
        "cnic": cnic,
        "propertySize": propertySize,
        "sellerType": sellerType,
        "location": location,
        "tax": tax,
        "description": description,
        "gas": gas,
        "cable": cable,
        "wifi": wifi,
        "elecricity": elecricity,
        "watersupply": watersupply,
        "greatlocation": greatlocation,
        "userId": userId,
        "images": images, // Storing images as Base64
        "createdAt": FieldValue.serverTimestamp(),
        "docId" : newPropertyRef.id,
        "isVerified": false,
        "userFcmToken": data["fcmToken"]
      };

      // Save property in the global collection for Buy/Rent Feed
      await newPropertyRef.set(propertyData);

      // Save property under the user's properties collection


      print("✅ Property added successfully!");
    } catch (e) {
      print("❌ Error adding property: $e");
      throw e;
    }
  }


  // Function to add a new property Rent-commercial
  Future<void> Rentcommercial({
    required String propertyType,
    required double price,
    required String cnic,
    required String propertySize,
    required String sellerType,
    required String location,
    required String lease,
    required String startDate,
    required String description,
    required bool gas,
    required bool elecricity,
    required bool watersupply,
    required bool wifi,
    required bool greatlocation,
    required bool cable,
    required List<String> images, // Base64-encoded images
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      dynamic data = documentSnapshot.data();
      // Generate a unique property ID
      DocumentReference newPropertyRef = _firestore.collection("Rentcommercial").doc();

      // Property Data
      Map<String, dynamic> propertyData = {
        "propertyType": propertyType,
        "price": price,
        "cnic": cnic,
        "propertySize": propertySize,
        "sellerType": sellerType,
        "location": location,
        "lease": lease,
        'startDate': startDate,
        "description": description,
        "gas": gas,
        "cable": cable,
        "wifi": wifi,
        "elecricity": elecricity,
        "watersupply": watersupply,
        "greatlocation": greatlocation,
        "userId": userId,
        "images": images, // Storing images as Base64
        "createdAt": FieldValue.serverTimestamp(),
        "docId" : newPropertyRef.id,
        "isVerified": false,
        "userFcmToken": data["fcmToken"]
      };

      // Save property in the global collection for Buy/Rent Feed
      await newPropertyRef.set(propertyData);


      print("✅ Property added successfully!");
    } catch (e) {
      print("❌ Error adding property: $e");
      throw e;
    }
  }

  // Function to add a new property Rent-residential.
  Future<void> Rentresidential({
    required String propertyType,
    required int singleRooms,
    required int doubleRooms,
    required int enSuiteRooms,
    required int bathrooms,
    required double price,
    required String cnic,
    required String propertySize,
    required String sellerType,
    required String location,
    required String lease,
    required String startDate,
    String? access,
    required String description,
    required bool gas,
    required bool elecricity,
    required bool watersupply,
    required bool wifi,
    required bool greatlocation,
    required bool cable,
    required List<String> images, // Base64-encoded images
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      dynamic data = documentSnapshot.data();
      // Generate a unique property ID
      DocumentReference newPropertyRef = _firestore.collection("Rentresidential").doc();

      // Property Data
      Map<String, dynamic> propertyData = {
        "propertyType": propertyType,
        "singleRooms": singleRooms,
        "doubleRooms": doubleRooms,
        "enSuiteRooms": enSuiteRooms,
        "bathrooms": bathrooms,
        "price": price,
        "cnic": cnic,
        "propertySize": propertySize,
        "sellerType": sellerType,
        "location": location,
        "lease": lease,
        'startDate': startDate,
        'access': access,
        "description": description,
        "gas": gas,
        "cable": cable,
        "wifi": wifi,
        "elecricity": elecricity,
        "watersupply": watersupply,
        "greatlocation": greatlocation,
        "userId": userId,
        "images": images, // Storing images as Base64
        "createdAt": FieldValue.serverTimestamp(),
        "docId" : newPropertyRef.id,
        "isVerified": false,
        "userFcmToken": data["fcmToken"]
      };

      // Save property in the global collection for Buy/Rent Feed
      await newPropertyRef.set(propertyData);


      print("✅ Property added successfully!");
    } catch (e) {
      print("❌ Error adding property: $e");
      throw e;
    }
  }


  // Function to add a new property Rent-commercial
  Future<void> Shareroomrent({
    required String propertyType,
    required int singleRooms,
    required int doubleRooms,
    required int enSuiteRooms,
    required int bathrooms,
    required double price,
    required String cnic,
    required String propertySize,
    required String sellerType,
    required String location,
    required String lease,
    required String selectedTenants,
    required String startDate,
    required String description,
    required bool ownerOccupied,
    required bool isPlusOneAllowed,
    required String selectedPreference,
    required bool gas,
    required bool elecricity,
    required bool watersupply,
    required bool wifi,
    required bool greatlocation,
    required bool cable,
    required List<String> images, // Base64-encoded images
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      dynamic data = documentSnapshot.data();
      // Generate a unique property ID
      DocumentReference newPropertyRef = _firestore.collection("Shareroomrent").doc();

      // Property Data
      Map<String, dynamic> propertyData = {
        "propertyType": propertyType,
        "singleRooms": singleRooms,
        "doubleRooms": doubleRooms,
        "enSuiteRooms": enSuiteRooms,
        "bathrooms": bathrooms,
        "price": price,
        "cnic": cnic,
        "propertySize": propertySize,
        "sellerType": sellerType,
        "location": location,
        "lease": lease,
        "selectedTenants": selectedTenants,
        'startDate': startDate,
        "description": description,
        'ownerOccupied': ownerOccupied,
        'isPlusOneAllowed': isPlusOneAllowed,
        'selectedPreference': selectedPreference,
        "gas": gas,
        "cable": cable,
        "wifi": wifi,
        "elecricity": elecricity,
        "watersupply": watersupply,
        "greatlocation": greatlocation,
        "userId": userId,
        "images": images, // Storing images as Base64
        "createdAt": FieldValue.serverTimestamp(),
        "docId" : newPropertyRef.id,
        "isVerified": false,
        "userFcmToken": data["fcmToken"]

      };

      // Save property in the global collection for Buy/Rent Feed
      await newPropertyRef.set(propertyData);


      print("✅ Property added successfully!");
    } catch (e) {
      print("❌ Error adding property: $e");
      throw e;
    }
  }

}
