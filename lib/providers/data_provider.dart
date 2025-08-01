import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;




class DataProvider extends ChangeNotifier{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();

  List<dynamic> userFavourite = GetStorage().read("favouriteProperty") ?? [];
  final propertiesCollection = FirebaseFirestore.instance.collection("buycommercial");
  final buyresidentialCollection = FirebaseFirestore.instance.collection("buyresidential");
  final RentcommercialCollection = FirebaseFirestore.instance.collection("Rentcommercial");
  final RentresidentialCollection = FirebaseFirestore.instance.collection("Rentresidential");
  final ShareroomrentCollection = FirebaseFirestore.instance.collection("Shareroomrent");
  StreamController<List<dynamic>>? _propertyListController;
  StreamController<List<dynamic>>? _propertyListController2;
  StreamController<List<dynamic>>? _propertyListController3;
  StreamController<List<dynamic>>? _propertyListController4;
  StreamController<List<dynamic>>? _propertyListController5;

  List<dynamic> propertyList = [];
  List<dynamic> propertyList2 = [];
  List<dynamic> propertyList3 = [];
  List<dynamic> propertyList4 = [];
  List<dynamic> propertyList5 = [];

  /// ✅ Dark Mode Variables
  ThemeMode _themeMode = ThemeMode.light; // Default is Light Mode
  ThemeMode get themeMode => _themeMode; // Getter to access theme mode

  /// ✅ Load the saved theme preference
  void _loadTheme() {
    final bool isDarkMode = box.read("isDarkMode") ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // ✅ UI update must happen
  }


  /// ✅ Toggle Dark Mode
  void toggleTheme() async {
    bool isDark = _themeMode == ThemeMode.dark;
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    box.write("isDarkMode", !isDark); // ✅ Save the preference in GetStorage
    notifyListeners(); // ✅ This updates the UI
  }




  /// ✅ **Get the logged-in user's ID**
  String? get userId => _auth.currentUser?.uid;

  /// ✅ **Constructor - Load user favorites when the provider is initialized**
  DataProvider() {
    _loadUserFavourites();
    _loadTheme();
    _auth.authStateChanges().listen((user) {
      _loadUserFavourites(); // Update favorites when the user logs in or logs out
    });
  }

  /// ✅ **Load Favourites for the Logged-in User**
  void _loadUserFavourites() {
    if (userId != null) {
      userFavourite = List<String>.from(box.read("favouriteProperty_$userId") ?? []);
    } else {
      userFavourite = []; // Reset if no user is logged in
    }
    notifyListeners();
  }

