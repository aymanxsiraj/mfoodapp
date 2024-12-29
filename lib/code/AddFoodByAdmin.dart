import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';



class AddFoodByAdmin extends StatefulWidget {
  @override
  _AddFoodByAdminState createState() => _AddFoodByAdminState();
}

class _AddFoodByAdminState extends State<AddFoodByAdmin> {
  // Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  // Firebase Realtime Database reference


  // Method to upload data
  Future<void> _uploadData() async {
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
    if (imageUrlController.text.isEmpty ||
        nameController.text.isEmpty ||
        numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill all fields."),
      ));
      return;
    }

    try {
      // Save data to Firebase Realtime Database
      String? key = _dbRef.push().key;
      await _dbRef.child("foods").child(key!).set({
        "key" : key,
        "name": nameController.text,
        "number": numberController.text,
        "image": imageUrlController.text,
        "status":"void"
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data added successfully!"),
      ));

      // Clear fields
      nameController.clear();
      numberController.clear();
      imageUrlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add food to system"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset("assets/backg.jpg"),
              SizedBox(height: 20),
              // Image URL Field
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: "Image URL",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Number Field
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Pirce",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _uploadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text("Add Item", style: TextStyle(fontSize: 18,color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}