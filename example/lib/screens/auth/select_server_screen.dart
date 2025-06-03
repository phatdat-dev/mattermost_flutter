import 'package:flutter/material.dart';

import '../../constants/screens.dart';
import '../../services/navigation_service.dart';

class SelectServerScreen extends StatefulWidget {
  const SelectServerScreen({super.key});

  @override
  State<SelectServerScreen> createState() => _SelectServerScreenState();
}

class _SelectServerScreenState extends State<SelectServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Common Mattermost server suggestions
  final List<String> _serverSuggestions = [
    'https://community.mattermost.com',
    'https://demo.mattermost.com',
    'https://your-company.mattermost.com',
  ];

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _connectToServer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serverUrl = _serverController.text.trim();

      // In a real implementation, this would test the server connection
      await Future.delayed(const Duration(seconds: 2));

      // Simulate server validation
      if (!serverUrl.contains('mattermost')) {
        throw Exception('Invalid Mattermost server');
      }

      if (!mounted) return;

      // Navigate to login screen with the selected server
      NavigationService.pushReplacementNamed(
        Screens.login,
        arguments: {'serverUrl': serverUrl},
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to server: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectSuggestedServer(String serverUrl) {
    _serverController.text = serverUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Server'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(
                Icons.dns,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter Your Server URL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter the URL of your Mattermost server to get started.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                  hintText: 'https://your-server.mattermost.com',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter server URL';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'URL must start with http:// or https://';
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _connectToServer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Connect'),
                ),
              ),

              const SizedBox(height: 32),

              // Server suggestions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Servers:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._serverSuggestions.map(
                      (server) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.dns),
                          title: Text(server),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _selectSuggestedServer(server),
                        ),
                      ),
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
}