  Future<String> getAccessToken2() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "home-rental-95294",
      "private_key_id": "529395c9d7daf97ac1f064ea54624c8a8565e58d",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDOR7duwvQuTNqC\nSbiYrFMvOacoSmnslpnP0QRRUjW9Xkuk6N+hxN5CwhNRH+NAyOuiWnXCoBhYP75X\nE+1ztadpnI9//ym3ZxoUgeVI5WaFrin9aH4XKGYW6IWdPaLnULpYlZG4zOm5Lp+2\nZrsAYWR/RL7psQKvdoxaRMGPV3f78Ra/G0k6dqLAl7TwoRJpNwTd0H24/QygthJr\nQUS8rz7whIiCZJz1hxj/jgCc4foqWjnxnpFauoPGarFxfmHcMCr+H5ejdTsr7/00\nhH0IKUVsU4XXAVZfmEYY4VGSiWPFukIKya3JYFbmAo4kJpxldRQId0Dttn7BHPNW\nlhPTFHR/AgMBAAECggEAA9/Emf/EU+hH7vbRJjY6UQ09Tpw91V6AtgP1bPePyyYt\nt9j9y40l0CLSomKTGIuNeAed5ZFZ07J4HII4d+9bR7hT2PINslmX26G9kNBqIVbu\nMp8B8I+8LHBNLhuoZxK/j9wDQsa/xFAUBM90x02M9HecjvQERQ+uFCCYHV07A3rG\nMLD8cWfskvUpwajMWO5NgBaK1eSTq/TpKnf23WrV0UFZ0TKPQIGMq7u6xVIODt/J\nWiPB+zvuUT+arE1IsSB5lNDhhgw5MWrByqWtUMt/LX4n4za6eYG5iuYQC0y47bbh\n91tta9nSfNDQ0BwvHFqPD3Z3plhm6JzF/P7u48q7DQKBgQDu6/vxFjxBHnxD8/JS\nxpDt2Mmt3s+ANJWQ1sYvpjX4nmsI6WMeludSnvu9zsV9F3YHy39DY2tFw6JCUU22\nZqoaSPC/+JHl/SxdX3kwgjVe+3HBp3EF0Lx0pqHYkWr1ETbY90/0uaWcVzCLXxg7\nLsRpZGC91dNFWO8XAAedbksbJQKBgQDdBmynVqiM62ihT+bM3UVAJ6XexYkwYVQ8\nPZ5EZTDPnAE3y/RDHR05lD4g5HjBy1c8dbChDzY89+E8XHszVEexzd9JCVVCvxWZ\nF60xCjQa7Ptol/weLP4yCBUOBcciLaMOe0jAu9vvxkF3XPVOR10A4fV826EZpqRb\n4isRQ58x0wKBgEYIMf9G7z5/OxmIBf2xaoXtR6CJcPU5dKXR7qHE7IkFloY0MvOi\ndAfJxiyq0USLffNm+NS97ZGzeHpL7qWKjk3KF5eNuuZZQYnVFGbdo9tFhOCovf5g\nYv0mYsZiSaGv/A244FzxldOv0vDnXOjsGnJyE9FRPe5T1TE+tvy0eZtpAoGABtYL\nCEXy4qDpVIvvHIj/elN/mttLOfbYryBMw9rJXrJ5iytAu86rt7sxDL1kSsIqSZFu\nTBz3VX1pNv+5Q8YojYRLkqu6Ol1Eor6LuceSAv8va3W/84L6vbtoQ03EcfctYuZH\nQsbMr6bXIYT7hVdJthxHBnyYh/2SedEN+fO4eccCgYBIuW74gw1+5SHvsBiP/5Qs\n/GTK1ZdwqaWW650Rd4ClUaGfkUlMlM5NO4DW+W44/uAlDpour64Nj0To4zn6ft5B\nPVsoInQPsvNHs5E/wkxnF6Hppp7OqEPHDk79+XQDlfAzLDVfgN9YjrF8yDUVJYnc\n590oTsesBvh4buOFxeR9KA==\n-----END PRIVATE KEY-----\n",
      "client_email": "home-rental-account@home-rental-95294.iam.gserviceaccount.com",
      "client_id": "108284095945456324121",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/home-rental-account%40home-rental-95294.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    var accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
    var client = await auth.clientViaServiceAccount(accountCredentials, scopes);

