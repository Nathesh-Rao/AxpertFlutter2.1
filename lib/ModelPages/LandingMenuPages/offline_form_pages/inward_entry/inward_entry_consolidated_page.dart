import 'dart:convert';
import 'dart:io';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'inward_entry_dynamic_controller.dart';

class InwardEntryConsolidatedPage
    extends GetView<InwardEntryDynamicController> {
  const InwardEntryConsolidatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    // final main = controller.mainFormJson;
    final summary = controller.sampleSummaryJson;

    // final filteredMain = Map.fromEntries(
    //   main.entries.where(
    //     (e) => e.value != null && e.value.toString().trim().isNotEmpty,
    //   ),
    // );

    final filteredSummary = Map.fromEntries(
      summary.entries.where((e) {
        if (e.key == "maf_date" || e.key == "maf_year" || e.key == "short")
          return false;
        final int v = e.value ?? 0;
        return v > 0;
      }),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: MyColors.AXMDark,
        title: Text(
          "Review & Confirm",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        // padding: const EdgeInsets.only(bottom: 20),
        children: [
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   decoration: _cardDecoration(),
          //   child: Column(
          //     children: filteredMain.entries.map((e) {
          //       return _compactMainRow(e.key, e.value.toString());
          //     }).toList(),
          //   ),
          // ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== HEADER STRIP =====
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Sample Summary",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                // ===== BODY =====
              ],
            ),
          ),

          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     "Sample Summary",
          //     style: GoogleFonts.poppins(
          //       fontSize: 13,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.black87,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 10),
          // SizedBox(
          //   height: 170,
          //   child: ListView(
          //     padding: EdgeInsets.symmetric(horizontal: 16),
          //     scrollDirection: Axis.horizontal,
          //     children: filteredSummary.entries.map((e) {
          //       return _cupertinoStatCard(e.key, e.value);
          //     }).toList(),
          //   ),
          // ),

          Expanded(
            child: Builder(builder: (context) {
              if (filteredSummary.entries.isEmpty) {
                return Center(
                  child: Column(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(width: 170, "assets/images/empty-box-2.png"),
                      Text(
                        "No sample boxes to show.\nGo back to add sample details if needed.",
                        style: GoogleFonts.poppins(),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                );
              }

              return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredSummary.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, index) {
                    var gridTiles = filteredSummary.entries.map((e) {
                      return _gridStatTile(e.key, e.value);
                    }).toList();

                    return gridTiles[index];
                  });
            }),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 52,
          child: Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                // controller.uploadForm();
                controller.submit();
              },
              child: controller.isLoading.value
                  ? CupertinoActivityIndicator()
                  : filteredSummary.entries.isEmpty
                      ? const Text("Submit without samples")
                      : const Text("Submit"),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: MyColors.AXMGray.withAlpha(20)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget _compactMainRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // small circle icon
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEFF6FF),
            ),
            child: const Icon(
              Icons.circle,
              size: 8,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              key.replaceAll("_", " ").toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),

          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cupertinoStatCard(String key, dynamic value) {
    return Container(
      // width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Obx(() {
        final images = controller.imageAttachmentJson[key] ?? [];
        final bool hasImages = images.isNotEmpty;

        if (!hasImages) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.label,
                    size: 12,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    key.replaceAll("_", " ").toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEFF6FF),
                    ),
                    child: const Icon(
                      Icons.circle,
                      size: 8,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Full width add button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () => _pickImages(key),
                  icon: const Icon(CupertinoIcons.add_circled_solid),
                  label: const Text("Add Images"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEFF6FF),
                  ),
                  child: const Icon(
                    Icons.circle,
                    size: 8,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    key.replaceAll("_", " ").toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // image strip
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...images.asMap().entries.map((entry) {
                    final index = entry.key;
                    final b64 = entry.value;
                    return _imageThumb(key, index, b64);
                  }).toList(),

                  // add button
                  GestureDetector(
                    onTap: () => _pickImages(key),
                    child: Container(
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _gridStatTile(String key, dynamic value) {
    return Container(
      // NOTE: Removed external margin. Let the GridView's crossAxisSpacing handle gaps.
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Obx(() {
        final images = controller.imageAttachmentJson[key] ?? [];
        final bool hasImages = images.isNotEmpty;

        // ---------------- STATE 1: NO IMAGES (Large Add Button) ----------------
        if (!hasImages) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label Row
              Row(
                children: [
                  const Icon(
                    Icons.label,
                    size: 12,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      key.replaceAll("_", " ").toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(), // Pushes value to center/bottom or distributes space

              // Value Row
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEFF6FF),
                    ),
                    child: const Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),

              const Spacer(), // Ensures button stays at bottom

              // Add Button
              SizedBox(
                width: double.infinity,
                height: 36, // Slightly compact for grid
                child: OutlinedButton.icon(
                  onPressed: () => _pickImages(key),
                  icon: const Icon(CupertinoIcons.add_circled_solid, size: 16),
                  label: Text(
                    "Add Images",
                    style: GoogleFonts.poppins(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // ---------------- STATE 2: HAS IMAGES (Thumbnail Strip) ----------------
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header Row (Label + Value combined)
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEFF6FF),
                  ),
                  child: const Icon(
                    Icons.circle,
                    size: 6,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key.replaceAll("_", " ").toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        value.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Image Strip
            SizedBox(
              height: 60, // Fixed height for thumbnails in grid
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  ...images.asMap().entries.map((entry) {
                    final index = entry.key;
                    final b64 = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _imageThumb(key, index, b64),
                    );
                  }).toList(),

                  // Mini Add Button
                  GestureDetector(
                    onTap: () => _pickImages(key),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
  // ================= IMAGE THUMB =================

  Widget _imageThumb(String key, int index, String b64) {
    final bytes = base64Decode(b64);

    return Stack(
      children: [
        Container(
          width: 70,
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MyColors.baseBlue.withAlpha(50)),
            image: DecorationImage(
              image: MemoryImage(bytes),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: CircleAvatar(
              radius: 10,
              child: Text(
                "${index + 1}",
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: MyColors.white1,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: GestureDetector(
            onTap: () {
              controller.imageAttachmentJson[key]!.removeAt(index);
              controller.imageAttachmentJson.refresh();
            },
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages(String key) async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    for (final img in images) {
      final bytes = await File(img.path).readAsBytes();
      final b64 = base64Encode(bytes);

      controller.imageAttachmentJson[key]!.add(b64);
    }

    controller.imageAttachmentJson.refresh();
  }
}
