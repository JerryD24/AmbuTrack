import 'dart:async';
import 'package:patient/authority/lib/mainScreens/main_screen.dart';
import 'package:flutter/material.dart';
import '../authentication/login_screen.dart';
import '../global/global.dart';


class AuthoritySplashScreen extends StatefulWidget
{
  const AuthoritySplashScreen({Key? key}) : super(key: key);

  @override
  State<AuthoritySplashScreen> createState() => _AuthoritySplashScreenState();
}

class _AuthoritySplashScreenState extends State<AuthoritySplashScreen>
{
  startTimer()
  {
    Timer(const Duration(microseconds: 0), () async
    {

      if(fAuth.currentUser != null)
        {
          fAuth .signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
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
              Image.asset("images/authority_app.jpg"),

              const SizedBox(height: 10,),

              const Text(
                "Authority",
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
