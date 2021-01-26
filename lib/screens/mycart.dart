import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe/models/shoe.dart';
import 'package:shoe/screens/address.dart';
import 'package:shoe/screens/loading.dart';
import 'package:shoe/screens/shoe_details.dart';

class MyCartScreen extends StatefulWidget {
  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  String _email;
  bool loading = true;
  List<Shoe> shoeList = [];
  int _totalCartItems = 0;

  Future<void> _getEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _email = pref.getString('email');
    await _getTotalItems(_email);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  _getTotalItems(String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('cart')
          .get()
          .then((value) {
        _totalCartItems = value.docs.length;
      });
    } catch (e) {
      _totalCartItems = 0;
    }
  }

  @override
  void initState() {
    _getEmail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          'Cart',
          style: TextStyle(color: Colors.black87, letterSpacing: 2),
        ),
      ),
      body: loading
          ? LoadingScreen()
          : Container(
              margin: EdgeInsets.only(bottom: height * 0.1),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_email)
                    .collection('cart')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: Container(
                        height: height * 0.001,
                        width: width * 0.25,
                        child: LinearProgressIndicator(),
                      ),
                    );
                  } else {
                    return _getCartProductsList(height, width, snapshot);
                  }
                },
              ),
            ),
      floatingActionButton:
          _totalCartItems > 0 ? _getFloatingActionButton(height, width) : null,
    );
  }

  _getFloatingActionButton(double height, double width) {
    return Ink(
      height: height * 0.065,
      width: width * 0.93,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_email)
                .collection('cart')
                .get()
                .then((QuerySnapshot snapshot) {
              for (int index = 0; index < snapshot.docs.length; index++) {
                Shoe shoe = new Shoe(
                  id: snapshot.docs[index].get('id'),
                  thumbUrl: snapshot.docs[index].get('image'),
                  brand: snapshot.docs[index].get('brand'),
                  name: snapshot.docs[index].get('name'),
                  title: snapshot.docs[index].get('title'),
                  color: snapshot.docs[index].get('color'),
                  gender: snapshot.docs[index].get('gender'),
                  price: snapshot.docs[index].get('price'),
                );
                shoeList.add(shoe);
              }
            });

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddressScreen(shoeList, _email)));
          } catch (e) {
            print('failed');
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddressScreen(shoeList, _email)));
        },
        child: Center(
          child: Text(
            'Checkout All',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  _getCartProductsList(
      double height, double width, AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: snapshot.data.docs.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Shoe shoe = new Shoe(
              id: snapshot.data.docs[index].get('id'),
              thumbUrl: snapshot.data.docs[index].get('image'),
              brand: snapshot.data.docs[index].get('brand'),
              name: snapshot.data.docs[index].get('name'),
              title: snapshot.data.docs[index].get('title'),
              color: snapshot.data.docs[index].get('color'),
              gender: snapshot.data.docs[index].get('gender'),
              price: snapshot.data.docs[index].get('price'),
            );
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShoeDetailsScreen(shoe)));
          },
          child: Container(
              padding: EdgeInsets.only(
                left: 20,
                top: 40,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data.docs[index].get('name'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: height * 0.025,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                snapshot.data.docs[index].get('brand'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: height * 0.020,
                                ),
                              ),
                              Text(
                                snapshot.data.docs[index].get('color'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: height * 0.020,
                                ),
                              ),
                              Text(
                                snapshot.data.docs[index].get('gender'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: height * 0.020,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "₹ " +
                                        (snapshot.data.docs[index]
                                                    .get('price') *
                                                73)
                                            .toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: height * 0.020,
                                    ),
                                  ),
                                  IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.trashAlt,
                                      color: Colors.black,
                                      size: height * 0.020,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(_email)
                                            .collection('cart')
                                            .doc(snapshot.data.docs[index].id)
                                            .delete();
                                        Fluttertoast.showToast(
                                          msg: "Item Deleted",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: "Delete operation failed",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(
                                snapshot.data.docs[index].get('image'),
                                height: height * 0.080,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
