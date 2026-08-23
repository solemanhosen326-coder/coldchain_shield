import 'package:firebase_auth/firebase_auth.dart';
import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EnterpriseSettingsPage extends StatelessWidget {
  const EnterpriseSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final enterprise =
        context.watch<EnterpriseProvider>().enterprise;

    if (enterprise == null) {
      return const Scaffold(
        backgroundColor: Color(0xff0B1220),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.cyanAccent,
          ),
        ),
      );
    }

    final companyId = enterprise.companyId;

    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Enterprise Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ============================================================
            // ENTERPRISE PROFILE
            // ============================================================

            const Text(
              "Enterprise Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildInfoCard(
              icon: Icons.business_outlined,
              title: "Company Name",
              value: enterprise.companyName,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.email_outlined,
              title: "Email",
              value: enterprise.email,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.phone_outlined,
              title: "Phone",
              value: enterprise.phone,
            ),

            const SizedBox(height: 30),

            // ============================================================
            // COMPANY ID
            // ============================================================

            const Text(
              "Company ID",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xff182233),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Row(
                    children: [
                      Icon(
                        Icons.key_outlined,
                        color: Colors.cyanAccent,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Your Company ID",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xff0B1220),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [

                        Expanded(
                          child: SelectableText(
                            companyId,
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          tooltip: "Copy Company ID",
                          icon: const Icon(
                            Icons.copy_outlined,
                            color: Colors.cyanAccent,
                          ),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: companyId,
                              ),
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Company ID copied",
                                  ),
                                ),
                              );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Share this ID with a driver who wants to "
                    "request to join your company.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ============================================================
            // ACCOUNT SECURITY
            // ============================================================

            const Text(
              "Account Security",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xff182233),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent
                          .withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.cyanAccent,
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Change Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Update your account password "
                          "to keep your account secure.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: "Change Password",
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.cyanAccent,
                      size: 18,
                    ),
                    onPressed: () {
                      _showChangePasswordDialog(
                        context,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.cyanAccent,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHANGE PASSWORD DIALOG
  // ============================================================

  Future<void> _showChangePasswordDialog(
    BuildContext context,
  ) async {
    final currentPasswordController =
        TextEditingController();

    final newPasswordController =
        TextEditingController();

    final confirmPasswordController =
        TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor:
                  const Color(0xff182233),

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),

              title: const Text(
                "Change Password",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ----------------------------------------------------
                    // CURRENT PASSWORD
                    // ----------------------------------------------------

                    TextField(
                      controller:
                          currentPasswordController,
                      obscureText: obscureCurrent,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            "Current Password",
                        labelStyle:
                            const TextStyle(
                          color: Colors.white70,
                        ),
                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                          color: Colors.cyanAccent,
                        ),
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color:
                                Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureCurrent =
                                  !obscureCurrent;
                            });
                          },
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color:
                                Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ----------------------------------------------------
                    // NEW PASSWORD
                    // ----------------------------------------------------

                    TextField(
                      controller:
                          newPasswordController,
                      obscureText: obscureNew,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            "New Password",
                        labelStyle:
                            const TextStyle(
                          color: Colors.white70,
                        ),
                        prefixIcon:
                            const Icon(
                          Icons.lock_reset,
                          color: Colors.cyanAccent,
                        ),
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color:
                                Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureNew =
                                  !obscureNew;
                            });
                          },
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color:
                                Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ----------------------------------------------------
                    // CONFIRM PASSWORD
                    // ----------------------------------------------------

                    TextField(
                      controller:
                          confirmPasswordController,
                      obscureText: obscureConfirm,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            "Confirm New Password",
                        labelStyle:
                            const TextStyle(
                          color: Colors.white70,
                        ),
                        prefixIcon:
                            const Icon(
                          Icons.lock_reset,
                          color: Colors.cyanAccent,
                        ),
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color:
                                Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirm =
                                  !obscureConfirm;
                            });
                          },
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color:
                                Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [

                // --------------------------------------------------------
                // CANCEL
                // --------------------------------------------------------

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),

                // --------------------------------------------------------
                // UPDATE
                // --------------------------------------------------------

                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.cyanAccent,
                    foregroundColor:
                        Colors.black,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await _changePassword(
                      context: dialogContext,
                      currentPassword:
                          currentPasswordController
                              .text
                              .trim(),
                      newPassword:
                          newPasswordController
                              .text
                              .trim(),
                      confirmPassword:
                          confirmPasswordController
                              .text
                              .trim(),
                    );
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword({
    required BuildContext context,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // ------------------------------------------------------------
    // Validation
    // ------------------------------------------------------------

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage(
        context,
        "Please fill in all fields.",
      );

      return;
    }

    if (newPassword.length < 6) {
      _showMessage(
        context,
        "New password must be at least 6 characters.",
      );

      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(
        context,
        "New passwords do not match.",
      );

      return;
    }

    // ------------------------------------------------------------
    // Current Firebase user
    // ------------------------------------------------------------

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        context,
        "Unable to identify the current account.",
      );

      return;
    }

    final email = user.email;

    if (email == null ||
        email.trim().isEmpty) {
      _showMessage(
        context,
        "This account does not have a valid email.",
      );

      return;
    }

    try {
      // ----------------------------------------------------------
      // Re-authenticate user
      // ----------------------------------------------------------

      final credential =
          EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(
        credential,
      );

      // ----------------------------------------------------------
      // Update Firebase Authentication password
      // ----------------------------------------------------------

      await user.updatePassword(
        newPassword,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);

      _showMessage(
        context,
        "Password changed successfully.",
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "❌ Change password Firebase error: "
        "${e.code}",
      );

      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message =
              "Current password is incorrect.";
          break;

        case 'weak-password':
          message =
              "The new password is too weak.";
          break;

        case 'requires-recent-login':
          message =
              "Please sign in again before changing "
              "your password.";
          break;

        case 'user-disabled':
          message =
              "This account has been disabled.";
          break;

        default:
          message =
              "Unable to change password. "
              "Please try again.";
      }

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        message,
      );
    } catch (e, stackTrace) {
      debugPrint(
        "❌ Change password error: $e",
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        "An unexpected error occurred.",
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}


// import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// class EnterpriseSettingsPage extends StatelessWidget {
//   const EnterpriseSettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final enterprise = context.watch<EnterpriseProvider>().enterprise;

//     if (enterprise == null) {
//       return const Scaffold(
//         backgroundColor: Color(0xff0B1220),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final companyId = enterprise.companyId;

//     return Scaffold(
//       backgroundColor: const Color(0xff0B1220),

//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "Enterprise Settings",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // =========================
//             // Enterprise Profile
//             // =========================
//             const Text(
//               "Enterprise Profile",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 15),

//             _buildInfoCard(
//               icon: Icons.business_outlined,
//               title: "Company Name",
//               value: enterprise.companyName,
//             ),

//             const SizedBox(height: 12),

//             _buildInfoCard(
//               icon: Icons.email_outlined,
//               title: "Email",
//               value: enterprise.email,
//             ),

//             const SizedBox(height: 12),

//             _buildInfoCard(
//               icon: Icons.phone_outlined,
//               title: "Phone",
//               value: enterprise.phone,
//             ),

//             const SizedBox(height: 30),

//             // =========================
//             // Company ID
//             // =========================
//             const Text(
//               "Company ID",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 15),

//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: const Color(0xff182233),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Row(
//                     children: [
//                       Icon(Icons.key_outlined, color: Colors.cyanAccent),

//                       SizedBox(width: 10),

//                       Text(
//                         "Your Company ID",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 17,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 15),

//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: const Color(0xff0B1220),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: SelectableText(
//                             companyId,
//                             style: const TextStyle(
//                               color: Colors.cyanAccent,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),

//                         IconButton(
//                           tooltip: "Copy Company ID",
//                           icon: const Icon(
//                             Icons.copy_outlined,
//                             color: Colors.cyanAccent,
//                           ),
//                           onPressed: () async {
//                             await Clipboard.setData(
//                               ClipboardData(text: companyId),
//                             );

//                             if (!context.mounted) return;

//                             ScaffoldMessenger.of(context)
//                               ..hideCurrentSnackBar()
//                               ..showSnackBar(
//                                 const SnackBar(
//                                   content: Text("Company ID copied"),
//                                 ),
//                               );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 15),

//                   const Text(
//                     "Share this ID with a driver who wants to "
//                     "request to join your company.",
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: const Color(0xff182233),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.cyanAccent),

//           const SizedBox(width: 15),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(color: Colors.white54, fontSize: 13),
//                 ),

//                 const SizedBox(height: 5),

//                 Text(
//                   value,
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
