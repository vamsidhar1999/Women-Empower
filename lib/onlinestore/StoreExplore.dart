import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:streecare/Components/styles.dart';
import 'package:streecare/Meetups/MeetRegistered.dart';
import 'package:streecare/onlinestore/StoreRegistered.dart';

class StoreExplore extends StatefulWidget {
  @override
  _StoreExploreState createState() => _StoreExploreState();
}

class _StoreExploreState extends State<StoreExplore> {
  Firestore firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  List<bool> isSelected = [true, false];

  bool isSearched = false;
  bool searchBar = false;
  var status;
  var Documents;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  double latitude, longitude;
  void getUser() async {
    _user = await _auth.currentUser();
  }

  Geoflutterfire geo = Geoflutterfire();
  StreamSubscription subscription;
  _getdata() async {
    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      latitude = position.latitude;
      longitude = position.longitude;
      print(latitude);
      print(longitude);
    }).catchError((e) {
      print(e);
    });
    // Create a geoFirePoint
    GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);

// get the collection reference or query
    var collectionReference =
        await Firestore.instance.collection('OnlineStore').getDocuments();

    double radius = 1000;
    String field = 'location';
    List a = collectionReference.documents.toList();
    _updateMarkers(a);
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    setState(() {
      Documents = documentList;
    });
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint pos = document.data['location']['geopoint'];
      double distance = document.data['distance'];
      print(document);
      print(pos);
      print(distance);
      print(document.data['title']);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    status = _getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xfffe82a7),
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        title: searchBar
            ? TextField(
                decoration: kSearchFieldDecor,
                style: kInfoText.copyWith(color: Colors.white),
                cursorColor: Colors.white,
              )
            : Center(
                child: Text(
                  'Store',
                  style: kGenderSelected,
                ),
              ),
        leading: GestureDetector(
          onTap: () {
            //TODO: Back Functionality
            setState(() {
              searchBar = false;
            });
            // if(isSearched)
            // {
            //   setState(() {
            //     screens[1] = BoardPage(searchedQuery: '',);
            //   });
            // }
            // else
            // {
            //
            // }
          },
          child: Icon(
            Icons.arrow_back,
            size: 30,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  searchBar = !searchBar;
                });
              },
              child: Icon(
                Icons.search,
                size: 30,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          Flexible(
            child: FutureBuilder(
                future: status,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    List<Widget> usersList = [];
                    final docs = Documents;
                    Documents.forEach((DocumentSnapshot document) {
                      print(document.data);
                      var name = document.data['name'];
                      var image = document.data['image'];
                      var price = document.data['price'];
                      var contact = document.data['contact'];
                      var description = document.data['description'];
                      print(name);
                      if (true) {
                        usersList.add(StoreExploreView(
                            name: name,
                            price: price,
                            contact: contact,
                            image: image,
                            description: description));
                        //     PatientView(
                        //       name: name, age: age, bloodGroup: bloodGroup, gender: genders[gender], lastTested: lastTested,
                        //       relation: relation, hospital: hospital, contact: contact, city: city, state: state, pincode: pincode,
                        //       bp: bp, diabetes: diabetes, preMedical: preMedical, extraDetails: moreDetails, neededDate: '19/05/2020',
                        //
                        //     )
                        //);
                      }
                    });
                    if (usersList.isEmpty) {
                      return Container(
                        child: Center(
                          child: Text(
                            '???? No Records Found',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return ListView(
                      children: usersList,
                    );
                  }
                  return Container();
                }),
          )
        ],
      )),
    );
  }
}
