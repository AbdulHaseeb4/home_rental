import 'package:flutter/material.dart';
import 'package:home_rental/menu_pages/menu_list/favoritespage.dart';
import 'package:home_rental/menu_pages/menu_list/myprofilepage.dart';
import '../menu_pages/menu_page.dart';
import '../menu_pages/buy_page.dart';
import '../menu_pages/rent_page.dart';
import '../menu_pages/list_property_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(); // ✅ Page Controller

  final List<Widget> _pages = [
    BuyPage(),
    RentPage(),
    ListPropertyPage(),
    MyProfilePage(),
    MenuPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut, // ✅ Smooth animation
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: ClampingScrollPhysics(), // ✅ Prevents overscroll effect
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // ✅ Sync bottom nav with swiping
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red.shade300,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Buy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Rent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'List Property',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }
}
