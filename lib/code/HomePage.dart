import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  String _userName = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
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
    final DatabaseReference _databaseReference = FirebaseDatabase.instanceFor(
        app: secondaryApp,
        databaseURL: "https://mfoodapp-5568b-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).ref();

    final DataSnapshot snapshot = await _databaseReference.child("users").child(FirebaseAuth.instance.currentUser!.uid).child("name").get();
    if (snapshot.exists) {
      
      setState(() {
        _userName = snapshot.value.toString();
      });
    } else {
      setState(() {
        _userName = 'YourName';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(_userName),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // First Card - Student
                  buildCard(
                    icon: Icons.person_outline,
                    number: "",
                    label: "Profile",
                      click: (){
                        setState(() {
                          Navigator.pushNamed(context, '/profile');
                        });
                      }
                  ),
                  const SizedBox(width: 16), // Space between cards
                  buildCard(
                    icon: Icons.emoji_food_beverage_rounded,
                    number: "",
                    label: "Order Food",
                      click: (){
                        setState(() {
                          Navigator.pushNamed(context, '/menu');
                        });
                      }
                  ),
                ],
              ),
        
              const SizedBox(height: 16),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // First Card - Student
                  buildCard(
                    icon: Icons.shopping_basket,
                    number: "",
                    label: "Order History",
                    click: (){
                      setState(() {
                        Navigator.pushNamed(context, '/history');
                      });
                    }
                  ),
             // Space between cards
        
                ],
              ),
              const SizedBox(height: 16),
              Image.asset("assets/foodon.jpg")
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard({
    required IconData icon,
    required String number,
    required String label,
    required VoidCallback click
  }) {
    return Expanded(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon and Number Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Label
            Container(
              color: Colors.black,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: click,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
