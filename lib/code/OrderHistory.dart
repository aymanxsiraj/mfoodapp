import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderHistory{
  late BuildContext context;
  String uid = "";
  String url = "";
  String key = "";
  String foodName = "";
  String foodPrice = "";
  String status ="";


  OrderHistory(this.context, this.uid, this.key, this.url, this.foodName, this.foodPrice, this.status);

  Future<void> uploadData() async {
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'mfoodapp',
      options: FirebaseOptions(
        apiKey: 'AIzaSyAX3vZm1osOl5ff_Aerv2c_UbrjUIRlKI0',
        appId: '1:606656212066:android:f8f83a0c5110050490f53b',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'mfoodapp-5568b',
        databaseURL: 'https://mfoodapp-5568b-default-rtdb.asia-southeast1.firebasedatabase.app/',
      ),
    );
    final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
        app: secondaryApp,
        databaseURL: "https://mfoodapp-5568b-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).ref();
    if (uid.isEmpty ||
        url.isEmpty ||
        foodName.isEmpty ||
        foodPrice.isEmpty
    ) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill all fields."),
      ));
      return;
    }

    try {
      // Save data to Firebase Realtime Database
      await _dbRef.child("users").child(uid).child("history").push().set({
        "key" : key,
        "name": foodName,
        "number": foodPrice,
        "image": url,
        "status": status
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data added successfully!"),
      ));
      Navigator.pop(context);


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    }
  }
}