import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:examen2/core/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _hide = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_isLogin) {
        await auth.signInWithPassword(
            email: _email.text.trim(), password: _pass.text);
      } else {
        final res = await auth.signUp(
          email: _email.text.trim(),
          password: _pass.text,
          data: {'name': _name.text.trim()},
        );
        if (res.session == null && mounted) {
          showSnack(context, 'Cuenta creada. Ahora inicia sesión.');
          setState(() => _isLogin = true);
        }
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(
    BuildContext context, {
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      fillColor: isLight ? const Color(0xFFFFF1F6) : scheme.surfaceContainerHighest,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    const avatarRadius = 44.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primaryContainer, theme.scaffoldBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // TARJETA BLANCA
                        Container(
                          margin: const EdgeInsets.only(top: avatarRadius),
                          padding: const EdgeInsets.fromLTRB(
                              24, avatarRadius + 20, 24, 28),
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.white
                                : scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.18),
                                blurRadius: 32,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _form,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _isLogin ? 'Bienvenido' : 'Crear cuenta',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isLogin
                                      ? 'Inicia sesión para ver tus lugares'
                                      : 'Regístrate para guardar tus lugares',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 24),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  child: _isLogin
                                      ? const SizedBox(width: double.infinity)
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 16),
                                          child: TextFormField(
                                            controller: _name,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: _dec(
                                              context,
                                              label: 'Nombre',
                                              icon: Icons
                                                  .person_outline_rounded,
                                            ),
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                    ? 'Escribe tu nombre'
                                                    : null,
                                          ),
                                        ),
                                ),
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: _dec(
                                    context,
                                    label: 'Correo electrónico',
                                    icon: Icons.mail_outline_rounded,
                                  ),
                                  validator: (v) =>
                                      (v == null || !v.contains('@'))
                                          ? 'Escribe un correo válido'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _pass,
                                  obscureText: _hide,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  decoration: _dec(
                                    context,
                                    label: 'Contraseña',
                                    icon: Icons.lock_outline_rounded,
                                    suffix: IconButton(
                                      tooltip: _hide ? 'Mostrar' : 'Ocultar',
                                      icon: Icon(_hide
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined),
                                      onPressed: () =>
                                          setState(() => _hide = !_hide),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.length < 6)
                                      ? 'Mínimo 6 caracteres'
                                      : null,
                                ),
                                const SizedBox(height: 28),
                                FilledButton(
                                  onPressed: _loading ? null : _submit,
                                  child: _loading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white),
                                        )
                                      : Text(_isLogin
                                          ? 'Iniciar sesión'
                                          : 'Crear cuenta'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // CIRCULO CON ICONO (sobresale arriba)
                        Container(
                          width: avatarRadius * 2,
                          height: avatarRadius * 2,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLight
                                  ? Colors.white
                                  : scheme.surfaceContainerHigh,
                              width: 5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isLogin
                                ? Icons.person_rounded
                                : Icons.person_add_alt_1_rounded,
                            size: 44,
                            color: isLight ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin
                          ? '¿No tienes cuenta? Regístrate'
                          : '¿Ya tienes cuenta? Inicia sesión'),
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