    return client.credentials.accessToken.data;
  }

  Future saveQueryData({
    required String name,
    required String email,
    required String phone,
    required String propertyName,
    required String propertyPrice,
    required String message,
    required String userID, // ✅ Landlord ka ID
  }) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid; // ✅ Jo renter query bhej raha hai

    // ✅ Landlord ka naam Firestore se fetch karein
    DocumentSnapshot landlordDoc = await FirebaseFirestore.instance.collection("users").doc(userID).get();
    String landlordName = landlordDoc.exists ? (landlordDoc['name'] ?? 'Unknown') : 'Unknown';

    DocumentReference newPropertyRef = FirebaseFirestore.instance.collection('allQueries').doc();

    await FirebaseFirestore.instance.collection('allQueries').doc(newPropertyRef.id).set({
      'name': name,
      'email': email,
      'phone': phone,
      'propertyName': propertyName,
      "price": propertyPrice,
      "message": message,
      "userId": userID, // ✅ Yeh landlord ka ID hai
      "sentBy": currentUserId, // ✅ Yeh renter ka ID hai
      "landlordName": landlordName, // ✅ NEW FIELD: Landlord ka naam
      "createdAt": FieldValue.serverTimestamp(),
    });
  }




  Future sendNotification(List<dynamic> tokens, String name) async {
    final String serverKey = await getAccessToken2();
    const url = 'https://fcm.googleapis.com/v1/projects/home-rental-95294/messages:send';
    for(dynamic token in tokens){
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            "message": {
              "token": token,
              'notification': {
                'title': "New Message Received",
                'body': "You got a new query from $name",
              },
            }
          },
        ),
      );
      if(response.statusCode == 200){
        print("notification Sent");
      }else{
        print(response.body.toString());
      }
    }
  }

  /// ✅ **Add to Favourites (Per User)**
  void addToFavourite(String docId) {
    if (userId != null && !userFavourite.contains(docId)) {
      userFavourite.add(docId);
      notifyListeners();
      box.write("favouriteProperty_$userId", userFavourite);
    }
  }

  /// ✅ **Remove from Favourites (Per User)**
  void removeFromFavourite(String docId) {
    if (userId != null && userFavourite.contains(docId)) {
      userFavourite.remove(docId);
      notifyListeners();
      box.write("favouriteProperty_$userId", userFavourite);
    }
  }

  /// ✅ **Check if Property is Favourite**
  bool isFavourite(String docId) {
    return userFavourite.contains(docId);
  }

  /// ✅ ** Property  Favourite function**
  Stream<List<dynamic>> getFavouriteProperties() async* {
    if (userId == null) {
      yield [];
      return;
    }

    try {
      StreamController<List<dynamic>> favPropertiesController = StreamController();
      List<dynamic> favProperties = [];

      // ✅ Ensure only logged-in user's favorites are loaded
      List<String> userSpecificFavorites = List<String>.from(box.read("favouriteProperty_$userId") ?? []);

      if (userSpecificFavorites.isEmpty) {
        yield [];
        return;
      }

      // ✅ Fetch from each collection & attach collection name
      Map<String, CollectionReference> collections = {
        "buycommercial": FirebaseFirestore.instance.collection("buycommercial"),
        "buyresidential": FirebaseFirestore.instance.collection("buyresidential"),
        "Rentcommercial": FirebaseFirestore.instance.collection("Rentcommercial"),
        "Rentresidential": FirebaseFirestore.instance.collection("Rentresidential"),
        "Shareroomrent": FirebaseFirestore.instance.collection("Shareroomrent"),
      };

      for (var entry in collections.entries) {
        String collectionName = entry.key;
        CollectionReference collection = entry.value;

        Stream<QuerySnapshot> result = collection
            .where(FieldPath.documentId, whereIn: userSpecificFavorites)
            .snapshots()
            .asBroadcastStream();

        result.listen((event) async {
          for (var element in event.docs) {
            var property = element.data()! as Map<String, dynamic>;
            property["collection"] = collectionName; // ✅ Add collection name to each property
            favProperties.add(property);
          }
          favPropertiesController.sink.add(favProperties);
        }, cancelOnError: true);
      }

      yield* favPropertiesController.stream;
    } catch (error) {
      print(error);
      yield [];
    }
  }

  /// ✅ ** get all my ads function**
  Stream<List<dynamic>> getAllMyAds() async* {
    if (userId == null) {
      yield [];
      return;
    }

    try {
      StreamController<List<dynamic>> favPropertiesController = StreamController();
      List<dynamic> favProperties = [];

      // ✅ Fetch from each collection & attach collection name
      Map<String, CollectionReference> collections = {
        "buycommercial": FirebaseFirestore.instance.collection("buycommercial"),
        "buyresidential": FirebaseFirestore.instance.collection("buyresidential"),
        "Rentcommercial": FirebaseFirestore.instance.collection("Rentcommercial"),
        "Rentresidential": FirebaseFirestore.instance.collection("Rentresidential"),
        "Shareroomrent": FirebaseFirestore.instance.collection("Shareroomrent"),
      };

      for (var entry in collections.entries) {
        String collectionName = entry.key;
        CollectionReference collection = entry.value;

        Stream<QuerySnapshot> result = collection
            .snapshots()
            .asBroadcastStream();

        result.listen((event) async {
          for (var element in event.docs) {
            var property = element.data()! as Map<String, dynamic>;
            property["collection"] = collectionName; // ✅ Add collection name to each property
            favProperties.add(property);
          }
          favPropertiesController.sink.add(favProperties);
        }, cancelOnError: true);
      }

      yield* favPropertiesController.stream;
    } catch (error) {
      print(error);
      yield [];
    }
  }

  /// ✅ ** get get totals ads count for buy page function**
  Future<int> getTotalAdsCount1() async {
    int totalAds = 0;

    try {
      List<String> collections = [
        "buycommercial",
        "buyresidential",
      ];

      for (String collection in collections) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
        totalAds += snapshot.docs.length;
      }
    } catch (e) {
      print("Error fetching total ads count: $e");
    }

    return totalAds;
  }

  /// ✅ ** get get totals ads count for rent page function**
  Future<int> getTotalAdsCount2() async {
    int totalAds = 0;

    try {
      List<String> collections = [
        "Rentcommercial",
        "Rentresidential",
        "Shareroomrent"
      ];

      for (String collection in collections) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
        totalAds += snapshot.docs.length;
      }
    } catch (e) {
      print("Error fetching total ads count: $e");
    }

    return totalAds;
  }
