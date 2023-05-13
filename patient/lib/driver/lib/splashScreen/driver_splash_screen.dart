import 'dart:async';

import 'package:patient/driver/lib/mainScreens/main_screen.dart';
import 'package:flutter/material.dart';

import '../authentication/login_screen.dart';
import '../global/global.dart';

class DriverSplashScreen extends StatefulWidget
{
  const DriverSplashScreen({Key? key}) : super(key: key);

  @override
  State<DriverSplashScreen> createState() => _DriverSplashScreenState();
}

class _DriverSplashScreenState extends State<DriverSplashScreen>
{
  startTimer()
  {
    Timer(const Duration(seconds: 1), () async
    {
      // print(fAuth.currentUser.toString());
      if(fAuth.currentUser != null)
        {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c)=> const MainScreen()),(Route<dynamic> route) => false);
        }
      else
        {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
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
              Image.asset("images/driver_logo.png"),

              const SizedBox(height: 10,),

              const Text(
                "Driver",
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
