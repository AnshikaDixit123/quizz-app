//import m,aterial package
import 'package:flutter/material.dart';

//import home screen file
import './screens/home_screen.dart';

//run the main method
void main(){
  
  //the runApp method
  runApp(
    const MyApp(),//created below
  );
}

//create MyApp widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //remove the debug manner
      debugShowCheckedModeBanner: false,
      //set homepage
      home: HomeScreen(),//create in seperate file
    );
  }
}