import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shoe/data.dart';
import 'package:shoe/models/homepage_provider.dart';
import 'package:shoe/models/searching_provider.dart';
import 'dart:convert';
import 'package:shoe/models/shoe.dart';
import 'package:shoe/screens/mycart.dart';
import 'package:shoe/screens/profile.dart';
import 'package:shoe/screens/search.dart';
import 'package:shoe/screens/shoe_details.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  Future<List<Shoe>> _getShoeDataByBrand(String brand, List<Shoe> list) async {
    if (list.isNotEmpty) return list;
    var response = await http.get(
        'https://api.thesneakerdatabase.com/v1/sneakers?limit=50&brand=$brand');
    var jsonData = json.decode(response.body);

    for (var json in jsonData['results']) {
      Shoe record = new Shoe(
        id: json['id'],
        brand: json['brand'],
        color: json['colorway'],
        gender: json['gender'],
        name: json['shoe'],
        title: json['title'],
        year: json['year'].toString(),
        thumbUrl: json['media']['thumbUrl'],
        price: (json['retailPrice'] == 0 || json['retailPrice'] == null)
            ? 100
            : json['retailPrice'],
      );
      list.add(record);
    }

    return list;
  }

  List<List<Shoe>> list = [];

  List<String> brands = [
    "Nike",
    "Puma",
    "Adidas",
    "Under Armour",
    "Reebok",
    "Jordan",
    "Asics",
    "Converse",
    "New Balance",
    "Vans",
    "Yeezy",
  ];
  HomepageProvider homepageProvider;
  @override
  void initState() {
    homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
    list.add(nike);
    list.add(puma);
    list.add(adidas);
    list.add(under);
    list.add(reebok);
    list.add(jordan);
    list.add(asics);
    list.add(converse);
    list.add(newbalance);
    list.add(vans);
    list.add(yeezy);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getHeader(height, width),
              _getBrandContainer(height),
              Expanded(
                child: Consumer<HomepageProvider>(
                    builder: (context, value, child) {
                  return _getShoeCardContainer(height, width,
                      brands[value.selectedIndex], list[value.selectedIndex]);
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  _getBrandContainer(double height) {
    return Container(
      height: height * 0.05,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: brands.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Consumer<HomepageProvider>(builder: (context, value, child) {
            return Ink(
              decoration: BoxDecoration(
                color:
                    value.selectedIndex == index ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: () {
                  value.updateIndex(index);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Center(
                    child: Consumer<HomepageProvider>(
                        builder: (context, value, child) {
                      return Text(
                        brands[index],
                        style: TextStyle(
                          color: value.selectedIndex == index
                              ? Colors.white
                              : Colors.black,
                          fontSize: height * 0.022,
                          letterSpacing: 1,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  _getFutureBuilder(
      double height, double width, String brand, List<Shoe> list) {
    return FutureBuilder(
      future: _getShoeDataByBrand(brand, list),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Container(
              height: height * 0.001,
              width: width * 0.25,
              child: LinearProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return GridView.count(
            crossAxisCount: 2,
            physics: BouncingScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            scrollDirection: Axis.vertical,
            childAspectRatio: 0.70,
            children: List.generate(snapshot.data.length, (index) {
              return _getShoeCard(height, width, snapshot.data[index]);
            }),
          );
        }
        return Center();
      },
    );
  }

  _getShoeCardContainer(
      double height, double width, String brand, List<Shoe> list) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _getFutureBuilder(height, width, brand, list),
          ),
        ],
      ),
    );
  }

  _getShoeCard(double height, double width, Shoe shoe) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ShoeDetailsScreen(shoe)));
      },
      child: Container(
        height: height * 0.35,
        width: width * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey)],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Image.network(
                    (shoe.thumbUrl == null)
                        ? 'https://app.swaggerhub.com/img/swaggerhub-logo.svg'
                        : shoe.thumbUrl,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        shoe.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: height * 0.020,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      shoe.gender,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: height * 0.017,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1),
                    ),
                    Text(
                      "₹ " + ((shoe.price * 73).toString()),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: height * 0.017,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _getHeader(double height, double width) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      margin: EdgeInsets.only(top: height * 0.013, bottom: height * 0.050),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Our',
                style: TextStyle(
                  fontSize: height * 0.035,
                  color: Colors.black87,
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.shoppingBag,
                        size: height * 0.030,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyCartScreen()));
                      }),
                  IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.userCircle,
                        size: height * 0.030,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()));
                      }),
                ],
              )
            ],
          ),
          Text(
            'Products',
            style: TextStyle(
              fontSize: height * 0.035,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(
            height: height * 0.016,
          ),
          Center(
            child: Container(
              height: height * 0.070,
              width: width * 0.95,
              decoration: BoxDecoration(
                color: Color(0xFFebe8e8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => Searching(),
                          child: SearchScreen(),
                        ),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search',
                        style: TextStyle(
                          fontSize: height * 0.019,
                          letterSpacing: 1,
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.search,
                        size: height * 0.019,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
