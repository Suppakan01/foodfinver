import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// จัดการสถานะการยืนยันตัวตนและข้อมูลผู้ใช้
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false; //ตัวแปรสำหรับเก็บสถานะการโหลดข้อมูล

  UserModel? _currentUser; // ตัวแปรสำหรับเก็บข้อมูลผู้ใช้ปัจจุบัน

  bool get isLoggedIn =>
      _auth.currentUser !=
      null; //Getter สำหรับตรวจสอบว่ามีการลงชื่อเข้าใช้อยู่หรือไม่

  bool get isLoading => _isLoading; //Getter สำหรับตรวจสอบสถานะการโหลดข้อมูล

  UserModel? get currentUser =>
      _currentUser; //Getter สำหรับเรียกดูข้อมูลผู้ใช้ปัจจุบัน

  String? get uid =>
      _auth.currentUser?.uid; //Getter สำหรับเรียกดู uid ของผู้ใช้ปัจจุบัน

  //สร้าง constructor และตรวจสอบการเปลี่ยนแปลงของสถานะการลงชื่อเข้าใช้
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // เรียกข้อมูลผู้ใช้จาก Firestore เมื่อมีการลงชื่อเข้าใช้
        _fetchUserData(user.uid);
      } else {
        // รีเซ็ตข้อมูลผู้ใช้เมื่อออกจากระบบ
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // ดึงข้อมูลผู้ใช้จาก Firestore
  Future<void> _fetchUserData(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ลงทะเบียนผู้ใช้ใหม่
  Future<bool> register(
    String email,
    String password,
    String displayName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // สร้างบัญชีผู้ใช้ใหม่ด้วย Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ถ้าสร้างบัญชีสำเร็จ เพิ่มข้อมูลผู้ใช้ใน Firestore
      if (result.user != null) {
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          email: email,
          displayName: displayName,
          favorites: [],
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());
        _currentUser = newUser;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('เกิดข้อผิดพลาดในการลงทะเบียน: $e');
      return false;
    }
  }

  // เข้าสู่ระบบ
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ล็อกอินด้วย Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ดึงข้อมูลผู้ใช้จาก Firestore
      DocumentSnapshot userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      // ถ้ามีข้อมูลใน Firestore
      if (userDoc.exists) {
        // แปลงข้อมูลจาก Firestore เป็น UserModel
        _currentUser = UserModel.fromMap({
          ...userDoc.data() as Map<String, dynamic>,
          'uid': userCredential.user!.uid,
        });
      } else {
        // ถ้าไม่มีข้อมูลใน Firestore (กรณีผู้ใช้ลงทะเบียนแต่ข้อมูลไม่ถูกสร้างใน Firestore)
        _currentUser = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          displayName: userCredential.user?.displayName ?? '',
          phoneNumber: '',
          favorites: [],
        );

        // สร้างข้อมูลผู้ใช้ใหม่ใน Firestore
        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .set(_currentUser!.toMap());
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      // จัดการกับข้อผิดพลาดต่างๆ และแปลเป็นภาษาไทย
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw 'ไม่พบบัญชีผู้ใช้ที่ตรงกับอีเมลนี้';
          case 'wrong-password':
            throw 'รหัสผ่านไม่ถูกต้อง';
          case 'invalid-email':
            throw 'รูปแบบอีเมลไม่ถูกต้อง';
          case 'user-disabled':
            throw 'บัญชีผู้ใช้นี้ถูกระงับการใช้งาน';
          case 'too-many-requests':
            throw 'มีการพยายามเข้าสู่ระบบหลายครั้งเกินไป โปรดลองอีกครั้งในภายหลัง';
          default:
            throw 'เกิดข้อผิดพลาด: ${e.code}';
        }
      } else {
        throw 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ: $e';
      }
    }
  }

  // อัปเดตข้อมูลผู้ใช้ทั่วไป (ไม่มีการเปลี่ยนรหัสผ่าน)
  Future<void> updateUser(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // อัปเดตข้อมูลใน Firestore
      await _firestore.collection('users').doc(updatedUser.uid).update({
        'displayName': updatedUser.displayName,
        'email': updatedUser.email,
        'phoneNumber': updatedUser.phoneNumber,
        // ไม่มีการอัปเดตรหัสผ่านที่นี่เพราะรหัสผ่านจัดการผ่าน Firebase Authentication
      });

      // อัปเดตข้อมูลผู้ใช้ปัจจุบันใน Provider
      _currentUser = updatedUser;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('เกิดข้อผิดพลาดในการอัปเดตข้อมูลผู้ใช้: $e');
      throw e; // ส่งต่อข้อผิดพลาดเพื่อให้หน้าจอจัดการได้
    }
  }

  // อัปเดตข้อมูลผู้ใช้พร้อมตรวจสอบและเปลี่ยนรหัสผ่าน
  Future<void> updateUserWithPasswordCheck(
    UserModel updatedUser,
    String currentPassword,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ตรวจสอบรหัสผ่านปัจจุบันโดยการลงชื่อเข้าใช้ใหม่
      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email != null) {
        // สร้าง credential จากอีเมลและรหัสผ่านปัจจุบัน
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );

        // ลงชื่อเข้าใช้ใหม่เพื่อตรวจสอบรหัสผ่าน
        await currentUser.reauthenticateWithCredential(credential);

        // เปลี่ยนรหัสผ่าน
        await currentUser.updatePassword(updatedUser.password);

        // อัปเดตข้อมูลอื่นๆ ใน Firestore
        await _firestore.collection('users').doc(updatedUser.uid).update({
          'displayName': updatedUser.displayName,
          'email': updatedUser.email,
          'phoneNumber': updatedUser.phoneNumber,
          // ไม่มีการเก็บรหัสผ่านใน Firestore
        });

        // อัปเดตข้อมูลผู้ใช้ปัจจุบันใน Provider
        _currentUser = updatedUser;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('เกิดข้อผิดพลาดในการอัปเดตข้อมูลผู้ใช้และรหัสผ่าน: $e');
      throw e; // ส่งต่อข้อผิดพลาดเพื่อให้หน้าจอจัดการได้
    }
  }

  // เมธอดสำหรับส่งอีเมลรีเซ็ตรหัสผ่าน
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ใช้ Firebase Authentication ส่งอีเมลรีเซ็ตรหัสผ่าน
      await _auth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      // จัดการกับข้อผิดพลาดต่างๆ และแปลเป็นภาษาไทย
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw 'ไม่พบบัญชีผู้ใช้ที่ตรงกับอีเมลนี้';
          case 'invalid-email':
            throw 'รูปแบบอีเมลไม่ถูกต้อง';
          case 'too-many-requests':
            throw 'มีการส่งคำขอมากเกินไป โปรดลองอีกครั้งในภายหลัง';
          default:
            throw 'เกิดข้อผิดพลาด: ${e.code}';
        }
      } else {
        throw 'เกิดข้อผิดพลาดในการส่งอีเมลรีเซ็ตรหัสผ่าน: $e';
      }
    }
  }

  // ออกจากระบบ
  Future<void> logout() async {
    await _auth.signOut();
  }

  // เพิ่มร้านอาหารลงในรายการโปรด
  Future<void> toggleFavorite(String restaurantId) async {
    if (_currentUser == null) return;

    try {
      List<String> updatedFavorites = List.from(_currentUser!.favorites);

      if (updatedFavorites.contains(restaurantId)) {
        updatedFavorites.remove(restaurantId);
      } else {
        updatedFavorites.add(restaurantId);
      }

      // อัปเดตใน Firestore
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'favorites': updatedFavorites,
      });

      // อัปเดตใน Provider
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: _currentUser!.displayName,
        photoURL: _currentUser!.photoURL,
        favorites: updatedFavorites,
      );

      notifyListeners();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปเดตรายการโปรด: $e');
    }
  }

  // ตรวจสอบว่าร้านอาหารอยู่ในรายการโปรดหรือไม่
  bool isFavorite(String restaurantId) {
    return _currentUser?.favorites.contains(restaurantId) ?? false;
  }
}
