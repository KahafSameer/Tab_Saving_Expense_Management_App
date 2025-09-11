// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:savings/Main_Screens/FixedExpenses.dart';
import 'package:savings/Main_Screens/HistoryPage.dart';
import 'package:savings/Main_Screens/HomePage.dart';
import 'package:savings/Main_Screens/NewItem.dart';
import 'package:savings/Main_Screens/ProfileInfo.dart';
import 'package:savings/Main_Screens/ChatBotScreen.dart';
import 'package:savings/Main_Screens/SpendingBarChart.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  PersistentTabController? controller;

  @override
  void initState() {
    super.initState();
    controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const NewItem(),
      const HistoryPage(),
      const FixedExpensesScreen(),
      const SpendingBarChart(),
      // const ProfileInfo(), // Profile tab commented out
      const ChatPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.house_outlined),
        title: "Home",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add),
        title: "Add",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.history),
        title: "History",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.receipt_long),
        title: "Fixed",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.bar_chart),
        title: "Spending",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      // PersistentBottomNavBarItem(
      //   icon: const Icon(Icons.person_outline),
      //   title: "Profile",
      //   activeColorPrimary: Colors.blue,
      //   inactiveColorPrimary: Colors.grey,
      // ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.chat_bubble_outline),
        title: "ChatBot",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: false,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style6,
    );
  }
}