// ✅ Chat Messages List (Now Stores Messages Per User)
  Map<String, List<Map<String, dynamic>>> userChatMessages = {};

// ✅ Get Logged-in User ID
  void addNewChatMessage({required bool isUser, required String message}) {
    if (userId == null) return; // ✅ No need to redefine userId

    // ✅ If user has no messages yet, create an empty list
    if (!userChatMessages.containsKey(userId)) {
      userChatMessages[userId!] = [];
    }

    // ✅ Add message to logged-in user's chat history
    userChatMessages[userId!]!.add({
      "isUser": isUser,
      "message": message,
      "timestamp": FieldValue.serverTimestamp(),
    });

    notifyListeners(); // ✅ UI will update automatically
  }


  // ✅ Get Messages for Logged-in User (Fix userId Conflict)
  List<Map<String, dynamic>> get userMessages {
    return userChatMessages[userId] ?? []; // ✅ No need to redefine userId
  }

// ✅ Clear Chat History (Only for Logged-in User)
  void clearChat() {
    if (userId != null) {
      userChatMessages[userId!] = [];
      notifyListeners();
    }
  }


  Stream<List<dynamic>> getProperties() async*{
    try{
      _propertyListController = StreamController();
      Stream<QuerySnapshot> result = propertiesCollection.orderBy('createdAt',descending: true).snapshots().asBroadcastStream();
      result.listen((event) async {
        propertyList.clear();
        await Future.forEach(event.docs, (DocumentSnapshot element) {
          propertyList.add(element.data()! as Map<String, dynamic>);
        });
        _propertyListController!.sink.add(propertyList);
      }, cancelOnError: true);
      yield* _propertyListController!.stream;
    } catch (error) {
      print(error);
    }

  }
  Stream<List<dynamic>> getProperties2() async*{
    try{
      _propertyListController2 = StreamController();
      Stream<QuerySnapshot> result = buyresidentialCollection.orderBy('createdAt',descending: true).snapshots().asBroadcastStream();
      result.listen((event) async {
        propertyList2.clear();
        await Future.forEach(event.docs, (DocumentSnapshot element) {
          propertyList2.add(element.data()! as Map<String, dynamic>);
        });
        _propertyListController2!.sink.add(propertyList2);
      }, cancelOnError: true);
      yield* _propertyListController2!.stream;
    } catch (error) {
      print(error);
    }

  }

  Stream<List<dynamic>> getProperties3() async*{
    try{
      _propertyListController3 = StreamController();
      Stream<QuerySnapshot> result = RentcommercialCollection.orderBy('createdAt',descending: true).snapshots().asBroadcastStream();
      result.listen((event) async {
        propertyList3.clear();
        await Future.forEach(event.docs, (DocumentSnapshot element) {
          propertyList3.add(element.data()! as Map<String, dynamic>);
        });
        _propertyListController3!.sink.add(propertyList3);
      }, cancelOnError: true);
      yield* _propertyListController3!.stream;
    } catch (error) {
      print(error);
    }

  }
  Stream<List<dynamic>> getProperties4() async*{
    try{
      _propertyListController4 = StreamController();
      Stream<QuerySnapshot> result = RentresidentialCollection.orderBy('createdAt',descending: true).snapshots().asBroadcastStream();
      result.listen((event) async {
        propertyList4.clear();
        await Future.forEach(event.docs, (DocumentSnapshot element) {
          propertyList4.add(element.data()! as Map<String, dynamic>);
        });
        _propertyListController4!.sink.add(propertyList4);
      }, cancelOnError: true);
      yield* _propertyListController4!.stream;
    } catch (error) {
      print(error);
    }

  }

  Stream<List<dynamic>> getProperties5() async*{
    try{
      _propertyListController5 = StreamController();
      Stream<QuerySnapshot> result = ShareroomrentCollection.orderBy('createdAt',descending: true).snapshots().asBroadcastStream();
      result.listen((event) async {
        propertyList5.clear();
        await Future.forEach(event.docs, (DocumentSnapshot element) {
          propertyList5.add(element.data()! as Map<String, dynamic>);
        });
        _propertyListController5!.sink.add(propertyList5);
      }, cancelOnError: true);
      yield* _propertyListController5!.stream;
    } catch (error) {
      print(error);
    }

  }

}