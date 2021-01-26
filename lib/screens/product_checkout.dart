import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe/models/address_model.dart';
import 'package:shoe/models/homepage_provider.dart';
import 'package:shoe/models/shoe.dart';
import 'package:shoe/screens/address.dart';
import 'package:shoe/screens/homepage.dart';
import 'package:shoe/screens/loading.dart';

class CheckoutScreen extends StatefulWidget {
  final Address address;
  final List<Shoe> shoe;
  CheckoutScreen(this.address, this.shoe);
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _groupValue = -1;
  bool loading = false;
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
          'Checkout',
          style: TextStyle(color: Colors.black87, letterSpacing: 2),
        ),
      ),
      body: loading
          ? LoadingScreen()
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getAddressContainer(height, width),
                  _getCartProductsList(height, width),
                  _getBillingDetails(height, width),
                  _getPaymentOptions(height, width),
                  Padding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            ),
      floatingActionButton: _getFloatingActionButton(height, width),
    );
  }

  _getPaymentOptions(double height, double width) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: Divider(
              height: 1,
              color: Colors.grey,
            ),
          ),
          Text(
            'Payment Options',
            style: TextStyle(
              color: Colors.black,
              fontSize: height * 0.020,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: Divider(
              height: 1,
              color: Colors.grey,
            ),
          ),
          _myRadioButton(
            title: "Pay Online",
            value: 0,
            onChanged: (newValue) => setState(() => _groupValue = newValue),
          ),
          _myRadioButton(
            title: "Cash On Delivery",
            value: 1,
            onChanged: (newValue) => setState(() => _groupValue = newValue),
          ),
        ],
      ),
    );
  }

  _getFloatingActionButton(double height, double width) {
    return Container(
      height: height * 0.065,
      width: width * 0.93,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (_groupValue == -1) {
            Fluttertoast.showToast(
              msg: "Please select payment option",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          } else if (_groupValue == 1) {
            _placeOrder();
          } else if (_groupValue == 0) {
            Fluttertoast.showToast(
              msg: "Online payment option is not available yet.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
        },
        child: Center(
          child: Text(
            'Place Order',
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

  _getBillingDetails(double height, double width) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              color: Colors.black,
              fontSize: height * 0.020,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: Divider(
              height: 1,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height * 0.020,
                  ),
                ),
                Text(
                  "₹ " + (_getTotalPrice() * 73).toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height * 0.020,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Charges',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height * 0.020,
                  ),
                ),
                Text(
                  "Free",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height * 0.020,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount Payable',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height * 0.020,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "₹ " + (_getTotalPrice() * 73).toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height * 0.020,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getCartProductsList(double height, double width) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.shoe.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            margin: EdgeInsets.only(top: 10, bottom: 10),
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
                              widget.shoe[index].name,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: height * 0.026,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              widget.shoe[index].brand,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: height * 0.020,
                              ),
                            ),
                            Text(
                              widget.shoe[index].color.split('/').last,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: height * 0.020,
                              ),
                            ),
                            Text(
                              widget.shoe[index].gender,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: height * 0.020,
                              ),
                            ),
                            Text(
                              (widget.shoe[index].price != null)
                                  ? "₹ " +
                                      ((widget.shoe[index].price * 73)
                                          .toString())
                                  : "₹ NaN",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: height * 0.020,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              (widget.shoe[index].thumbUrl == null)
                                  ? 'https://app.swaggerhub.com/img/swaggerhub-logo.svg'
                                  : widget.shoe[index].thumbUrl,
                              height: height * 0.090,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                )
              ],
            ));
      },
    );
  }

  _getAddressContainer(double height, double width) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.address.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: height * 0.025,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.address.address,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height * 0.020,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.address.phone,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: height * 0.020,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Ink(
                  height: height * 0.060,
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddressScreen(
                                  widget.shoe, pref.getString('email'))));
                    },
                    child: Center(
                      child: Text(
                        'Change or Add Address',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: height * 0.018,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getTotalPrice() {
    int total = 0;
    for (int i = 0; i < widget.shoe.length; i++) {
      total += widget.shoe[i].price;
    }
    return total;
  }

  Widget _myRadioButton({String title, int value, Function onChanged}) {
    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
    );
  }

  _placeOrder() async {
    try {
      if (mounted) {
        setState(() {
          loading = true;
        });
      }
      SharedPreferences pref = await SharedPreferences.getInstance();
      CollectionReference collection = FirebaseFirestore.instance
          .collection('users')
          .doc(pref.getString('email'))
          .collection('orders');

      for (int i = 0; i < widget.shoe.length; i++) {
        collection.add({
          'id': widget.shoe[i].id,
          'productTitle': widget.shoe[i].title,
          'productName': widget.shoe[i].name,
          'brand': widget.shoe[i].brand,
          'color': widget.shoe[i].color,
          'price': widget.shoe[i].price,
          'image': widget.shoe[i].thumbUrl,
          'gender': widget.shoe[i].gender,
          'timestamp': DateTime.now(),
          'payment': _groupValue,
          'customername': widget.address.name,
          'address': widget.address.address,
          'phone': widget.address.phone,
        });
      }
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      _showOrderStatusDialoge();
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      Fluttertoast.showToast(
        msg: "Order failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  _showOrderStatusDialoge() {
    return showGeneralDialog(
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: Container(
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.check,
                        color: Colors.black,
                        size: 30,
                      ),
                      Text(
                        'Your order is placed successfully.\n Thank you for shopping.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 1,
                          color: Colors.black,
                          fontFamily: 'OpenSans',
                          fontSize: 16,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Ink(
                          height: 40,
                          width: MediaQuery.of(context).size.width - 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider(
                                            create: (context) =>
                                                HomepageProvider(),
                                            child: HomePageScreen(),
                                          )),
                                  (route) => false);
                            },
                            child: Center(
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'OpenSans',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        context: context,
        transitionDuration: Duration(milliseconds: 300),
        barrierDismissible: false,
        barrierLabel: '',
        pageBuilder: (context, animation1, animation2) {});
  }
}
