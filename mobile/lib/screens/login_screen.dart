import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isRegistering = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistering) {
        await widget.authService.register(
          _usernameCtrl.text.trim(),
          _passwordCtrl.text,
        );
        if (!mounted) return;
        setState(() {
          _isRegistering = false;
          _passwordCtrl.clear();
          _confirmPasswordCtrl.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesap oluşturuldu. Şimdi giriş yapabilirsin.'),
          ),
        );
      } else {
        await widget.authService.login(
          _usernameCtrl.text.trim(),
          _passwordCtrl.text,
        );
        if (mounted) context.go('/');
      }
    } catch (error) {
      if (mounted) {
        setState(
          () =>
              _errorMessage = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegistering ? 'Hesap Oluştur' : 'Giriş Yap';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1F3864),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_city,
                      size: 60,
                      color: Color(0xFF1F3864),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bandırma Cepte',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3864),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameCtrl,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        labelText: 'Kullanıcı adı',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final username = value?.trim() ?? '';
                        if (username.length < 3) {
                          return 'Kullanıcı adı en az 3 karakter olmalı.';
                        }
                        if (username.length > 100) {
                          return 'Kullanıcı adı en fazla 100 karakter olabilir.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                      ),
                      textInputAction:
                          _isRegistering
                              ? TextInputAction.next
                              : TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isRegistering) _submit();
                      },
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) return 'Şifre boş olamaz.';
                        if (_isRegistering && password.length < 8) {
                          return 'Şifre en az 8 karakter olmalı.';
                        }
                        return null;
                      },
                    ),
                    if (_isRegistering) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Şifreyi tekrar gir',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator:
                            (value) =>
                                value != _passwordCtrl.text
                                    ? 'Şifreler eşleşmiyor.'
                                    : null,
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3864),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            _loading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _isRegistering
                                      ? 'Hesap oluştur'
                                      : 'Giriş yap',
                                  style: const TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _loading
                              ? null
                              : () => setState(() {
                                _isRegistering = !_isRegistering;
                                _errorMessage = null;
                                _formKey.currentState?.reset();
                              }),
                      child: Text(
                        _isRegistering
                            ? 'Zaten hesabın var mı? Giriş yap'
                            : 'Hesabın yok mu? Hesap oluştur',
                      ),
                    ),
                    if (!_isRegistering)
                      const Text(
                        'Varsayılan yönetici: admin / Admin123!',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
