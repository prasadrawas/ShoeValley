import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe/models/shoe.dart';
import 'package:shoe/screens/address.dart';
import 'package:shoe/screens/mycart.dart';
import 'package:shoe/screens/profile.dart';

class ShoeDetailsScreen extends StatefulWidget {
  final Shoe shoe;
  ShoeDetailsScreen(this.shoe);
  @override
  _ShoeDetailsScreenState createState() => _ShoeDetailsScreenState();
}

class _ShoeDetailsScreenState extends State<ShoeDetailsScreen> {
  List<int> size = [10, 12, 14, 16, 18, 20, 22];
  int selectedSize = 0;
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
          'ORDER',
          style: TextStyle(color: Colors.black87, letterSpacing: 2),
        ),
        actions: [
          IconButton(
              icon: FaIcon(
                FontAwesomeIcons.shoppingBag,
                size: height * 0.030,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyCartScreen()));
              }),
          IconButton(
              icon: FaIcon(
                FontAwesomeIcons.userCircle,
                size: height * 0.030,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              }),
        ],
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  height: height * 0.35,
                  child: Center(child: Image.network(widget.shoe.thumbUrl)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    widget.shoe.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: height * 0.030,
                    ),
                  ),
                ),
                Text(
                  "₹ " + ((widget.shoe.price * 73).toString()),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff453f3f),
                    fontWeight: FontWeight.bold,
                    fontSize: height * 0.030,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.shoe.color,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff453f3f),
                    fontWeight: FontWeight.bold,
                    fontSize: height * 0.020,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.shoe.gender,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff453f3f),
                    fontWeight: FontWeight.bold,
                    fontSize: height * 0.020,
                  ),
                ),
                SizedBox(
                  height: height * 0.030,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Size',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: height * 0.020),
                    ),
                    Text(
                      'Size Chart',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: height * 0.018),
                    ),
                  ],
                ),
                _getSizeChart(context, height, width),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Ink(
                height: height * 0.065,
                width: width * 0.45,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _addToCart();
                  },
                  child: Center(
                      child: Text(
                    'Add to cart',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ),
              Ink(
                height: height * 0.065,
                width: width * 0.45,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddressScreen(
                                <Shoe>[widget.shoe], pref.getString('email'))));
                  },
                  child: Center(
                    child: Text(
                      'Buy now',
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getSizeChart(BuildContext context, double height, double width) {
    return Container(
      margin: EdgeInsets.only(top: height * 0.020, bottom: height * 0.020),
      height: height * 0.08,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 10),
            height: height * 0.08,
            width: height * 0.08,
            decoration: BoxDecoration(
              color: selectedSize == index ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: InkWell(
              onTap: () {
                if (mounted) {
                  setState(() {
                    selectedSize = index;
                  });
                }
              },
              child: Center(
                child: Text(
                  size[index].toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          selectedSize == index ? Colors.white : Colors.black),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _addToCart() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(pref.getString('email'))
          .collection('cart')
          .doc(widget.shoe.name + size[selectedSize].toString())
          .set({
        'id': widget.shoe.id,
        'image': widget.shoe.thumbUrl,
        'name': widget.shoe.name,
        'title': widget.shoe.title,
        'price': widget.shoe.price,
        'gender': widget.shoe.gender,
        'color': widget.shoe.color,
        'size': size[selectedSize],
        'brand': widget.shoe.brand,
      });
      Fluttertoast.showToast(
        msg: "Added to Cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Can't Add",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
