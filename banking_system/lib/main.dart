import 'dart:io';
import 'dart:math';

// ─────────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────────
enum AccountType { savings, checking, fixedDeposit }

enum TransactionType { deposit, withdrawal, transfer, interest }

// ─────────────────────────────────────────────
//  TRANSACTION
// ─────────────────────────────────────────────
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime timestamp;
  final String description;
  final double balanceAfter;

  Transaction({
    required this.type,
    required this.amount,
    required this.description,
    required this.balanceAfter,
  })  : id = _generateId(),
        timestamp = DateTime.now();

  static String _generateId() {
    final rand = Random();
    return 'TXN${rand.nextInt(900000) + 100000}';
  }

  @override
  String toString() {
    final date =
        '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    final sign = (type == TransactionType.deposit ||
        type == TransactionType.interest)
        ? '+'
        : '-';
    return '  [$id]  $date $time  ${description.padRight(30)}  '
        '${sign}${amount.toStringAsFixed(2).padLeft(10)}  '
        'Balance: ${balanceAfter.toStringAsFixed(2)}';
  }
}

// ─────────────────────────────────────────────
//  ABSTRACT ACCOUNT
// ─────────────────────────────────────────────
abstract class Account {
  final String accountNumber;
  final String ownerName;
  final AccountType type;
  double _balance;
  final List<Transaction> _transactions = [];
  final DateTime createdAt;

  Account({
    required this.ownerName,
    required this.type,
    double initialBalance = 0.0,
  })  : accountNumber = _generateAccountNumber(),
        _balance = initialBalance,
        createdAt = DateTime.now();

  static String _generateAccountNumber() {
    final rand = Random();
    return 'ACC${rand.nextInt(9000000) + 1000000}';
  }

  double get balance => _balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  // Polymorphism: subclasses override interest logic
  double get interestRate;
  String get accountTypeName;

  bool deposit(double amount, {String? note}) {
    if (amount <= 0) {
      print('  ✗ Deposit amount must be positive.');
      return false;
    }
    _balance += amount;
    _transactions.add(Transaction(
      type: TransactionType.deposit,
      amount: amount,
      description: note ?? 'Deposit',
      balanceAfter: _balance,
    ));
    print('  ✓ Deposited \$${amount.toStringAsFixed(2)} successfully.');
    return true;
  }

  bool withdraw(double amount, {String? note}) {
    if (amount <= 0) {
      print('  ✗ Withdrawal amount must be positive.');
      return false;
    }
    if (amount > _balance) {
      print('  ✗ Insufficient funds. Available: \$${_balance.toStringAsFixed(2)}');
      return false;
    }
    _balance -= amount;
    _transactions.add(Transaction(
      type: TransactionType.withdrawal,
      amount: amount,
      description: note ?? 'Withdrawal',
      balanceAfter: _balance,
    ));
    print('  ✓ Withdrew \$${amount.toStringAsFixed(2)} successfully.');
    return true;
  }

  void applyInterest() {
    final interest = _balance * interestRate;
    _balance += interest;
    _transactions.add(Transaction(
      type: TransactionType.interest,
      amount: interest,
      description: 'Interest (${(interestRate * 100).toStringAsFixed(1)}%)',
      balanceAfter: _balance,
    ));
    print('  ✓ Interest of \$${interest.toStringAsFixed(2)} applied.');
  }

  void printSummary() {
    print('  Account No : $accountNumber');
    print('  Owner      : $ownerName');
    print('  Type       : $accountTypeName');
    print('  Balance    : \$${_balance.toStringAsFixed(2)}');
    print('  Interest   : ${(interestRate * 100).toStringAsFixed(1)}% p.a.');
    final created =
        '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
    print('  Opened     : $created');
  }

  void printStatement() {
    print('  ${'─' * 90}');
    print('  ACCOUNT STATEMENT — $accountNumber ($ownerName)');
    print('  ${'─' * 90}');
    if (_transactions.isEmpty) {
      print('  No transactions found.');
    } else {
      for (final t in _transactions) {
        print(t);
      }
    }
    print('  ${'─' * 90}');
    print('  Current Balance: \$${_balance.toStringAsFixed(2)}');
  }
}

// ─────────────────────────────────────────────
//  SAVINGS ACCOUNT  (inheritance)
// ─────────────────────────────────────────────
class SavingsAccount extends Account {
  final double minimumBalance;

  SavingsAccount({
    required String ownerName,
    double initialBalance = 0.0,
    this.minimumBalance = 100.0,
  }) : super(ownerName: ownerName, type: AccountType.savings, initialBalance: initialBalance);

