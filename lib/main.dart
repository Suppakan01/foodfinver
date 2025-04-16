import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// นำเข้า FirebaseOptions
import 'firebase_options.dart';

// นำเข้า providers
import 'providers/auth_provider.dart';
import 'providers/restaurant_provider.dart';

// นำเข้า screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // ต้องเรียกก่อนใช้งาน native code (Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น Firebase ด้วย options ที่กำหนด
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ใช้ MultiProvider เพื่อจัดการ providers หลายตัว
    return MultiProvider(
      providers: [
        // Provider สำหรับจัดการการยืนยันตัวตน
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Provider สำหรับจัดการข้อมูลร้านอาหาร
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
      child: MaterialApp(
        title: 'FoodFinver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            secondary: Colors.deepOrangeAccent,
          ),
          fontFamily:
              'Kanit', // ใช้ฟอนต์ Kanit หรือเปลี่ยนเป็นฟอนต์ที่คุณต้องการ
          visualDensity: VisualDensity.adaptivePlatformDensity,

          // ปรับแต่ง AppBar
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.orange),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // ปรับแต่ง ElevatedButton
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // ปรับแต่ง Card
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // ปรับแต่ง InputDecoration
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        ),

        // เริ่มต้นที่ SplashScreen
        home: SplashScreen(),

        // กำหนด routes สำหรับการนำทางในแอป
        routes: {
          '/home': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }
}
