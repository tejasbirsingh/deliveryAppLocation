import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/screens/detailPage.dart';
import 'package:grocery_app/screens/location_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String address;

  void getAddress() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();

    setState(() {
      address = _preferences.getString('useraddress');
    });

    print(address);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          'Food Delivery',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green.shade900, Colors.green.shade500])),
        ),
      ),
      backgroundColor: Color(0xFFFCFAF8),
      body: Stack(
        children: <Widget>[
          ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            children: <Widget>[
              SizedBox(height: 15.0),
              Container(
                child: Wrap(
                  children: [
                    address != null
                        ? Text(address)
                        : Text('Select your location'),
                    IconButton(
                      icon: Icon(
                        Icons.location_on,
                        size: 30.0,
                        color: Colors.green,
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectLocationPage())),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                  width: MediaQuery.of(context).size.width - 30.0,
                  height: MediaQuery.of(context).size.height - 50.0,
                  child: GridView.count(
                    crossAxisCount: 2,
                    primary: false,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 0.8,
                    children: <Widget>[
                      _itemCard('Cheese Burger', 'Rs 99', 'images/1.png', false,
                          false, context),
                      _itemCard('Fried Fish', 'Rs 200', 'images/2.png', true,
                          false, context),
                      _itemCard('Panner fried', 'Rs 150', 'images/3.png', false,
                          true, context),
                      _itemCard('Family pack', 'Rs 300', 'images/4.png', false,
                          false, context),

                    ],
                  )),
              SizedBox(height: 15.0)
            ],
          ),

        ],
      ),
    );
  }

  Widget _itemCard(String name, String price, String imgPath, bool added,
      bool isFavorite, context) {
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => details_page(
                      assetPath: imgPath,
                      price:price,
                      name: name
                  )));
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3.0,
                          blurRadius: 5.0)
                    ],
                    color: Colors.white),
                child: Column(children: [
                  Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            isFavorite
                                ? Icon(Icons.favorite, color: Colors.green)
                                : Icon(Icons.favorite_border,
                                    color: Colors.green)
                          ])),
                  Container(
                      height: 75.0,
                      width: 75.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(imgPath), fit: BoxFit.fill))),
                  SizedBox(height: 7.0),
                  Text(price,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Varela',
                          fontSize: 14.0)),
                  Text(name,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Varela',
                          fontSize: 14.0)),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(color: Color(0xFFEBEBEB), height: 1.0)),
                  Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (!added) ...[
                              Icon(Icons.shopping_basket,
                                  color: Color(0xFFD17E50), size: 12.0),
                              Text('Add to cart',
                                  style: TextStyle(
                                      fontFamily: 'Varela',
                                      color: Color(0xFFD17E50),
                                      fontSize: 15.0))
                            ],
                            if (added) ...[
                              Icon(Icons.remove_circle_outline,
                                  color: Color(0xFFD17E50), size: 12.0),
                              Text('3',
                                  style: TextStyle(
                                      fontFamily: 'Varela',
                                      color: Color(0xFFD17E50),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0)),
                              Icon(Icons.add_circle_outline,
                                  color: Color(0xFFD17E50), size: 12.0),
                            ]
                          ]))
                ]))));
  }
}
