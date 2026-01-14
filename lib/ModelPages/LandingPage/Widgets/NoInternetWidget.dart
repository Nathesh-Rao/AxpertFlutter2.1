import 'package:animate_do/animate_do.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onGoOffline;

  const NoInternetWidget({
    super.key,
    this.onGoOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🐱 LOTTIE
                Expanded(
                  flex: 5,
                  child: ZoomIn(
                    // from: 1.5,
                    child: Lottie.asset(
                      'assets/lotties/download.json',
                      // width: 220,
                      // fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ===== TITLE =====
                Text(
                  "You're Offline",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: MyColors.AXMDark,
                  ),
                ),

                const SizedBox(height: 10),

                // ===== DESCRIPTION =====
                Text(
                  "It looks like you don't have an internet connection right now.\n"
                  "You can continue working using the offline forms and previously synced data.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: MyColors.AXMGray,
                  ),
                ),

                const SizedBox(height: 28),

                // ===== INFO CARD =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MyColors.blue2.withOpacity(0.12),
                        ),
                        child: const Icon(
                          Icons.cloud_off_outlined,
                          color: MyColors.blue2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Only offline forms and cached data are available in this mode.",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: MyColors.AXMDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Spacer(),
                // ===== BUTTON =====
                if (onGoOffline != null)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.blue2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onGoOffline,
                      child: Text(
                        "Go to Offline Mode",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
