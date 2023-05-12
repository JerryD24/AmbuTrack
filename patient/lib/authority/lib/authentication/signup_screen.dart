
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:patient/authority/lib/splashScreen/authority_splash_screen.dart';
import '../../../widgets/progress_dialog.dart';
import '../global/global.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
{
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController employeeIdTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm()
  {
    if(nameTextEditingController.text.length < 3)
      {
        Fluttertoast.showToast(msg: "Name must be least 3 characters.");
      }
    else if(!emailTextEditingController.text.contains("@"))
      {
        Fluttertoast.showToast(msg: "Email is not Valid.");
      }
    else if(phoneTextEditingController.text.isEmpty)
      {
        Fluttertoast.showToast(msg: "Phone Number is Mandatory.");
      }
    else if(employeeIdTextEditingController.text.isEmpty )
      {
        Fluttertoast.showToast(msg: "Employee Id is Mandatory.");
      }
    else if(employeeIdTextEditingController.text.length < 5 )
    {
      Fluttertoast.showToast(msg: "Employee Id must be greater than 5 characters.");
    }
    else if(passwordTextEditingController.text.length < 8)
      {
        Fluttertoast.showToast(msg: "Password must be least 8 characters.");
      }
    else
      {
        saveAuthorityInfoNow();
      }

  }

  saveAuthorityInfoNow() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c)
        {
          return ProgressDialog(message: "Processing. Please Wait...",);
        }
    );

    final User? firebaseUser = (
    await fAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ).catchError((msg){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: $msg");
    })
    ).user;

    if(firebaseUser != null)
      {
        Map authorityMap =
            {
              "id":firebaseUser.uid,
              "name": nameTextEditingController.text.trim(),
              "phone": phoneTextEditingController.text.trim(),
              "emp_id": employeeIdTextEditingController.text.trim(),
              "email": emailTextEditingController.text.trim(),
            };

        DatabaseReference authorityRef = FirebaseDatabase.instance.ref().child("Authority");
        authorityRef.child(firebaseUser.uid).set(authorityMap);

        currentFirebaseUser =firebaseUser;
        Fluttertoast.showToast(msg: "Account has been created.");
        Navigator.push(context, MaterialPageRoute(builder: (c)=> AuthoritySplashScreen()));
      }
    else
      {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Account has not been created.");
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              const SizedBox(height: 10,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/authority_app.jpg"),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Register as a Authority",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextField(
                controller: nameTextEditingController,
                style:const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Name",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: employeeIdTextEditingController,
                style:const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Employee Id",
                  hintText: "Employee Id",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style:const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style:const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Phone",
                  hintText: "Phone",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style:const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: ()
                {
                  validateForm();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child: const Text(
                    "Create Account",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        )


                ),
              ),

              TextButton(
                child: const Text(
                  "Already have an Account? Login Here",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> const LoginScreen()));
                },
              ),

            ],
          ),
        ),
      ),

    );
  }
}
