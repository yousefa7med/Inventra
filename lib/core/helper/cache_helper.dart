import 'package:Inventra/core/models/buying_invoice_model.dart';
import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/selling_invoice_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/balance_audit_entry_model.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/objectbox.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;
  CacheHelper._internal();
  static final CacheHelper _instance = CacheHelper._internal();
  factory CacheHelper() => _instance;

  Future<SharedPreferences> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences;
  }

  Future<bool> saveData({required String key, required value}) async {
    if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is double) {
      return await sharedPreferences.setDouble(key, value);
    } else {
      return await sharedPreferences.setStringList(key, value);
    }
  }

  Object? getData(String key) => sharedPreferences.get(key);

  Future<bool> removeData(String key) async =>
      await sharedPreferences.remove(key);
}

class ObjectBoxServices {
  late final Store store;
  late final Box<ProductModel> productsBox;
  late final Box<SupplierModel> suppliersBox;
  late final Box<SellingInvoiceModel> invoicesBox;
  late final Box<BuyingInvoiceModel> buyInvoicesBox;
  late final Box<CustomerModel> customersBox;
  late final Box<ExpenseModel> expensesBox;
  late final Box<SafeBalanceModel> safeBalanceBox;
  late final Box<BalanceAuditEntryModel> balanceAuditEntryBox;
  late final Box<InvoiceItemModel> sellInvoiceItemsBox;

  Future<void> init() async {
    store = await openStore();
    productsBox = store.box<ProductModel>();
    suppliersBox = store.box<SupplierModel>();
    invoicesBox = store.box<SellingInvoiceModel>();
    buyInvoicesBox = store.box<BuyingInvoiceModel>();
    customersBox = store.box<CustomerModel>();
    expensesBox = store.box<ExpenseModel>();
    safeBalanceBox = store.box<SafeBalanceModel>();
    balanceAuditEntryBox = store.box<BalanceAuditEntryModel>();
    sellInvoiceItemsBox = store.box<InvoiceItemModel>();
  }
}
