import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';




class UsersOrders extends StatefulWidget {
  @override
  _UsersOrdersState createState() => _UsersOrdersState();
}

class _UsersOrdersState extends State<UsersOrders> {
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
    secondaryApp = await Firebase.initializeApp(
      name: 'mfoodapp',
      options: const FirebaseOptions(
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
    ).ref().child("Restaurant");
    try {
      _dbRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          final List<Map<String, dynamic>> loadedData = [];
          data.forEach((key, value) {
            loadedData.add({
              "uid": value["uid"],
              "key": value["key"],
              "name": value["name"],
              "price": value["price"],
              "image": value["image"],
              "user":value["user"],
              "status":value["status"],
              "quantity": value["quantity"],
              "total": value["total"],
              "payment":"cash"
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

  void updateData(String uid, String key)
  {
    Map<String,String> map = {
      "status":"Ready"
    };
    final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
        app: secondaryApp,
        databaseURL: "https://mfoodapp-5568b-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).ref();
    _dbRef.child("Restaurant").child(key).update(map).whenComplete(() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
    title: const Text("order is up to date!"),
    content: const Text("status update successfully!"),
    actions: [
      TextButton(onPressed: (){
        Navigator.pop(context);
      }, child: const Text("Done"))
    ],
    ),
    ).whenComplete(() => updateUserHistory(uid, key)
    )
    );
  }

  void updateUserHistory(String uid, String key){
    Map<String,String> map = {
      "status":"Ready"
    };
    final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
        app: secondaryApp,
        databaseURL: "https://mfoodapp-5568b-default-rtdb.asia-southeast1.firebasedatabase.app/"
    ).ref();
    _dbRef.child("users").child(uid).child("history").child(key).update(map).whenComplete(() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("user history is up to date!"),
        content: const Text("history update successfully!"),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: const Text("Done"))
        ],
      ),
    ).whenComplete(() => {

    })
    );


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders Management"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dataList.isEmpty
          ? const Center(child: Text("No data available"))
          : ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final item = dataList[index];
          return Dismissible(
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete,color: Colors.black,),
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
                    title: const Text("Item Details"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(item["image"]),
                        const SizedBox(height: 10),
                        Text("Name: ${item["name"]}"),
                        Text("Price: ${item["price"]}"),
                        Text("Quantity: ${item["quantity"]}"),
                        Text("Total: ${item["total"]}"),
                        Text("Payment: ${item["payment"]}"),
                        Text("User: ${item["user"]}"),
                        Text("Order Status: ${item["status"]}"),
                      ],
                    ),
                    actions: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                updateData(item["uid"],item["key"]);
                              });
                            },
                            child: const Text("Order IS Ready",
                              style: TextStyle(
                                color: Colors.green
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("done"),
                          ),
                        ],
                      ),

                    ],
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                      const SizedBox(width: 15),

                      // Name and Number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["name"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item["user"],
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