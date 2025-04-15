import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

//หน้าจอสำหรับแก้ไขข้อมูลโปรไฟล์ผู้ใช้
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();

    //ดึงข้อมูลผู้ใช้ปัจจุบันมาแสดงในฟอร์ม
    final userModel =
        Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (userModel != null) {
      _nameController.text =
          userModel.displayName; // หรือใช้ userModel.name ก็ได้
      _emailController.text = userModel.email;
      _phoneController.text = userModel.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // บันทึกข้อมูลโปรไฟล์ที่แก้ไข
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // ข้อมูลที่จะอัปเดท - แก้ไขการสร้าง UserModel ให้ถูกต้อง
      final userUpdate = UserModel(
        uid: authProvider.currentUser!.uid, // ใช้ uid แทน id
        email: _emailController.text.trim(),
        displayName: _nameController.text.trim(), // ใช้ displayName แทน name
        phoneNumber: _phoneController.text.trim(),
        password: _changePassword ? _newPasswordController.text : '',
        favorites:
            authProvider
                .currentUser!
                .favorites, // ใช้ favorites แทน favoriteRestaurants
        reviewCount: authProvider.currentUser!.reviewCount,
        createdAt: authProvider.currentUser!.createdAt,
      );

      // บันทึกข้อมูลและเช็ครหัสผ่านปัจจุบัน (ถ้ามีการเปลี่ยนรหัสผ่าน)
      if (_changePassword) {
        await authProvider.updateUserWithPasswordCheck(
          userUpdate,
          _currentPasswordController.text,
        );
      } else {
        await authProvider.updateUser(userUpdate);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')));

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $error')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('แก้ไขโปรไฟล์')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //ส่วนหัวของหน้า
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'แก้ไขข้อมูลส่วนตัว',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'แก้ไขข้อมูลส่วนตัวหรือเปลี่ยนรหัสผ่านของคุณ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),

                      //ส่วนข้อมูลส่วนตัว
                      Text(
                        'ข้อมูลส่วนตัว',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),

                      //ชื่อ
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'ชื่อ',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกชื่อ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      //อีเมล
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'อีเมล',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกอีเมล';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'รูปแบบอีเมลไม่ถูกต้อง';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      //เบอร์โทรศัพท์
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'เบอร์โทรศัพท์',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกเบอร์โทรศัพท์';
                          }
                          if (!RegExp(r'^[0-9]{9,10}$').hasMatch(value)) {
                            return 'รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),

                      //ส่วนเปลี่ยนรหัสผ่าน
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'เปลี่ยนรหัสผ่าน',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: _changePassword,
                            onChanged: (value) {
                              setState(() {
                                _changePassword = value;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 15),

                      //แสดงฟอร์มเปลี่ยนรหัสผ่านเมื่อกดปุ่มเปลี่ยนรหัสผ่าน
                      if (_changePassword) ...[
                        //รหัสผ่านปัจจุบัน
                        TextFormField(
                          controller: _currentPasswordController,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่านปัจจุบัน',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: !_showPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกรหัสผ่านปัจจุบัน';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),

                        //รหัสผ่านใหม่
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่านใหม่',
                            prefixIcon: Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: !_showPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกรหัสผ่านใหม่';
                            }
                            if (value.length < 6) {
                              return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),

                        //ยืนยันรหัสผ่านใหม่
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'ยืนยันรหัสผ่านใหม่',
                            prefixIcon: Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: !_showPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณายืนยันรหัสผ่านใหม่';
                            }
                            if (value != _newPasswordController.text) {
                              return 'รหัสผ่านไม่ตรงกัน';
                            }
                            return null;
                          },
                        ),
                      ],

                      SizedBox(height: 40),

                      // ปุ่มบันทึกข้อมูล
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'บันทึกข้อมูล',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // ปุ่มยกเลิก
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey),
                          ),
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
