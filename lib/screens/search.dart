import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shoe/models/searching_provider.dart';
import 'package:shoe/models/shoe.dart';
import 'package:shoe/screens/shoe_details.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool searching = true;
  String _query = '';
  List<Shoe> searchResults = [];
  Searching searchProvider;
  @override
  void initState() {
    searchProvider = Provider.of<Searching>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: _getAppBar(),
        body: _getShoeCardContainer(height, width, _query, searchResults));
  }

  Future<List<Shoe>> _getShoesResults(String query, List<Shoe> list) async {
    searchResults = [];
    var response = await http.get(
        'https://api.thesneakerdatabase.com/v1/sneakers?limit=50&name=$query');
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

  _getFutureBuilder(
      double height, double width, String query, List<Shoe> list) {
    return Consumer<Searching>(builder: (context, value, child) {
      return FutureBuilder(
        future: _getShoesResults(query, list),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (value.querySubmitted == true &&
              snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: Container(
                height: height * 0.001,
                width: width * 0.25,
                child: LinearProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Center(
                child: Text('No results found'),
              );
            }
            return GridView.count(
              crossAxisCount: 2,
              physics: BouncingScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              scrollDirection: Axis.vertical,
              childAspectRatio: 0.65,
              children: List.generate(snapshot.data.length, (index) {
                return _getShoeCard(height, width, snapshot.data[index]);
              }),
            );
          }
          return Center();
        },
      );
    });
  }

  _getShoeCardContainer(
      double height, double width, String brand, List<Shoe> list) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
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
        padding: EdgeInsets.all(15),
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
            Image.network(
              shoe.thumbUrl,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace stackTrace) {
                return Image.network(
                    'https://stockx-assets.imgix.net/media/New-Product-Placeholder-Default.jpg?fit=fill&bg=FFFFFF&w=140&h=100&auto=format,compress&trim=color&q=90&dpr=2&updated_at=0');
              },
            ),
            Flexible(
              child: Text(
                shoe.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: height * 0.021,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              shoe.gender,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: height * 0.019,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
            Text(
              "₹ " + ((shoe.price * 73).toString()),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: height * 0.019,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      title: searching
          ? Consumer<Searching>(builder: (context, value, child) {
              return TextFormField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onTap: () {
                  value.updateVarFalse();
                },
                onFieldSubmitted: (String s) {
                  _query = s;
                  FocusScope.of(context).unfocus();
                  value.updateVarTrue();
                },
                autofocus: true,
                style: TextStyle(
                  color: Colors.black,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                  border: InputBorder.none,
                ),
              );
            })
          : Text(
              'Search',
              style: TextStyle(letterSpacing: 1, color: Colors.black),
            ),
      actions: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.times,
            color: Colors.black,
            size: 18,
          ),
          onPressed: () {
            _controller.clear();
          },
        ),
      ],
    );
  }
}
