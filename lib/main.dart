import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/user/view_model/user_view_model.dart';
// import 'ui/user/widgets/user_screen.dart';
import 'ui/core/tab_screen.dart'; // Import the TabScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()..fetchUsers()),
      ],
      child: MaterialApp(
        title: 'Training App',
        debugShowCheckedModeBanner: false,
        home: const TabScreen(), // Set TabScreen as the initial screen
      ),
    );
  }
}