  @override
  double get interestRate => 0.035; // 3.5%

  @override
  String get accountTypeName => 'Savings';

  @override
  bool withdraw(double amount, {String? note}) {
    if (_balance - amount < minimumBalance) {
      print('  ✗ Cannot drop below minimum balance of \$${minimumBalance.toStringAsFixed(2)}.');
      return false;
    }
    return super.withdraw(amount, note: note);
  }
}

// ─────────────────────────────────────────────
//  CHECKING ACCOUNT  (inheritance)
// ─────────────────────────────────────────────
class CheckingAccount extends Account {
  double overdraftLimit;

  CheckingAccount({
    required String ownerName,
    double initialBalance = 0.0,
    this.overdraftLimit = 500.0,
  }) : super(ownerName: ownerName, type: AccountType.checking, initialBalance: initialBalance);

  @override
  double get interestRate => 0.01; // 1%

  @override
  String get accountTypeName => 'Checking';

  @override
  bool withdraw(double amount, {String? note}) {
    if (amount <= 0) {
      print('  ✗ Withdrawal amount must be positive.');
      return false;
    }
    if (amount > _balance + overdraftLimit) {
      print('  ✗ Exceeds overdraft limit. Max withdrawal: '
          '\$${(_balance + overdraftLimit).toStringAsFixed(2)}');
      return false;
    }
    _balance -= amount;
    _transactions.add(Transaction(
      type: TransactionType.withdrawal,
      amount: amount,
      description: note ?? 'Withdrawal',
      balanceAfter: _balance,
    ));
    if (_balance < 0) {
      print('  ⚠  Withdrew \$${amount.toStringAsFixed(2)} — account is now overdrawn '
          '(\$${_balance.toStringAsFixed(2)}).');
    } else {
      print('  ✓ Withdrew \$${amount.toStringAsFixed(2)} successfully.');
    }
    return true;
  }
}

// ─────────────────────────────────────────────
//  FIXED DEPOSIT ACCOUNT  (inheritance)
// ─────────────────────────────────────────────
class FixedDepositAccount extends Account {
  final int termMonths;
  final DateTime maturityDate;
  bool _matured = false;

  FixedDepositAccount({
    required String ownerName,
    required double principal,
    this.termMonths = 12,
  })  : maturityDate = DateTime.now().add(Duration(days: termMonths * 30)),
        super(ownerName: ownerName, type: AccountType.fixedDeposit, initialBalance: principal);

  @override
  double get interestRate => 0.065; // 6.5%

  @override
  String get accountTypeName => 'Fixed Deposit';

  bool get isMatured {
    if (!_matured && DateTime.now().isAfter(maturityDate)) _matured = true;
    return _matured;
  }

  @override
  bool withdraw(double amount, {String? note}) {
    if (!isMatured) {
      print('  ✗ Fixed deposit has not matured yet. Matures on '
          '${maturityDate.day}/${maturityDate.month}/${maturityDate.year}.');
      return false;
    }
    return super.withdraw(amount, note: note);
  }

  @override
  void printSummary() {
    super.printSummary();
    print('  Term       : $termMonths months');
    print('  Matures    : ${maturityDate.day}/${maturityDate.month}/${maturityDate.year}');
    print('  Status     : ${isMatured ? "✓ Matured" : "⏳ Locked"}');
  }
}

// ─────────────────────────────────────────────
//  CUSTOMER  (encapsulation)
// ─────────────────────────────────────────────
class Customer {
  final String id;
  final String name;
  final String email;
  String _pin;
  final List<Account> _accounts = [];

  Customer({
    required this.name,
    required this.email,
    required String pin,
  })  : id = _generateId(),
        _pin = pin;

  static String _generateId() {
    final rand = Random();
    return 'CUS${rand.nextInt(90000) + 10000}';
  }

  List<Account> get accounts => List.unmodifiable(_accounts);

  bool verifyPin(String pin) => _pin == pin;

  void changePin(String oldPin, String newPin) {
    if (!verifyPin(oldPin)) {
      print('  ✗ Incorrect current PIN.');
      return;
    }
    _pin = newPin;
    print('  ✓ PIN changed successfully.');
  }

  void addAccount(Account account) {
    _accounts.add(account);
    print('  ✓ Account ${account.accountNumber} opened for $name.');
  }

  Account? findAccount(String accountNumber) {
    try {
      return _accounts.firstWhere((a) => a.accountNumber == accountNumber);
    } catch (_) {
      return null;
    }
  }

