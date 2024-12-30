import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'OrderHistory.dart';
import 'OrderSender.dart';




class FoodMenu extends StatefulWidget {
  @override
  _FoodMenuState createState() => _FoodMenuState();
}

class _FoodMenuState extends State<FoodMenu> {
  //final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("foods");
  List<Map<String, dynamic>> dataList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data from Firebase
  Future<void> _fetchData() async {
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
    ).ref().child("foods");
    try {
      _dbRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          final List<Map<String, dynamic>> loadedData = [];
          data.forEach((key, value) {
            loadedData.add({
              "key": value["key"],
              "name": value["name"],
              "price": value["price"],
              "image": value["image"],
              "status": value["status"]
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

  //child: Text("Quantity: ${quantity}")
  final ValueNotifier<int> _quantity = ValueNotifier<int>(0);
  final ValueNotifier<int> _total = ValueNotifier<int>(0);
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Food List"),
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
          return GestureDetector(
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
                      
                      Text("Price: ${item["price"]}",),

                      ValueListenableBuilder(
                        valueListenable: _quantity,
                        builder: (context, value, child){
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quantity: $value',
                              ),
                              Row(
                                children: [
                                  TextButton(onPressed: (){
                                    _quantity.value++;
                                    int p = int.parse(item["price"].toString());
                                    _total.value = _quantity.value * p;// Increment counter

                                  },
                                      child: Icon(Icons.add)),

                                  TextButton(onPressed: (){

                                    _quantity.value--;
                                    int p = int.parse(item["price"].toString());
                                    _total.value = _quantity.value * p;// Decrement counter
                                  },
                                      child: const Icon(Icons.delete)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      ValueListenableBuilder(
                        valueListenable: _total,
                        builder: (context, value, child){
                          return Text(
                            'Total: $value',
                          );
                        },
                      ),

                      const Text("Payment: Cash",),
                    ],
                  ),
                  actions: [

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),

                    TextButton(
                      onPressed: () {
                        setState(() {

                          OrderHistory history = OrderHistory(
                            context,
                            FirebaseAuth.instance.currentUser!.uid,
                              item["key"],item["image"],item["name"],item["price"],"process",_quantity.value.toString(),_total.value.toString()
                          );
                          history.uploadData();
                          /////////////////////
                          OrderSender sender = OrderSender(context, FirebaseAuth.instance.currentUser!.uid,
                              item["key"],item["image"],item["name"],item["price"]
                              ,FirebaseAuth.instance.currentUser!.email!,"process",_quantity.value.toString(),_total.value.toString());
                          sender.uploadData();

                        });
                      },
                      child: const Text("Order Now"),
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
                            item["price"],
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
          );
        },
      ),
    );
  }
}