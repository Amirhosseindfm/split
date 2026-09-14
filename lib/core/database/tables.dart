import 'package:drift/drift.dart';

/// همه‌ی مبالغ به‌صورت INTEGER (ریال) ذخیره می‌شوند - هرگز REAL/double.

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().unique()();
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant('سایر'))();
  TextColumn get imagePath => text().nullable()();
  TextColumn get createdBy => text().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class GroupMembers extends Table {
  TextColumn get groupId => text().references(Groups, #id)();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {groupId, userId};
}

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id)();
  TextColumn get title => text()();
  IntColumn get amountRial => integer()();
  TextColumn get splitMethod => text()(); // equal | exact | percentage | shares
  TextColumn get category => text().withDefault(const Constant('سایر'))();
  TextColumn get note => text().nullable()();
  TextColumn get receiptPath => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get createdBy => text().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// هر ردیف: یک نفر چقدر برای این هزینه پرداخت کرده (پشتیبانی چند payer).
class ExpensePayers extends Table {
  TextColumn get expenseId => text().references(Expenses, #id)();
  TextColumn get userId => text().references(Users, #id)();
  IntColumn get paidAmountRial => integer()();

  @override
  Set<Column> get primaryKey => {expenseId, userId};
}

/// هر ردیف: سهم نهایی محاسبه‌شده‌ی هر شرکت‌کننده از این هزینه.
class ExpenseShares extends Table {
  TextColumn get expenseId => text().references(Expenses, #id)();
  TextColumn get userId => text().references(Users, #id)();
  IntColumn get shareAmountRial => integer()();

  @override
  Set<Column> get primaryKey => {expenseId, userId};
}

class Settlements extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id)();
  TextColumn get fromUserId => text().references(Users, #id)();
  TextColumn get toUserId => text().references(Users, #id)();
  IntColumn get amountRial => integer()();
  DateTimeColumn get settledAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// لاگ تغییرات برای Offline-First Sync آینده (بخش 23-25 سند).
class SyncLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // insert | update | delete
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
