import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // To get safe storage location
import 'package:path/path.dart' as p;
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // final summary = controller.sampleSummaryJson;

    // // final filteredMain = Map.fromEntries(
    // //   main.entries.where(
    // //     (e) => e.value != null && e.value.toString().trim().isNotEmpty,
    // //   ),
    // // );

    // final filteredSummary = Map.fromEntries(
    //   summary.entries.where((e) {
    //     if (e.key == "maf_date" || e.key == "maf_year" || e.key == "short")
    //       return false;
    //     final int v = e.value ?? 0;
    //     return v > 0;
    //   }),
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.calculateFilteredSummary();
    });
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
            child: GetBuilder(
                init: controller,
                id: "sample_list",
                builder: (context) {
                  if (controller.filteredSummary.entries.isEmpty) {
                    return Center(
                      child: Column(
                        spacing: 15,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                              width: 170, "assets/images/empty-box-2.png"),
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
                      itemCount: controller.filteredSummary.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        crossAxisCount: 2,
                        childAspectRatio: 1.3,
                      ),
                      itemBuilder: (context, index) {
                        var gridTiles =
                            controller.filteredSummary.entries.map((e) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (!controller.isLoading.value ||
                  controller.submitStatus.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF2563EB))),
                    const SizedBox(width: 8),
                    Text(
                      controller.submitStatus.value,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          // controller.uploadForm();
                          controller.submit();
                        },
                  child: controller.isLoading.value
                      ? CupertinoActivityIndicator()
                      : const Text("Submit"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({bool isError = false}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: isError ? MyColors.maroon : MyColors.AXMGray.withAlpha(20)),
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
      child: Stack(
        children: [
          Obx(() {
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
        ],
      ),
    );
  }

  Widget _gridStatTile(String key, dynamic value) {
    final imageMap = {
      'broken': "assets/images/broken-bottle.png",
      'neck chip': "assets/images/broken-bottle-neck.png",
      'extra dirty': "assets/images/dirty-bottle.png",
      'other brand': "assets/images/message-in-a-bottle.png",
      'other kf': "assets/images/kf.png",
      'torn bags': "assets/images/torned-bag.png",
    };
    var isTablet = Get.width > 600;

    return Obx(() {
      final images = controller.imageAttachmentJson[key] ?? [];
      final bool hasImages = images.isNotEmpty;
      final bool hasError = controller.imageErrors[key] == true;
      return Container(
        // NOTE: Removed external margin. Let the GridView's crossAxisSpacing handle gaps.
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(isError: hasError),
        child: Stack(
          children: [
            Positioned(
              right: isTablet ? 10 : 0,
              top: isTablet ? 10 : 0,
              child: Image.asset(
                imageMap[key.replaceAll("_", " ").toLowerCase()] ?? '',
                width: isTablet ? 100 : 60,
              ),
            ),

            Positioned(
                right: 0,
                top: 0,
                child: hasError
                    ? Icon(
                        Icons.broken_image_rounded,
                        color: MyColors.baseRed,
                      )
                    : SizedBox.shrink()),
            // ---------------- STATE 1: NO IMAGES (Large Add Button) ----------------
            Builder(builder: (context) {
              if (!hasImages) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label Row
                    Row(
                      children: [
                        Icon(
                          Icons.label,
                          size: isTablet ? 24 : 12,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            key.replaceAll("_", " ").toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 24 : 12,
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
                          width: isTablet ? 40 : 20,
                          height: isTablet ? 40 : 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEFF6FF),
                          ),
                          child: Icon(
                            Icons.circle,
                            size: isTablet ? 12 : 6,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 8),
                        Text(
                          value.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 32 : 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(), // Ensures button stays at bottom

                    // Add Button
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 36, // Slightly compact for grid
                    //   child: OutlinedButton.icon(
                    //     onPressed: () => _pickImages(key),
                    //     icon: const Icon(CupertinoIcons.add_circled_solid,
                    //         size: 16),
                    //     label: Text(
                    //       "Add Images",
                    //       style: GoogleFonts.poppins(fontSize: 11),
                    //     ),
                    //     style: OutlinedButton.styleFrom(
                    //       foregroundColor: const Color(0xFF2563EB),
                    //       side: const BorderSide(color: Color(0xFFE2E8F0)),
                    //       padding: EdgeInsets.zero,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    Container(
                      height: isTablet ? 100 : null,
                      width: isTablet ? 100 : null,
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: MyColors.baseBlue.withAlpha(50),
                      ),
                      child: IconButton(
                          onPressed: () => _pickImages(key),
                          icon: const Icon(CupertinoIcons.add_circled_solid,
                              color: MyColors.baseBlue, size: 16)),
                    )
                  ],
                );
              }

              // ---------------- STATE 2: HAS IMAGES (Thumbnail Strip) ----------------
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact Header Row (Label + Value combined)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isTablet ? 40 : 20,
                        height: isTablet ? 40 : 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEFF6FF),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: isTablet ? 12 : 6,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          spacing: isTablet ? 20 : 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              key.replaceAll("_", " ").toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 20 : 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              value.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 24 : 14,
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
                    height: isTablet
                        ? 100
                        : 50, // Fixed height for thumbnails in grid
                    child: Row(
                      children: [
                        Container(
                          height: isTablet ? 100 : null,
                          width: isTablet ? 100 : null,
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: MyColors.baseBlue.withAlpha(50),
                          ),
                          child: IconButton(
                              onPressed: () => _pickImages(key),
                              icon: const Icon(CupertinoIcons.add_circled_solid,
                                  color: MyColors.baseBlue, size: 16)),
                        ),
                        Flexible(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              ...images.asMap().entries.map((entry) {
                                final index = entry.key;
                                final b64 = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: _imageThumb(key, index, b64),
                                );
                              }).toList(),

                              // Mini Add Button
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            })
          ],
        ),
      );
    });
  }
  // ================= IMAGE THUMB =================

  Widget _imageThumb(String key, int index, String path) {
    ImageProvider imageProvider = FileImage(File(path));
    var isTablet = Get.width > 600;
    return Stack(
      children: [
        Container(
          width: isTablet ? 100 : 50,
          height: isTablet ? 100 : 50,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MyColors.baseBlue.withAlpha(50)),
            image: DecorationImage(
              image: imageProvider,
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
              controller.validateImages(isPartial: true);
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

  // Future<void> _pickImages(String key) async {
  //   final picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.camera);
  //   if (image != null) {
  //     final bytes = await File(image.path).readAsBytes();
  //     final b64 = base64Encode(bytes);

  //     controller.imageAttachmentJson[key]!.add(b64);

  //     controller.imageAttachmentJson.refresh();
  //     controller.validateImages(isPartial: true);
  //   }
  // }

  Future<void> _pickImages(String key) async {
    final picker = ImagePicker();

    // 1. Pick Image (Recommended: Reduce quality to save storage/bandwidth)
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();

      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${(image.path.split(".").last)}';
      final String localPath = '${directory.path}/$fileName';

      await File(image.path).copy(localPath);

      if (controller.imageAttachmentJson[key] == null) {
        controller.imageAttachmentJson[key] = [];
      }
      controller.imageAttachmentJson[key]!.add(localPath);

      controller.imageAttachmentJson.refresh();

      if (controller.imageErrors[key] == true) {
        controller.imageErrors[key] = false;
      }

      controller.validateImages(isPartial: true);
    }
  }
}
