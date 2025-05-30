import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms of Service',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Acceptance of Terms',
                      'By accessing and using this Mattermost service, you accept and agree to be bound by the terms and provision of this agreement.',
                    ),
                    _buildSection(
                      'Use License',
                      'Permission is granted to temporarily download one copy of the materials on Mattermost\'s website for personal, non-commercial transitory viewing only.',
                    ),
                    _buildSection(
                      'Disclaimer',
                      'The materials on Mattermost\'s website are provided on an \'as is\' basis. Mattermost makes no warranties, expressed or implied.',
                    ),
                    _buildSection(
                      'Limitations',
                      'In no event shall Mattermost or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit).',
                    ),
                    _buildSection(
                      'Privacy Policy',
                      'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service.',
                    ),
                    _buildSection(
                      'User Conduct',
                      'You agree not to use the service to transmit, distribute, post or submit any information concerning any other person or entity.',
                    ),
                    _buildSection(
                      'Termination',
                      'Either party may terminate this agreement at any time. Upon termination, your right to use the service will cease immediately.',
                    ),
                    _buildSection(
                      'Governing Law',
                      'These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction in which Mattermost operates.',
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Last updated: May 30, 2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Accept terms and navigate back
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
