import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Common strings
  String get appTitle => _getString('appTitle');
  String get welcome => _getString('welcome');
  String get login => _getString('login');
  String get signup => _getString('signup');
  String get email => _getString('email');
  String get password => _getString('password');
  String get name => _getString('name');
  String get role => _getString('role');
  String get patient => _getString('patient');
  String get caregiver => _getString('caregiver');
  String get clinician => _getString('clinician');
  String get admin => _getString('admin');
  String get createAccount => _getString('createAccount');
  String get haveAccount => _getString('haveAccount');
  String get noAccount => _getString('noAccount');
  String get demoAccounts => _getString('demoAccounts');
  String get signIn => _getString('signIn');
  String get signOut => _getString('signOut');
  String get error => _getString('error');
  String get success => _getString('success');
  String get warning => _getString('warning');
  String get info => _getString('info');

  String _getString(String key) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicStrings[key] ?? key;
      case 'en':
      default:
        return _englishStrings[key] ?? key;
    }
  }

  static const Map<String, String> _arabicStrings = {
    'appTitle': 'NeuroGuard',
    'welcome': 'مرحباً بك في NeuroGuard',
    'login': 'تسجيل الدخول',
    'signup': 'إنشاء حساب',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'name': 'الاسم الكامل',
    'role': 'نوع الحساب',
    'patient': 'مريض',
    'caregiver': 'مقدم رعاية',
    'clinician': 'طبيب',
    'admin': 'مدير',
    'createAccount': 'إنشاء حساب جديد',
    'haveAccount': 'لديك حساب بالفعل؟ سجل دخول',
    'noAccount': 'ليس لديك حساب؟ سجل الآن',
    'demoAccounts': 'حسابات تجريبية للاختبار',
    'signIn': 'تسجيل الدخول',
    'signOut': 'تسجيل الخروج',
    'error': 'خطأ',
    'success': 'نجح',
    'warning': 'تحذير',
    'info': 'معلومات',
  };

  static const Map<String, String> _englishStrings = {
    'appTitle': 'NeuroGuard',
    'welcome': 'Welcome to NeuroGuard',
    'login': 'Login',
    'signup': 'Sign Up',
    'email': 'Email',
    'password': 'Password',
    'name': 'Full Name',
    'role': 'Account Type',
    'patient': 'Patient',
    'caregiver': 'Caregiver',
    'clinician': 'Clinician',
    'admin': 'Admin',
    'createAccount': 'Create New Account',
    'haveAccount': 'Have an account? Sign in',
    'noAccount': 'Don\'t have an account? Sign up',
    'demoAccounts': 'Demo Accounts for Testing',
    'signIn': 'Sign In',
    'signOut': 'Sign Out',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Info',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
