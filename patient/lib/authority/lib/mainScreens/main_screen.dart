import 'package:patient/authority/lib/mainScreens/profile_tab.dart';
import 'package:flutter/material.dart';
import 'home_tab.dart';

class MainScreen extends StatefulWidget {


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
    return SafeArea(
      child: Scaffold(
    
    
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children:  [
            HomeTabScreen(),
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
    );
  }
}
