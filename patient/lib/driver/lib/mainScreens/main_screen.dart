
// ignore_for_file: prefer_const_constructors

import 'package:patient/driver/lib/tabPages/home_tab.dart';
import 'package:patient/driver/lib/tabPages/profile_tab.dart';
import 'package:flutter/material.dart';

import '../../../mainScreens/toggle_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin
{
  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index)
  {
    setState(() {
      selectedIndex =index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState()
  {
    super.initState();

    tabController =TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var count = 0;
    return WillPopScope(
      onWillPop: ()async {
        if(count==1){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c)=>  ToggleScreenPage()),(Route<dynamic> route) => false);
        }
        count++;
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: const [
              HomeTabPage(),
              ProfileTabPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
      
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
              ),
      
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
      
            ],
            unselectedItemColor: Colors.white24,
            selectedItemColor: Colors.white,
            backgroundColor: Colors.blue,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontSize: 14),
            showUnselectedLabels: true,
            currentIndex: selectedIndex,
            onTap: onItemClicked,
          ),
      
        ),
      ),
    );
  }
}
