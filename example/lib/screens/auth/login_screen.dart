import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';
import '../main/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill with example values for testing
    _serverController.text = 'https://your-mattermost-server.com';
    _usernameController.text = '';
    _passwordController.text = '';
    _tokenController.text = '';
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize the Mattermost client
      AppRoutes.client = MattermostClient(config: MattermostConfig(baseUrl: _serverController.text, enableDebugLogs: true));

      if (_tokenController.text.isNotEmpty) {
        // Or use token-based authentication
        await AppRoutes.client.login(token: _tokenController.text);
      } else {
        // Login with provided credentials
        await AppRoutes.client.login(loginId: _usernameController.text, password: _passwordController.text);
      }

      // Get current user information
      AppRoutes.currentUser = await AppRoutes.client.users.getMe();

      if (!mounted) return;

      // Navigate to the home screen on successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mattermost Login')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FlutterLogo(size: 80),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _serverController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'https://your-mattermost-server.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter server URL';
                      }
                      if (!value.startsWith('http')) {
                        return 'URL must start with http:// or https://';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username or Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter username or email';
                    //   }
                    //   return null;
                    // },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter password';
                    //   }
                    //   return null;
                    // },
                  ),
                  // Optional token-based authentication
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                      labelText: 'Or Login with Token (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 10) {
                        return 'Token must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
