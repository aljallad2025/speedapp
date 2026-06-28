import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'تعذر إنشاء الحساب، تأكد من البيانات');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('حساب جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.heroGradient,
                  ),
                  boxShadow: AppShadows.redGlow,
                ),
                child: const Icon(Icons.person_add_alt_1, color: AppColors.white, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'إنشاء حساب جديد',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'عبّي بياناتك بالأسفل للبدء',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.mail_outline, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الموبايل',
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.greyMedium,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.error.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12.5)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('إنشاء حساب'),
            ),
          ],
        ),
      ),
    );
  }
}