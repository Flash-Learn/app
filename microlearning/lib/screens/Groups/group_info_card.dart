import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

Widget groupInfoCard(String groupID) {
  return StreamBuilder(
      stream:
          Firestore.instance.collection('groups').document(groupID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
              child: SizedBox(
            child: CircularProgressIndicator(),
            width: 30,
            height: 30,
          ));
        }

        dynamic group = snapshot.data;
        return Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Container(
            height: 110,
            width: MediaQuery.of(context).size.width,
            child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                color: MyColorScheme.uno(),
                shadowColor: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 35, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              group["name"],
                              style: TextStyle(
                                color: MyColorScheme.cinco(),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              group["description"],
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ));
      });
}
