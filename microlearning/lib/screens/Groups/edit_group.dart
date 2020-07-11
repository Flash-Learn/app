import 'package:flutter/material.dart';
import 'package:microlearning/Models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Utilities/Widgets/popUp.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/inputTextDecorations.dart';
import 'package:microlearning/screens/Groups/group.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';

class EditGroup extends StatefulWidget {
  final GroupData groupData;
  EditGroup({@required this.groupData});
  @override
  _EditGroupState createState() => _EditGroupState(groupData: groupData);
}

class _EditGroupState extends State<EditGroup> {
  final _formKeyDetails = GlobalKey<FormState>();
  final _formKeyUsers = GlobalKey<FormState>();
  String userToAdd;
  GroupData groupData;
  _EditGroupState({@required this.groupData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: (){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){return GroupList();}));
          },
        ),
        title: Text(
          "Edit Group",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Done'),
        icon: Icon(Icons.check),
        onPressed: () async {
          if(_formKeyDetails.currentState.validate()){  
            await updateGroupData(groupData);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
              return Group(groupID: groupData.groupID,);
            }));}
        },
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKeyDetails,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onChanged: (val) {
                      setState(() {
                        groupData.name = val;
                      });
                    },
                    validator: (String arg){
                      if(arg.length == 0){
                        return 'Group name must not be empty';
                      }else{
                        return null;
                      }
                    },
                    initialValue: groupData.name,
                    decoration: inputTextDecorations('Group Name')
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    onChanged: (val) {
                      setState(() {
                        groupData.description = val;
                      });
                    },
                    initialValue: groupData.description,
                     validator: (String arg){
                      if(arg.length == 0){
                        return 'Group discription must not be empty';
                      }else{
                        return null;
                      }
                    },
                    decoration: inputTextDecorations('Group Description')
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                      onPressed: (){
                        addUserDialog(context);
                      },
                      child: Text('Add a User'),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.group,),
                      Text('Group Memebers:',style: TextStyle(color: MyColorScheme.accent(), fontWeight: FontWeight.bold, fontSize: 18),)
                    ],
                  ),
                  SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView(
                        children: buildUserLists(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
  buildUserLists(){
    return groupData.users.map<Widget>((dynamic username){
      return StreamBuilder(
        stream: Firestore.instance
          .collection('user_data')
          .document(username)
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("loading");
          if (snapshot.data == null) return Container();
          dynamic mailID = snapshot.data["email"];
          dynamic name = snapshot.data["name"];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            child: ListTile(
              title: Text(name, style: TextStyle(fontSize: 18),),
              subtitle: Text(mailID),
            ),
          );
        }
      );
    }).toList();
  }



  addUserDialog(BuildContext context,){
    return showDialog(
      context: context,
      builder: (context){
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: _formKeyUsers,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          onChanged: (val) {
                            setState(() {
                              userToAdd = val;
                            });
                          },
                          decoration: inputTextDecorations('User Email ID'),
                          validator: (String arg){
                            if(arg.length == 0){
                              return 'Please enter an Email ID';
                            }else{
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            FlatButton(
                              child: Text('Cancel', style: TextStyle(color: Colors.red),),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              child: Center(
                                child: Text(
                                  'Add',
                                  style: TextStyle(color: MyColorScheme.accent()),
                                ),
                              ),
                              onPressed: () async {
                                bool alreadyThere = false;
                                bool doesExist = false;
                                bool didAdd = false;
                                if(_formKeyUsers.currentState.validate()){
                                    CollectionReference userCollection =
                                      Firestore.instance.collection('user_data');
                                  try {
                                    var user = await userCollection
                                        .where("email", isEqualTo: userToAdd)
                                        .getDocuments();
                                    user.documents.forEach((element) {
                                      doesExist = true;
                                      if (groupData.users.contains(element.documentID) ==
                                          false) {
                                        groupData.users.add(element.documentID);
                                      } else {
                                        alreadyThere = true;
                                      }
                                    });
                                  } catch (e) {
                                    print(e);
                                    return;
                                  }
                                  if (!doesExist) {
                                    popUp(context, "No such user!");
                                    return;
                                  } else if (alreadyThere) {
                                    popUp(context, "User already in group!");
                                    return;
                                  }
                                  try {
                                    await updateGroupData(groupData);
                                  } catch (e) {
                                    print(e);
                                    return;
                                  }
                                  if (!didAdd) {
                                    popUp(context, "Some error occured. Try again!");
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
      }
    );
  }
}
