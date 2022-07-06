import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:outshade_user_app/profile_page.dart';
import 'package:outshade_user_app/user.dart';

Future<void> main() async {
  // Initializing Hive Box for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleLoginApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SimpleLogin'),
    );
  }
}

// This is the main state widget of the app which shows the list of users
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<User>> usersFuture; // stores the list of users
  late Box box; // Box for hive database local storage
  late TextEditingController ageController,
      genderController; // Controllers for age and gender input fileds

  final genders = ["Male", "Female", "Others"];

  @override
  void initState() {
    super.initState();
    box = Hive.box<User>('box');
    usersFuture = getUsers(context);
    ageController = TextEditingController();
    genderController = TextEditingController();
  }

  @override
  void dispose() {
    ageController.dispose();
    genderController.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: FutureBuilder<List<User>>(
                future: usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final users = snapshot.data!;
                    return buildUsers(users);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })));
  }

  // ********** Widgets *************** \\

  // Builds a listview of the users
  Widget buildUsers(List<User> users) => ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        String sign;
        if (box.get(user.id) != null) {
          sign = 'Sign Out';
        } else {
          sign = 'Sign In';
        }
        return Card(
            child: ListTile(
                onTap: () => openProfilePage(context, user),
                title: Text(user.name),
                leading: Text(user.id),
                trailing: OutlinedButton(
                    child: Text(sign),
                    onPressed: () => signInOut(context, user))));
      });

  // Opens a dialogue box for the user to enter age and gender
  openDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add your Age and Gender"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Text("Age:      "),
                SizedBox(
                    width: 200,
                    child: TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(hintText: "Enter Age")))
              ]),
              Row(children: [
                const Text("Gender: "),
                SizedBox(
                    width: 200,
                    child: TextField(
                        controller: genderController,
                        decoration:
                            const InputDecoration(hintText: "Enter Gender")))
              ])
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => submit(user, context),
                child: const Text("Submit"))
          ],
        );
      },
    );
  }

  // *********** Helper Functions ************* \\
  // Below is the list of the required functions which are used to do the given tasks for the app

  // Gets user data from UserData.json file stored in the assets folder and returns a list of User
  static Future<List<User>> getUsers(BuildContext context) async {
    final assetBundle = DefaultAssetBundle.of(context);
    final data = await assetBundle.loadString('assets/UserData.json');
    final body = json.decode(data);
    return body.map<User>(User.fromJson).toList();
  }

  // Adds Gender and Age to user and stores it in the hive database
  void submit(User user, BuildContext context) {
    if (genderController.text == '') {
      return;
    }
    User newUser = User(
        id: user.id,
        name: user.name,
        age: int.parse(ageController.text),
        gender: genderController.text);

    // Add new User to box
    box.put(newUser.id, newUser);

    // Close the dialogue box
    Navigator.of(context).pop();

    // Clear the input fields
    setState(() {
      ageController.clear();
      genderController.clear();
    });

    // Navigate to the profile page
    openProfilePage(context, newUser);
  }

  // Navigates to Profile Page if the user is registered in the hive database else open the dialogue box
  void openProfilePage(BuildContext context, User user) {
    if (box.get(user.id) != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(user: box.get(user.id)!)),
      );
    } else {
      // Ask for age and gender from user
      openDialog(context, user);
    }
  }

  // Sign's out and deletes a user from hive database if registered else opens a dialogue box for registering user
  void signInOut(BuildContext context, User user) {
    if (box.get(user.id) != null) {
      box.delete(user.id);
      setState(() {});
    } else {
      openDialog(context, user);
    }
  }
}
