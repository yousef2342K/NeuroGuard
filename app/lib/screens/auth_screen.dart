import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/user_management_service.dart';
import '../utils/language_manager.dart';
import '../utils/safe_text_field.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const AuthScreen({super.key, required this.onToggleTheme});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLogin
          ? LoginWidget(
              onSwitch: () => setState(() => _isLogin = false),
              onToggleTheme: widget.onToggleTheme,
            )
          : SignupWidget(
              onSwitch: () => setState(() => _isLogin = true),
              onToggleTheme: widget.onToggleTheme,
            ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onToggleTheme;

  const LoginWidget({
    super.key,
    required this.onSwitch,
    required this.onToggleTheme,
  });

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AppState.instance.signIn(emailC.text.trim(), passC.text);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroGuard - Login'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.onToggleTheme)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and title
              const SizedBox(height: 20),
              Icon(
                Icons.health_and_safety,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to NeuroGuard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Smart Neurological Health Monitoring System',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email field
              SafeTextField(
                controller: emailC,
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              SafeTextField(
                controller: passC,
                labelText: 'Password',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscurePassword,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Login button
              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),

              // Switch to sign up
              TextButton(
                onPressed: widget.onSwitch,
                child: const Text('Don\'t have an account? Sign up'),
              ),
              const SizedBox(height: 24),

              // Demo accounts section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Demo Accounts for Testing',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildDemoButton(
                          'Patient (Sara)',
                          () {
                            AppState.instance.currentUser.value =
                                Map<String, dynamic>.from(
                                    AppState.instance.users['pt_sara']!);
                          },
                          Colors.green,
                        ),
                        _buildDemoButton(
                          'Caregiver (Mona)',
                          () {
                            AppState.instance.currentUser.value =
                                Map<String, dynamic>.from(
                                    AppState.instance.users['cg_mona']!);
                          },
                          Colors.orange,
                        ),
                        _buildDemoButton(
                          'Clinician (Dr. Ali)',
                          () {
                            AppState.instance.currentUser.value =
                                Map<String, dynamic>.from(
                                    AppState.instance.users['cl_ali']!);
                          },
                          Colors.blue,
                        ),
                        _buildDemoButton(
                          'Admin',
                          () {
                            AppState.instance.currentUser.value =
                                Map<String, dynamic>.from(
                                    AppState.instance.users['ad_admin']!);
                          },
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoButton(String text, VoidCallback onPressed, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SignupWidget extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onToggleTheme;

  const SignupWidget({
    super.key,
    required this.onSwitch,
    required this.onToggleTheme,
  });

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  String? _error;
  String role = UserManagementService.rolePatient;

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    confirmPassC.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AppState.instance
          .signUp(nameC.text.trim(), emailC.text.trim(), passC.text, role);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case UserManagementService.rolePatient:
        return Icons.person;
      case UserManagementService.roleCaregiver:
        return Icons.family_restroom;
      case UserManagementService.roleClinician:
        return Icons.medical_services;
      case UserManagementService.roleAdmin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case UserManagementService.rolePatient:
        return Colors.green;
      case UserManagementService.roleCaregiver:
        return Colors.orange;
      case UserManagementService.roleClinician:
        return Colors.blue;
      case UserManagementService.roleAdmin:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getEnglishRoleName(String role) {
    switch (role) {
      case UserManagementService.rolePatient:
        return 'Patient';
      case UserManagementService.roleCaregiver:
        return 'Caregiver';
      case UserManagementService.roleClinician:
        return 'Clinician';
      case UserManagementService.roleAdmin:
        return 'Admin';
      default:
        return role;
    }
  }

  String _getEnglishRoleDescription(String role) {
    switch (role) {
      case UserManagementService.rolePatient:
        return 'Monitor your health';
      case UserManagementService.roleCaregiver:
        return 'Care for patients';
      case UserManagementService.roleClinician:
        return 'Provide medical care';
      case UserManagementService.roleAdmin:
        return 'Manage system';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroGuard - Create Account'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.onToggleTheme)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and title
              const SizedBox(height: 20),
              Icon(
                Icons.person_add_alt_1,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Create New Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Join the NeuroGuard smart healthcare system',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Name field
              SafeTextField(
                controller: nameC,
                labelText: 'Full Name',
                prefixIcon: Icons.person_outlined,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter full name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field
              SafeTextField(
                controller: emailC,
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              SafeTextField(
                controller: passC,
                labelText: 'Password',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscurePassword,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm password field
              SafeTextField(
                controller: confirmPassC,
                labelText: 'Confirm Password',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscureConfirmPassword,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm password';
                  }
                  if (value != passC.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: role,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: UserManagementService.availableRoles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getRoleIcon(role),
                                  color: _getRoleColor(role),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _getEnglishRoleName(role),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(
                          () => role = v ?? UserManagementService.rolePatient),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Sign up button
              ElevatedButton(
                onPressed: _loading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),

              // Switch to login
              TextButton(
                onPressed: widget.onSwitch,
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
