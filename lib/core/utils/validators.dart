import 'dart:developer';

import 'package:flutter/material.dart';

abstract class Validator {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'برجاء إدخال $fieldName';
    }
    return null;
  }

  static String? Function(String? value) validateName() {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'برجاء إدخال الاسم';
      }
      if (value.trim().length < 3) {
        return 'الاسم يجب أن يكون 3 أحرف على الأقل';
      }
      return null;
    };
  }

  static String? Function(String? value) validatePhone() {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'برجاء إدخال رقم الهاتف';
      }
      final phoneRegex = RegExp(r'^[0-9+]{7,15}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return 'برجاء إدخال رقم هاتف صحيح';
      }
      return null;
    };
  }

  static String? Function(String? value) validateAddress() {
    return (value) {
      return validateRequired(value, 'العنوان');
    };
  }

  static String? Function(String? value) validateStoreName() {
    return (value) {
      return validateRequired(value, 'اسم المتجر');
    };
  }

  static String? Function(String? value) validateBarcode() {
    return (value) {
      return validateRequired(value, "الباركود");
    };
  }

  static String? Function(String? value) validateQuantaty() {
    return (value) {
      if (value == null || value.isEmpty) {
        return "ادخل الكمية المتاحة";
      }
      final quantity = int.tryParse(value);
      if (quantity == null || quantity <= 0) return "رقم غير صحيح";
      return null;
    };
  }

  static String? Function(String? value) validateBuyingPrice() {
    return (value) {
      if (value == null || value.isEmpty) {
        return "ادخل سعر الشراء";
      }
      final price = double.tryParse(value);
      if (price == null || price <= 0) {
        return "رقم غير صحيح";
      }
      return null;
    };
  }

  static String? Function(String? value) validateSellingPrice(
    TextEditingController buyingPrice,
    TextEditingController wholeSalePrice,
  ) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "ادخل سعر البيع";
      }
      final price = double.tryParse(value);
      if (price == null || price <= 0) {
        return "رقم غير صحيح";
      }
      log(buyingPrice.text);
      log(wholeSalePrice.text);
      final parsedBuyingPrice = double.tryParse(buyingPrice.text) ?? 0;
      final parsedWholesalePrice = double.tryParse(wholeSalePrice.text) ?? 0;
      log(parsedBuyingPrice.toString());
      log(parsedWholesalePrice.toString());
      if (price <= parsedBuyingPrice) {
        return "يجب أن يزيد عن سعر الشراء";
      }
      if (price <= parsedWholesalePrice) {
        return "يجب أن يزيد عن سعر الجملة";
      }
      return null;
    };
  }

  static String? Function(String? value) validateWholeSalePrice(
    TextEditingController buyingPrice,
  ) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "ادخل سعر الجملة";
      }
      final price = double.tryParse(value);
      if (price == null || price <= 0) {
        return "رقم غير صحيح";
      }
      final parsedBuyingPrice = double.tryParse(buyingPrice.text) ?? 0;
      if (price <= parsedBuyingPrice) {
        return "يجب أن يزيد عن سعر الشراء";
      }
      return null;
    };
  }
}
