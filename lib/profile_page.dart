import 'package:flutter/material.dart';
import 'package:outshade_user_app/user.dart';

//This is the profile page of the user which shows user's id, name, age and gender
class ProfilePage extends StatelessWidget {
  final User user;
  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile Page"),
        ),
        body: Column(
          children: [
            Card(
                child: ListTile(
                    leading: const Padding(
                        padding: EdgeInsets.only(top: 4), child: Text("ID:")),
                    title: Text(user.id))),
            Card(
                child: ListTile(
                    leading: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text("Name: ")),
                    title: Text(user.name))),
            Card(
                child: ListTile(
                    leading: const Padding(
                        padding: EdgeInsets.only(top: 4), child: Text("Age: ")),
                    title: Text(user.age.toString()))),
            Card(
                child: ListTile(
                    leading: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text("Gender: ")),
                    title: Text(user.gender)))
          ],
        ));
  }
}
