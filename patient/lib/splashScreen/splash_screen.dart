import 'dart:async';
import 'package:flutter/material.dart';
import 'package:patient/mainScreens/main_screen.dart';

import '../assistants/assistant_methods.dart';
import '../authentication/login_screen.dart';
import '../global/global.dart';


class MySplashScreen extends StatefulWidget 
{
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> 
{
  startTimer()
  {
    fAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;

    Timer(const Duration(seconds: 0), () async
    {

      if(fAuth.currentUser != null)
        {
          currentFirebaseUser = fAuth.currentUser;
          Navigator.push(context, MaterialPageRoute(builder: (c)=>  MainScreen()));
        }
      else
        {
          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
        }

    });
  }
  
  @override
  void initState() 
  {
    super.initState();
     
    startTimer();
  }
  
  @override
  Widget build(BuildContext context) 
  {
    
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/patient_logo.png"),

              const SizedBox(height: 10,),

              const Text(
                "Patient",
                    style: TextStyle(
                  fontSize: 30,
                color: Colors.red,
                fontWeight: FontWeight.bold
              )
              )
            ],
          ),
        ),
      ),
    );
  }
}
