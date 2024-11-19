import 'package:flutter/material.dart';

class SampleHomeConfigModelGenerator {
  SampleHomeConfigModelGenerator() {
    configureSampleData();
  }
  Map<String, List<SampleConfigModelItemModel>> sampleHomeConfigModel = {};

  configureSampleData() {
    //-----------------------
    sampleHomeConfigModel["Financials"] = [
      SampleConfigModelItemModel(data: "Trial Balance", icon: Icons.abc),
      SampleConfigModelItemModel(
          data: "Profit and Loss Statement", icon: Icons.money),
      SampleConfigModelItemModel(data: "Voucher Listing", icon: Icons.list),
      SampleConfigModelItemModel(
          data: "General Ledger", icon: Icons.airplane_ticket),
      SampleConfigModelItemModel(
          data: "Chart of Accounts", icon: Icons.account_balance),
    ];
    //-----------------------
    sampleHomeConfigModel["AR/AP Transaction"] = [
      SampleConfigModelItemModel(
          data: "Customer Receipts", icon: Icons.receipt),
      SampleConfigModelItemModel(
          data: "Supplier Payments", icon: Icons.payment),
      SampleConfigModelItemModel(
          data: "Set Off Unudjusted bills", icon: Icons.blinds_closed),
      SampleConfigModelItemModel(
          data: "Accounts Recievable", icon: Icons.account_box),
      SampleConfigModelItemModel(
          data: "Accounts Payable", icon: Icons.account_balance_wallet),
      SampleConfigModelItemModel(data: "Deductions", icon: Icons.access_alarm),
      SampleConfigModelItemModel(data: "Settings", icon: Icons.dark_mode),
      SampleConfigModelItemModel(data: "Supplier", icon: Icons.javascript),
    ];
    //-----------------------
    sampleHomeConfigModel["Master Definition"] = [
      SampleConfigModelItemModel(data: "Customer", icon: Icons.g_mobiledata),
      SampleConfigModelItemModel(
          data: "Supplier", icon: Icons.baby_changing_station),
      SampleConfigModelItemModel(data: "Retail Customer", icon: Icons.cabin),
      SampleConfigModelItemModel(data: "Product Master", icon: Icons.earbuds),
      SampleConfigModelItemModel(data: "Employee Master", icon: Icons.face),
      SampleConfigModelItemModel(data: "Purchase Order", icon: Icons.gamepad),
      SampleConfigModelItemModel(data: "Good Receipt", icon: Icons.hail),
      SampleConfigModelItemModel(
          data: "Purchase Bill", icon: Icons.ice_skating),
      SampleConfigModelItemModel(data: "Purchase Return", icon: Icons.kayaking),
      SampleConfigModelItemModel(data: "QC on Goods", icon: Icons.label),
    ];
  }
}

class SampleConfigModelItemModel {
  SampleConfigModelItemModel({required this.icon, required this.data}) {}

  final IconData icon;
  final String data;
}
