import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mfoodapp/code/OrderHistory.dart';



class ViewUserOrderHistory extends StatefulWidget {
  @override
  _ViewUserOrderHistoryState createState() => _ViewUserOrderHistoryState();
}

class _ViewUserOrderHistoryState extends State<ViewUserOrderHistory> {
  //final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("foods");
  List<Map<String, dynamic>> dataList = [];
  bool isLoading = true;
  late FirebaseApp secondaryApp;
  late final DatabaseReference _dbRef;


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data from Firebase
  Future<void> _fetchData() async {
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
    _dbRef = FirebaseDatabase.instanceFor(
        app: secondaryApp,
        databaseURL: "https://mfoodapp-5568b-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).ref().child("users").child(FirebaseAuth.instance.currentUser!.uid).child("history");
    try {
      _dbRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          final List<Map<String, dynamic>> loadedData = [];
          data.forEach((key, value) {
            loadedData.add({
              "id": key,
              "key": value["key"],
              "name": value["name"],
              "number": value["number"],
              "image": value["image"],
            });
          });

          setState(() {
            dataList = loadedData;
            isLoading = false;
          });
        } else {
          setState(() {
            dataList = [];
            isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  void deleteData(String key) async {

    final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
        app: secondaryApp,
        databaseURL: "https://mfoodapp-5568b-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).ref().child("users").child(FirebaseAuth.instance.currentUser!.uid).child("history");

    try {
      await _dbRef.child("key").remove().then((value) => (){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data removed successfully.")),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while removing data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History List"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : dataList.isEmpty
          ? Center(child: Text("No data available"))
          : ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final item = dataList[index];
          return Dismissible(
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete,color: Colors.black,),
            ),
            key: ValueKey(dataList[index]),
            onDismissed: (DismissDirection direction) {
              setState(() {
                deleteData(item["key"]);
                dataList.removeAt(index);
              });
            },
            child: GestureDetector(
              onTap: () {
                // Action when item is tapped
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Item Details"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(item["image"]),
                        SizedBox(height: 10),
                        Text("Name: ${item["name"]}"),
                        Text("Price: ${item["number"]}"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("done"),
                      ),

                    ],
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item["image"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 15),

                      // Name and Number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["name"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              item["number"],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}