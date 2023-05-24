// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:patient/mainScreens/toggle_screen.dart';
import 'package:patient/splashScreen/splash_screen.dart';

import '../global/global.dart';

class MyDrawer extends StatefulWidget
{
  String? name;
  String? email;

  MyDrawer({this.name,this.email});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //drawer header
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                       const Icon(
                      Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 16,),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,

                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12,),

          //drawer body
          GestureDetector(
            onTap: ()
            {

            },
            child: const ListTile(
              leading: Icon(Icons.history,color: Colors.grey,),
              title: Text(
                "History",
                style: TextStyle(
                  color:Colors.white54,
                ),

              ),
            ),
          ),

          GestureDetector(
            onTap: ()
            {

            },
            child: const ListTile(
              leading: Icon(Icons.person,color: Colors.grey,),
              title: Text(
                "Visit Profile",
                style: TextStyle(
                  color:Colors.white54,
                ),

              ),
            ),
          ),

          GestureDetector(
            onTap: ()
            {

            },
            child: const ListTile(
              leading: Icon(Icons.info,color: Colors.grey,),
              title: Text(
                "About",
                style: TextStyle(
                  color:Colors.white54,
                ),

              ),
            ),
          ),

          GestureDetector(
            onTap: ()
            {
              fAuth.signOut();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c)=> ToggleScreenPage()),(Route<dynamic> route) => false);
            },
            child: const ListTile(
              leading: Icon(Icons.logout,color: Colors.grey,),
              title: Text(
                "Sign Out",
                style: TextStyle(
                  color:Colors.white54,
                ),

              ),
            ),
          ),

        ],
      ),
    );
  }
}
