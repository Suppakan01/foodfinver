import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

//หน้าจอแสดงเมื่อเริ่มต้นแอปพลิเคชัน รอตรวจสอบสถานะการล็อกอิน
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //ตั้งเวลาก่อนไปหน้าถัดไป
    Timer(Duration(seconds: 2), () {
      checkLoginStatus();
    });
  }

  //ตรวจสอบสถานะการล็อกอิน
  void checkLoginStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    //ถ้าล็อกอินแล้วไปที่หน้าหลัก ถ้าไม่ไปที่หน้าล็อกอิน
    if (authProvider.isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้แอปพลิเคชัน
            Icon(
              Icons.restaurant,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 20),
            Text(
              'FoodFinver',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
