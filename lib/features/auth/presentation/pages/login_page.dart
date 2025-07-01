import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo and Title
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ReFab',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Textile Recycling & Women Empowerment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Toggle between Login and Register
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => isLogin = true),
                      style: TextButton.styleFrom(
                        backgroundColor: isLogin ? Theme.of(context).primaryColor : null,
                        foregroundColor: isLogin ? Colors.white : null,
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => isLogin = false),
                      style: TextButton.styleFrom(
                        backgroundColor: !isLogin ? Theme.of(context).primaryColor : null,
                        foregroundColor: !isLogin ? Colors.white : null,
                      ),
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Form
              if (isLogin) const LoginForm() else const RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}
