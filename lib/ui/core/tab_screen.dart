import 'package:flutter/material.dart';
import '../user/widgets/user_screen.dart'; // Import the UserScreen

class TabScreen extends StatelessWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Flutter App'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 5),
                    Text('Users'),
                ]),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 5),
                    Text('Tab 2'),
                ]),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 5),
                    Text('Tab 3'),
                ]),
              ),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            // First tab content - UserScreen
            UserScreen(),
            // Placeholder for the second tab
            Center(child: Text('Content for Tab 2')),
            // Placeholder for the third tab
            Center(child: Text('Content for Tab 3')),
          ],
        ),
      ),
    );
  }
}