  void printProfile() {
    print('  Customer ID : $id');
    print('  Name        : $name');
    print('  Email       : $email');
    print('  Accounts    : ${_accounts.length}');
    for (final a in _accounts) {
      print('    • ${a.accountNumber}  (${a.accountTypeName})  '
          '\$${a.balance.toStringAsFixed(2)}');
    }
  }
}

// ─────────────────────────────────────────────
//  BANK  (manages everything)
// ─────────────────────────────────────────────
class Bank {
  final String name;
  final Map<String, Customer> _customers = {};

  Bank(this.name);

  Customer registerCustomer(String name, String email, String pin) {
    final customer = Customer(name: name, email: email, pin: pin);
    _customers[customer.id] = customer;
    print('\n  ✓ Customer registered — ID: ${customer.id}');
    return customer;
  }

  Customer? findCustomerById(String id) => _customers[id];

  Customer? findCustomerByEmail(String email) {
    try {
      return _customers.values.firstWhere(
              (c) => c.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  bool transfer(Account from, Account to, double amount) {
    print('\n  Initiating transfer of \$${amount.toStringAsFixed(2)} …');
    if (from.withdraw(amount, note: 'Transfer to ${to.accountNumber}')) {
      to.deposit(amount, note: 'Transfer from ${from.accountNumber}');
      // Link transaction records
      print('  ✓ Transfer complete.');
      return true;
    }
    return false;
  }

  void printAllCustomers() {
    print('\n  ${'─' * 60}');
    print('  $name — Customer Registry (${_customers.length} customers)');
    print('  ${'─' * 60}');
    if (_customers.isEmpty) {
      print('  No customers registered.');
    } else {
      for (final c in _customers.values) {
        print('  ${c.id}  ${c.name.padRight(20)}  ${c.email}');
      }
    }
  }
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
String readLine(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync() ?? '';
}

double? readDouble(String prompt) {
  stdout.write(prompt);
  return double.tryParse(stdin.readLineSync() ?? '');
}

void banner(String title) {
  final line = '═' * 60;
  print('\n  $line');
  print('  ${title.toUpperCase().padLeft((60 + title.length) ~/ 2)}');
  print('  $line');
}

void pause() {
  readLine('\n  Press Enter to continue…');
}

// ─────────────────────────────────────────────
//  MAIN MENU SYSTEM
// ─────────────────────────────────────────────
void main() {
  final bank = Bank('Dart National Bank');
  Customer? session; // logged-in customer

  // ── seed demo data ──────────────────────────
  final alice = bank.registerCustomer('Alice Johnson', 'alice@example.com', '1234');
  final savings = SavingsAccount(ownerName: alice.name, initialBalance: 1500.0);
  final checking = CheckingAccount(ownerName: alice.name, initialBalance: 300.0);
  alice.addAccount(savings);
  alice.addAccount(checking);

  final bob = bank.registerCustomer('Bob Smith', 'bob@example.com', '5678');
  final bobSavings = SavingsAccount(ownerName: bob.name, initialBalance: 800.0);
  bob.addAccount(bobSavings);
  // ─────────────────────────────────────────────

  while (true) {
    if (session == null) {
      // ── GUEST MENU ──
      banner('${bank.name}  —  Welcome');
      print('''
  [1] Login
  [2] Register New Customer
  [3] Exit
''');
      final choice = readLine('  Choose: ');

      switch (choice.trim()) {
        case '1':
          final email = readLine('  Email       : ');
          final pin   = readLine('  PIN         : ');
          final found = bank.findCustomerByEmail(email);
          if (found == null || !found.verifyPin(pin)) {
            print('\n  ✗ Invalid email or PIN.');
          } else {
            session = found;
            print('\n  ✓ Welcome back, ${session.name}!');
          }
          pause();

        case '2':
          banner('Register');
          final name  = readLine('  Full Name   : ');
          final email = readLine('  Email       : ');
          final pin   = readLine('  Choose PIN  : ');
          final c = bank.registerCustomer(name, email, pin);
          session = c;
          pause();

        case '3':
          print('\n  Goodbye! Thank you for banking with ${bank.name}.\n');
          exit(0);

        default:
          print('\n  ✗ Invalid choice.');
          pause();
      }
    } else {
      // ── CUSTOMER MENU ──
      banner('${bank.name}  —  ${session.name}');
      print('''
  [1] View Profile & Accounts
  [2] Open New Account
  [3] Deposit
  [4] Withdraw
  [5] Transfer Between Accounts
  [6] Apply Interest
  [7] View Account Statement
  [8] Change PIN
  [9] Logout
''');
      final choice = readLine('  Choose: ');

      switch (choice.trim()) {
      // ── View Profile ──────────────────────
        case '1':
          banner('Profile');
          session.printProfile();
          pause();

      // ── Open Account ──────────────────────
        case '2':
          banner('Open Account');
          print('''
  [1] Savings        (3.5% p.a., min balance \$100)
  [2] Checking       (1.0% p.a., \$500 overdraft)
  [3] Fixed Deposit  (6.5% p.a., locked 12 months)
''');
          final type = readLine('  Account Type: ');
          final dep  = readDouble('  Initial Deposit (\$): ') ?? 0;

          switch (type.trim()) {
            case '1':
              if (dep < 100) { print('  ✗ Minimum opening deposit is \$100.'); break; }
              session.addAccount(SavingsAccount(ownerName: session.name, initialBalance: dep));
            case '2':
              session.addAccount(CheckingAccount(ownerName: session.name, initialBalance: dep));
            case '3':
              if (dep <= 0) { print('  ✗ Principal must be > 0.'); break; }
              session.addAccount(FixedDepositAccount(ownerName: session.name, principal: dep));
            default:
              print('  ✗ Invalid type.');
          }
          pause();

      // ── Deposit ───────────────────────────
        case '3':
          banner('Deposit');
          if (session.accounts.isEmpty) { print('  No accounts found.'); pause(); break; }
          for (final a in session.accounts) {
            print('  ${a.accountNumber}  (${a.accountTypeName})  \$${a.balance.toStringAsFixed(2)}');
          }
          final accNo  = readLine('\n  Account Number: ');
          final amount = readDouble('  Amount (\$)    : ') ?? -1;
          final acc    = session.findAccount(accNo);
          if (acc == null) { print('  ✗ Account not found.'); }
          else { acc.deposit(amount); }
          pause();

      // ── Withdraw ──────────────────────────
        case '4':
          banner('Withdraw');
          if (session.accounts.isEmpty) { print('  No accounts found.'); pause(); break; }
          for (final a in session.accounts) {
            print('  ${a.accountNumber}  (${a.accountTypeName})  \$${a.balance.toStringAsFixed(2)}');
          }
          final accNo  = readLine('\n  Account Number: ');
          final amount = readDouble('  Amount (\$)    : ') ?? -1;
          final acc    = session.findAccount(accNo);
          if (acc == null) { print('  ✗ Account not found.'); }
          else { acc.withdraw(amount); }
          pause();

      // ── Transfer ──────────────────────────
        case '5':
          banner('Transfer');
          if (session.accounts.length < 2) {
            print('  ✗ You need at least 2 accounts to transfer.');
            pause();
            break;
          }
          for (final a in session.accounts) {
            print('  ${a.accountNumber}  (${a.accountTypeName})  \$${a.balance.toStringAsFixed(2)}');
          }
          final fromNo = readLine('\n  From Account: ');
          final toNo   = readLine('  To Account  : ');
          final amount = readDouble('  Amount (\$)  : ') ?? -1;
          final from   = session.findAccount(fromNo);
          final to     = session.findAccount(toNo);
          if (from == null || to == null) { print('  ✗ One or both accounts not found.'); }
          else if (from == to)            { print('  ✗ Cannot transfer to the same account.'); }
          else { bank.transfer(from, to, amount); }
          pause();

      // ── Interest ──────────────────────────
        case '6':
          banner('Apply Interest');
          if (session.accounts.isEmpty) { print('  No accounts found.'); pause(); break; }
          for (final a in session.accounts) {
            print('  ${a.accountNumber}  (${a.accountTypeName})');
          }
          final accNo = readLine('\n  Account Number: ');
          final acc   = session.findAccount(accNo);
          if (acc == null) { print('  ✗ Account not found.'); }
          else { acc.applyInterest(); }
          pause();

      // ── Statement ─────────────────────────
        case '7':
          banner('Account Statement');
          if (session.accounts.isEmpty) { print('  No accounts found.'); pause(); break; }
          for (final a in session.accounts) {
            print('  ${a.accountNumber}  (${a.accountTypeName})');
          }
          final accNo = readLine('\n  Account Number: ');
          final acc   = session.findAccount(accNo);
          if (acc == null) { print('  ✗ Account not found.'); }
          else { acc.printStatement(); }
          pause();

      // ── Change PIN ────────────────────────
        case '8':
          banner('Change PIN');
          final old = readLine('  Current PIN : ');
          final neu = readLine('  New PIN     : ');
          session.changePin(old, neu);
          pause();

      // ── Logout ────────────────────────────
        case '9':
          print('\n  ✓ Logged out. Goodbye, ${session.name}!');
          session = null;
          pause();

        default:
          print('\n  ✗ Invalid choice.');
          pause();
      }
    }
  }
}
