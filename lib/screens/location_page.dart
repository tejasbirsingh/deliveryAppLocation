import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLocationPage extends StatefulWidget {
  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  Completer<GoogleMapController> _controller = Completer();
  MapType type;
  List loc = [];
  LatLng UserLatLong;
  double radius = 30000;
  LatLng center = LatLng(31.329442, 75.573180);
  var location = Location();
  LocationData userLocation;
  LatLng Displaylocation = LatLng(0, 0);
  LatLng UserFinal = LatLng(0, 0);
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  Address first, second;
  static final CameraPosition JalandharLocation = CameraPosition(
    target: LatLng(31.1471, 75.3412),
    zoom: 8,
  );
  List<LatLng> point = [];
  Set<Marker> markers;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    type = MapType.normal;
    markers = Set.from([]);
    getName(LatLng(0,0));
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void getCurrentPosition() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: Duration.microsecondsPerMillisecond);
   try{
     userLocation = await location.getLocation();
   } on Exception {
     userLocation = null ;
   }

    print("${userLocation.longitude}, ${userLocation.latitude}");
    UserLatLong = LatLng(userLocation.latitude, userLocation.longitude);
    _goToPos();
  }

  Future<void> _goToPos() async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(userLocation.latitude, userLocation.longitude),18));
    setState(() {
      markers.add(
        Marker(
            markerId: MarkerId('jalandhar'),
            position: UserLatLong,
            infoWindow: InfoWindow(title: 'Your location')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(
                Icons.location_on,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                setState(() {
                  getCurrentPosition();

                });
              },
            ),
          ],
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green.shade900, Colors.green.shade500])),
          ),
          centerTitle: true,
          title: Text(
            'Select your location',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              markers: markers,
              mapType: type,
              zoomGesturesEnabled: true,

              compassEnabled: true,
              buildingsEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,

              onCameraMove: ((_position) => _updatePosition(_position)),
              onTap: (position) {
                Marker mk1 = Marker(
                  markerId: MarkerId('jalandhar'),
                  position: position,
                );
                setState(() {
                  markers.add(mk1);
                });
              },
              initialCameraPosition: JalandharLocation,
              onMapCreated: (GoogleMapController controller) {

                _controller.complete(controller);
              },
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.zoom_in,
                        size: 40.0,
                        color: Colors.green.shade900,
                      ),
                      onPressed: () async {
                        (await _controller.future)
                            .animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.zoom_out,
                        size: 40.0,
                        color: Colors.green.shade900,
                      ),
                      onPressed: () async {
                        (await _controller.future)
                            .animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                    FloatingActionButton.extended(
                      heroTag: '1',
                      icon: Icon(Icons.add),
                      label: Text("Add location"),
                      onPressed: () {
                        if (markers.length < 1) {
                          print("Select a Location");
                        }
                        setState(() {
                          Displaylocation = markers.first.position;
                          double a = calculateDistance(
                              Displaylocation.latitude,
                              Displaylocation.longitude,
                              center.latitude,
                              center.longitude);
                          if (a < 40) {
                            UserFinal = Displaylocation;
                            saveAddress();
                            _posSuccess(context);
                          } else {
                            UserFinal = LatLng(0, 0);
                            _posNotSuccess(context);
                          }

                          print(UserFinal);
                          print(a);
                        });
                        getName(Displaylocation);
                      },
                    ),
                    FloatingActionButton(
                      heroTag: '2',
                      onPressed: () {
                        setState(() {
                          type = type == MapType.hybrid
                              ? MapType.normal
                              : MapType.hybrid;
                        });
                      },
                      child: Icon(Icons.map),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.grey.shade100,
                  child: Text(first == null ? "" : first.addressLine,
                  style: TextStyle(
                    color: Colors.black,
              fontWeight: FontWeight.bold
                  ),)),
            )

          ],
        ),
      ),
    );
  }

   void getName(LatLng) async {
    final coordinates =
        Coordinates(Displaylocation.latitude, Displaylocation.longitude);
    loc = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      first = loc.first;
    });
//    print(first.addressLine);

  }

  void _updatePosition(CameraPosition _position) {

    Marker marker = markers.firstWhere(
        (p) => p.markerId == MarkerId('jalandhar'),
        orElse: () => null);

    markers.remove(marker);
    markers.add(
      Marker(
          markerId: MarkerId('jalandhar'),
          position:
              LatLng(_position.target.latitude, _position.target.longitude),
          infoWindow: InfoWindow(

              title: first != null ? first.addressLine : "Your location")),

    );
getName(_position.target);
    setState(() {
      Displaylocation = _position.target;
    });
  }

  Future<void> _posNotSuccess(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not Successful'),
          content:
              const Text('Sorry, currently we are not delivering in this area'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _posSuccess(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: const Text('Your Location has been successfully added'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void saveAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

     prefs.setString('useraddress', first.addressLine.toString());


  }
}
