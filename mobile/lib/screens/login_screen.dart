import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final bool adminOnly;
  const LoginScreen({
    super.key,
    required this.authService,
    this.adminOnly = false,
  });

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
        final auth = await widget.authService.login(
          _usernameCtrl.text.trim(),
          _passwordCtrl.text,
        );
        if (widget.adminOnly && !auth.isAdmin) {
          await widget.authService.logout();
          if (mounted) {
            setState(
              () =>
                  _errorMessage =
                      'Bu giriş yalnızca yönetici hesaplarına açıktır.',
            );
          }
          return;
        }
        if (mounted) context.go(auth.isAdmin ? '/admin' : '/');
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
    final title =
        widget.adminOnly
            ? 'Yönetici Girişi'
            : _isRegistering
            ? 'Hesap Oluştur'
            : 'Giriş Yap';
    return Scaffold(
      backgroundColor:
          widget.adminOnly ? const Color(0xFF0C2038) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(title),
        backgroundColor:
            widget.adminOnly
                ? const Color(0xFF0C2038)
                : const Color(0xFF1F3864),
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
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          widget.adminOnly
                              ? const Color(0xFFE6B85C)
                              : const Color(0xFFEAF3FF),
                      child: Icon(
                        widget.adminOnly
                            ? Icons.admin_panel_settings_rounded
                            : Icons.location_city,
                        size: 38,
                        color: const Color(0xFF123B5D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.adminOnly ? 'Yönetim Merkezi' : 'Bandırma Cepte',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3864),
                      ),
                    ),
                    if (widget.adminOnly) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Yetkili personel girişi',
                        style: TextStyle(color: Color(0xFF60758A)),
                      ),
                    ],
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
                    if (!widget.adminOnly)
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
                    if (!widget.adminOnly && !_isRegistering)
                      TextButton.icon(
                        onPressed:
                            _loading ? null : () => context.go('/admin-login'),
                        icon: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 18,
                        ),
                        label: const Text('Yönetici girişi'),
                      ),
                    if (widget.adminOnly)
                      TextButton(
                        onPressed: _loading ? null : () => context.go('/login'),
                        child: const Text('Kullanıcı girişine dön'),
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
