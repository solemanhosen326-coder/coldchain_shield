import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coldchain_shield/app/app_home_gate.dart';
import 'package:coldchain_shield/model.dart';
import 'package:coldchain_shield/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

 
  bool _isDriverActive = true;
  bool _isSignInMode =
      true; 
  bool isloading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String uid) async {
    // Call the user's CollectionReference to add a new user
    await users
        .doc(uid)
        .set({
          'email': _emailController.text.trim(),
          'role': 'driver',
          'uid': uid,
          'userName': _nameController.text,
          'userPhone': _phoneController.text,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF0B0E14);
    const Color crystalBlue = Color(0xFF00E5FF);
    const Color cyberBlue = Color(0xFF0052D4);

    return Scaffold(
      backgroundColor: bgBlack,
      body: Stack(
        children: [
          
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: crystalBlue.withValues(alpha: 0.15),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _globalKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                   
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: crystalBlue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: crystalBlue.withValues(alpha: 0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.ac_unit,
                        size: 40,
                        color: crystalBlue,
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text(
                      'COLDCHAIN SHIELD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'رادار الإمداد الذكي وسلاسل التبريد',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    
                    if (_isSignInMode)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDriverActive = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isDriverActive
                                        ? crystalBlue
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'تطبيق السائق',
                                      style: TextStyle(
                                        color: _isDriverActive
                                            ? bgBlack
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDriverActive = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isDriverActive
                                        ? crystalBlue
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'لوحة الشركة',
                                      style: TextStyle(
                                        color: !_isDriverActive
                                            ? bgBlack
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: _isSignInMode ? 30 : 10),

                   
                    if (!_isSignInMode) ...[
                      CustomCrystalTextField(
                        keyboardType: TextInputType.name,
                        controller: _nameController,
                        hint: 'اسم السائق الثلاثي',
                        icon: Icons.person_outline,
                        crystalBlue: crystalBlue,
                      ),
                      const SizedBox(height: 15),
                      CustomCrystalTextField(
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        hint: 'رقم الجوال الفعال (الخليج/المحلي)',
                        icon: Icons.phone_android_outlined,
                        crystalBlue: crystalBlue,
                      ),
                      const SizedBox(height: 15),
                    ],

                    
                    CustomCrystalTextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      hint: 'البريد الإلكتروني المهني',
                      icon: Icons.email_outlined,
                      crystalBlue: crystalBlue,
                    ),
                    const SizedBox(height: 15),

                    
                    CustomCrystalTextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      hint: 'كلمة المرور السرية',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      crystalBlue: crystalBlue,
                    ),

                    const SizedBox(height: 30),

                    
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [cyberBlue, crystalBlue],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: crystalBlue.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: MaterialButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();

                          // ============================================================
                          // VALIDATION
                          // ============================================================

                          if (!_globalKey.currentState!.validate()) {
                            return;
                          }

                          setState(() {
                            isloading = true;
                          });

                          // ============================================================
                          // CREATE NEW DRIVER ACCOUNT
                          // ============================================================

                          if (!_isSignInMode) {
                            try {
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );

                              final uid = credential.user?.uid.trim();

                              if (uid == null || uid.isEmpty) {
                                await FirebaseAuth.instance.signOut();

                                if (!mounted) return;

                                setState(() {
                                  isloading = false;
                                });

                                showCyberErrorDialog(
                                  title: 'تنبيه',
                                  message: 'تعذر إنشاء بيانات المستخدم.',
                                );

                                return;
                              }

                              // ==========================================================
                              // New accounts created from this page are ALWAYS drivers.
                              // addUser() stores role = driver in Firestore.
                              // ==========================================================

                              await addUser(uid);

                              if (!mounted) return;

                              // Provider = Driver
                              context.read<Model>().setFinalRole(true);

                              setState(() {
                                isloading = false;
                              });

                              showCyberSuccessDialog(
                                title: '',
                                message: 'تم إنشاء الحساب بنجاح',
                                btnOkOnPress: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const AppHomeGate(),
                                    ),
                                  );
                                },
                              );
                            } on FirebaseAuthException catch (e) {
                              if (!mounted) return;

                              setState(() {
                                isloading = false;
                              });

                              if (e.code == 'weak-password') {
                                showCyberErrorDialog(
                                  title: 'تنبيه',
                                  message: 'كلمة المرور ضعيفة للغاية',
                                );
                              } else if (e.code == 'email-already-in-use') {
                                showCyberErrorDialog(
                                  title: 'تنبيه',
                                  message:
                                      'الحساب موجود بالفعل لهذا البريد الإلكتروني',
                                );
                              } else if (e.code == 'invalid-email') {
                                showCyberErrorDialog(
                                  title: 'تنبيه',
                                  message: 'البريد الإلكتروني غير صالح',
                                );
                              } else {
                                debugPrint(
                                  '❌ CREATE ACCOUNT AUTH ERROR: '
                                  '${e.code} - ${e.message}',
                                );

                                showCyberErrorDialog(
                                  title: 'خطأ',
                                  message: 'تعذر إنشاء الحساب، حاول مرة أخرى.',
                                );
                              }
                            } catch (e, stackTrace) {
                              debugPrint('❌ CREATE ACCOUNT ERROR: $e');
                              debugPrintStack(stackTrace: stackTrace);

                              if (!mounted) return;

                              setState(() {
                                isloading = false;
                              });

                              showCyberErrorDialog(
                                title: 'خطأ',
                                message: 'حدث خطأ أثناء إنشاء الحساب.',
                              );
                            }

                            return;
                          }

                          // ============================================================
                          // SIGN IN
                          // ============================================================

                          try {
                            // ==========================================================
                            // 1️⃣ Firebase Authentication
                            // ==========================================================

                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );

                            final uid = credential.user?.uid.trim();

                            if (uid == null || uid.isEmpty) {
                              await FirebaseAuth.instance.signOut();

                              if (!mounted) return;

                              setState(() {
                                isloading = false;
                              });

                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message: 'بيانات الحساب غير صالحة.',
                              );

                              return;
                            }

                            debugPrint(
                              '🟢 LOGIN CHECK 1: Firebase Authentication successful.',
                            );
                            debugPrint('   UID = $uid');

                            // ==========================================================
                            // 2️⃣ Firestore User Document
                            // ==========================================================

                            final DocumentSnapshot<Map<String, dynamic>>
                            userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .get();

                            if (!userDoc.exists || userDoc.data() == null) {
                              debugPrint(
                                '🔴 LOGIN CHECK 2: User document does not exist.',
                              );

                              await FirebaseAuth.instance.signOut();

                              if (!mounted) return;

                              setState(() {
                                isloading = false;
                              });

                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message: 'لم يتم العثور على بيانات المستخدم.',
                              );

                              return;
                            }

                            final Map<String, dynamic> data = userDoc.data()!;

                            final String? userRole = (data['role'] as String?)
                                ?.trim()
                                .toLowerCase();

                            if (userRole == null || userRole.isEmpty) {
                              debugPrint(
                                '🔴 LOGIN CHECK 2: User role is missing.',
                              );

                              await FirebaseAuth.instance.signOut();

                              if (!mounted) return;

                              setState(() {
                                isloading = false;
                              });

                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message: 'لم يتم تحديد صلاحية هذا الحساب.',
                              );

                              return;
                            }

                            final bool isDriver = userRole == 'driver';

                            final bool isEnterprise =
                                userRole == 'enterprise' ||
                                userRole == 'company';

                            // ==========================================================
                            // Unknown Role
                            // ==========================================================

                            if (!isDriver && !isEnterprise) {
                              debugPrint(
                                '🔴 LOGIN CHECK 2: Unknown Firestore role = $userRole',
                              );

                              await FirebaseAuth.instance.signOut();

                              if (!mounted) return;

                              setState(() {
                                isloading = false;
                              });

                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message: 'نوع الحساب غير معروف.',
                              );

                              return;
                            }

                            debugPrint(
                              '🟢 LOGIN CHECK 2: Firestore role = $userRole',
                            );

                            // ==========================================================
                            // 3️⃣ Check selected login interface
                            // ==========================================================

                            // User selected Enterprise UI but account is Driver.
                            if (!_isDriverActive && isDriver) {
                              debugPrint(
                                '🔴 LOGIN: Driver account used Enterprise interface.',
                              );

                              await FirebaseAuth.instance.signOut();

                              if (!mounted) return;

                              setState(() {
                                isloading = false;
                              });

                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message: 'هذا الحساب خاص بالسائقين فقط.',
                              );

                              return;
                            }

                            // User selected Driver UI but account is Enterprise.
                            if (_isDriverActive && isEnterprise) {
                              debugPrint(
                                '🔴 LOGIN: Enterprise account used Driver interface.',
                              );

                              await FirebaseAuth.instance.signOut();

                              if (!mounted) return;

                              setState(() {
                                isloading = false;
                              });

                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message: 'هذا الحساب خاص بالشركات فقط.',
                              );

                              return;
                            }

                            // ==========================================================
                            // 4️⃣ Update Provider
                            // ==========================================================

                            if (!mounted) return;

                            final model = context.read<Model>();

                            // true  = Driver
                            // false = Enterprise
                            model.setFinalRole(isDriver);

                            final bool? providerRole = model.isDriverRole;

                            debugPrint(
                              '🟡 LOGIN: Provider role = '
                              '${providerRole == null
                                  ? 'unknown'
                                  : providerRole
                                  ? 'driver'
                                  : 'enterprise'}',
                            );

                            // ==========================================================
                            // 5️⃣ Finish loading
                            // ==========================================================

                            setState(() {
                              isloading = false;
                            });

                            // ==========================================================
                            // 6️⃣ Let AppHomeGate perform the final verification
                            // ==========================================================

                            debugPrint('🟢 LOGIN: Opening AppHomeGate.');

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const AppHomeGate(),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (!mounted) return;

                            setState(() {
                              isloading = false;
                            });

                            if (e.code == 'user-not-found') {
                              showCyberErrorDialog(
                                title: 'خطأ',
                                message:
                                    'لم يتم العثور على مستخدم لهذا البريد الإلكتروني.',
                              );
                            } else if (e.code == 'wrong-password') {
                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message: 'تم إدخال كلمة مرور خاطئة.',
                              );
                            } else if (e.code == 'invalid-credential') {
                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message:
                                    'بريد إلكتروني أو كلمة مرور غير صحيحة.',
                              );
                            } else if (e.code == 'invalid-email') {
                              showCyberErrorDialog(
                                title: 'تنبيه',
                                message: 'البريد الإلكتروني غير صالح.',
                              );
                            } else {
                              debugPrint(
                                '❌ LOGIN AUTH ERROR: '
                                '${e.code} - ${e.message}',
                              );

                              showCyberErrorDialog(
                                title: 'خطأ',
                                message: 'تعذر تسجيل الدخول، حاول مرة أخرى.',
                              );
                            }
                          } catch (e, stackTrace) {
                            debugPrint('❌ LOGIN ERROR: $e');
                            debugPrintStack(stackTrace: stackTrace);

                            if (!mounted) return;

                            setState(() {
                              isloading = false;
                            });

                            showCyberErrorDialog(
                              title: 'خطأ',
                              message: 'حدث خطأ أثناء تسجيل الدخول.',
                            );
                          }
                        },

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: isloading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isSignInMode
                                    ? 'دخول آمن للمنظومة'
                                    : 'إنشاء حساب سائق جديد',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),


                    if (_isDriverActive)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignInMode = !_isSignInMode;
                          });
                        },
                        child: Text.rich(
                          TextSpan(
                            text: _isSignInMode
                                ? 'تريد الانضمام لأسطولنا؟ '
                                : 'تمتلك حساباً بالفعل؟ ',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: _isSignInMode ? 'سجل كسائق جديد' : 'دخول',
                                style: const TextStyle(
                                  color: crystalBlue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  1. ديالوج الخطأ والإنذار السحابي (أسود وأزرق بلوري)
  void showCyberErrorDialog({required String title, required String message}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      dialogBackgroundColor: const Color(0xFF0B0E14), // الأسود الملكي للتطبيق
      title: title,
      desc: message,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: const TextStyle(
        color: Color(0xFF00E5FF), 
        fontSize: 14,
      ),
      btnOkColor: const Color(0xFF0052D4), 
      btnOkText: 'مفهوم',
      btnOkOnPress: () {},
    ).show();
  }

  //  2. ديالوج النجاح والعبور الآمن للمنظومة
  void showCyberSuccessDialog({
    required String title,
    required String message,
    void Function()? btnOkOnPress,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      dialogBackgroundColor: const Color(0xFF0B0E14),
      title: title,
      desc: message,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: const TextStyle(color: Colors.greenAccent, fontSize: 14),
      btnOkColor: const Color(0xFF00E5FF), 
      btnOkText: 'انطلق',
      btnOkOnPress: () {
        btnOkOnPress?.call();
      },
    ).show();
  }
}
