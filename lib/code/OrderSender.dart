import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderSender{
  late BuildContext context;
  String uid = "";
  String key = "";
  String url = "";
  String foodName = "";
  String foodPrice = "";
  String userName = "";
  String status = "";
  String quantity ="";
  String total ="";
  String payment = "";



  OrderSender(this.context, this.uid, this.key, this.url, this.foodName, this.foodPrice, this.userName, this.status, this.quantity, this.total, this.payment);

  Future<void> uploadData() async {
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'mfoodapp',
      options: const FirebaseOptions(
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
      await _dbRef.child("Restaurant").child(key).set({
        "uid" : uid,
        "key" : key,
        "name": foodName,
        "price": foodPrice,
        "image": url,
        "user":userName,
        "status":status,
        "quantity": quantity,
        "total": total,
        "payment": payment
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