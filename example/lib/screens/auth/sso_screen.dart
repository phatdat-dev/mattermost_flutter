import 'package:flutter/material.dart';

import '../main/home_screen.dart';

class SSOScreen extends StatefulWidget {
  const SSOScreen({super.key});

  @override
  State<SSOScreen> createState() => _SSOScreenState();
}

class _SSOScreenState extends State<SSOScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _authenticateWithSSO(String provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real implementation, this would handle SSO authentication
      // For now, we'll simulate the process
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to home screen after successful SSO
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'SSO authentication failed: $e';
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
      appBar: AppBar(
        title: const Text('Single Sign-On'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Single Sign-On',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose your authentication provider',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

            // SSO Provider Buttons
            _buildSSOButton(
              'Google',
              Icons.card_giftcard_outlined,
              Colors.red,
              () => _authenticateWithSSO('google'),
            ),
            const SizedBox(height: 12),
            _buildSSOButton(
              'Microsoft',
              Icons.business,
              Colors.blue,
              () => _authenticateWithSSO('microsoft'),
            ),
            const SizedBox(height: 12),
            _buildSSOButton(
              'SAML',
              Icons.key,
              Colors.purple,
              () => _authenticateWithSSO('saml'),
            ),
            const SizedBox(height: 12),
            _buildSSOButton(
              'LDAP',
              Icons.corporate_fare,
              Colors.orange,
              () => _authenticateWithSSO('ldap'),
            ),

            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSSOButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon),
        label: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text('Continue with $label'),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
