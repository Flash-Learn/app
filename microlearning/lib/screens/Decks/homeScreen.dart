import 'package:flutter/material.dart';
import 'package:microlearning/Models/notification_plugin.dart';
import 'package:microlearning/Utilities/Widgets/deckInfoCard.dart';
import 'package:microlearning/Utilities/Widgets/deckReorderList.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/Utilities/constants/transitions.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';
import 'package:microlearning/screens/Groups/group.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';
import 'package:microlearning/screens/authentication/init_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> userGroupIDs;
  List<dynamic> userDeckIDs;
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;

  @override
  void initState(){
    super.initState();
    controller.addListener((){
      setState(() {
        closeTopContainer = controller.offset > 100;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Color.fromRGBO(196, 208, 223, 0),
        centerTitle: true,
        title: Text(
          'Flash Learn',
          style: TextStyle(
              color: MyColorScheme.uno(),
              letterSpacing: 2,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20,20,20,0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(SizeRoute(page: GroupList()));
              },
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Deck name',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(child: Divider(color: Colors.black, )),
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: closeTopContainer ? 0 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: size.width,
                height: closeTopContainer?0:size.height*0.15,
                child: getGroupsAsCard(),
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(SizeRoute(page: MyDecks()));
              },
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Decks',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(padding: EdgeInsets.symmetric(vertical: 2),child: Divider(color: Colors.black, )),
            getDecksAsCards(),  
          ],
        ),
      ),
    );
  }
  getGroupsAsCard(){
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading');
        }
        final String uid = snapshot.data.getString('uid');
        return StreamBuilder(
          stream: Firestore.instance
              .collection('user_data')
              .document(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Loading');
            }
            if (snapshot.data == null) {
              return Container();
            }
            try {
              userGroupIDs = snapshot.data["groups"];
            } catch (e) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return GetUserInfo();
              }));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: horizontalScrollCards(),
                ),
            );
          },
        );
      },
    );
  }
  horizontalScrollCards(){
    return userGroupIDs.map<Widget>((dynamic groupID){
      return StreamBuilder(
        stream: Firestore.instance.collection('groups').document(groupID).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Loading(size: 20);
          }
          dynamic group = snapshot.data;
          return GestureDetector(
            onTap: (){
              Navigator.of(context).push( SizeRoute(page: Group(groupID: groupID,)));
            },
            child: FittedBox(
              fit: BoxFit.fill,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                margin: EdgeInsets.only(right: 5),
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(color: MyColorScheme.accentLight(),borderRadius: BorderRadius.all(Radius.circular(20.0)), boxShadow: [BoxShadow(color: Colors.black26,)]),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(group["name"],style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
                        SizedBox(height: 20,),
                        Text(group["description"], style: TextStyle(color: MyColorScheme.uno(), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
  getDecksAsCards(){
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: Loading(
              size: 50,
            ),
          );
        final String userID = snapshot.data.getString('uid');
        return StreamBuilder(
            stream: Firestore.instance
                .collection('user_data')
                .document(userID)
                .snapshots(),
            builder: (context, snapshot) {
              print(userID);
              if (!snapshot.hasData)
                return Center(
                  child: Loading(
                    size: 50,
                  ),
                );
              if (snapshot.data == null) return Container();
              try {
                userDeckIDs = snapshot.data["decks"];
              } catch (e) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return GetUserInfo();
                }));
              }
              return Expanded(
                child: ListView(
                  controller: controller,
                  physics: BouncingScrollPhysics(),
                  children: verticalScrollCards(),
                ),
              );
            });
      });
  }
  verticalScrollCards(){
    List<Widget> children = userDeckIDs.map<Widget>((dynamic deckID){
      return GestureDetector(
        onTap: (){
          Navigator.of(context).push(SizeRoute(page: ViewDeck(deckID: deckID,)));
        },
        child: deckInfoCard(deckID)
      );
    }).toList();
    children.add(Container(height: MediaQuery.of(context).size.height * 0.5,));
    return children;
  }
}