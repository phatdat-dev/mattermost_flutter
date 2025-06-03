import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          _buildAppInfoSection(),
          const Divider(height: 1),
          _buildVersionSection(),
          const Divider(height: 1),
          _buildLegalSection(),
          const Divider(height: 1),
          _buildSupportSection(),
          const Divider(height: 1),
          _buildDeveloperSection(),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              Icons.chat,
              size: 60,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mattermost',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open source team communication',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVersionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Version Information',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('App Version'),
          subtitle: Text(_packageInfo?.version ?? 'Loading...'),
        ),
        ListTile(
          title: const Text('Build Number'),
          subtitle: Text(_packageInfo?.buildNumber ?? 'Loading...'),
        ),
        const ListTile(
          title: Text('Server Version'),
          subtitle: Text('7.8.1'),
        ),
        const ListTile(
          title: Text('Database Version'),
          subtitle: Text('8.0.0'),
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Legal',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLegalDocument('Terms of Service', _getTermsOfService());
          },
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLegalDocument('Privacy Policy', _getPrivacyPolicy());
          },
        ),
        ListTile(
          title: const Text('Open Source Licenses'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLicenses();
          },
        ),
        ListTile(
          title: const Text('Copyright Notice'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLegalDocument('Copyright Notice', _getCopyrightNotice());
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Support',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: const Text('Help Center'),
          subtitle: const Text('Get help and documentation'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchURL('https://docs.mattermost.com');
          },
        ),
        ListTile(
          leading: Icon(
            Icons.bug_report_outlined,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: const Text('Report a Bug'),
          subtitle: const Text('Report issues and bugs'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchURL('https://github.com/mattermost/mattermost-mobile/issues');
          },
        ),
        ListTile(
          leading: Icon(
            Icons.star_outline,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: const Text('Rate the App'),
          subtitle: const Text('Rate us on the App Store'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _rateApp();
          },
        ),
      ],
    );
  }

  Widget _buildDeveloperSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Developer',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.code,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: const Text('Source Code'),
          subtitle: const Text('View the source code on GitHub'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchURL('https://github.com/mattermost/mattermost-mobile');
          },
        ),
        ListTile(
          leading: Icon(
            Icons.people_outline,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: const Text('Contributors'),
          subtitle: const Text('View all contributors'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchURL('https://github.com/mattermost/mattermost-mobile/graphs/contributors');
          },
        ),
        ListTile(
          leading: Icon(
            Icons.language,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: const Text('Website'),
          subtitle: const Text('Visit mattermost.com'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _launchURL('https://mattermost.com');
          },
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '© 2023 Mattermost, Inc. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showLegalDocument(String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Mattermost',
      applicationVersion: _packageInfo?.version ?? '1.0.0',
      applicationLegalese: '© 2023 Mattermost, Inc.',
    );
  }

  void _launchURL(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $url')),
    );
    // In a real app, you would use url_launcher package
    // launch(url);
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening App Store...')),
    );
    // In a real app, you would use in_app_review package
    // InAppReview.instance.openStoreListing();
  }

  String _getTermsOfService() {
    return '''Terms of Service

1. ACCEPTANCE OF TERMS
By using Mattermost, you agree to these Terms of Service.

2. DESCRIPTION OF SERVICE
Mattermost is a team communication platform that allows teams to collaborate through messaging, file sharing, and other features.

3. USER CONDUCT
You agree to use the service responsibly and not to:
- Violate any applicable laws or regulations
- Post harmful, offensive, or inappropriate content
- Attempt to gain unauthorized access to the service
- Interfere with the operation of the service

4. PRIVACY
Your privacy is important to us. Please review our Privacy Policy to understand how we collect and use your information.

5. INTELLECTUAL PROPERTY
The service and its content are protected by copyright and other intellectual property laws.

6. LIMITATION OF LIABILITY
Mattermost is provided "as is" without warranties of any kind.

7. TERMINATION
We may terminate your access to the service at any time for any reason.

8. CHANGES TO TERMS
We may update these terms from time to time. Continued use of the service constitutes acceptance of the updated terms.

For the complete terms, please visit our website.''';
  }

  String _getPrivacyPolicy() {
    return '''Privacy Policy

Last updated: January 1, 2023

1. INFORMATION WE COLLECT
We collect information you provide directly to us, such as when you create an account, post messages, or contact us for support.

2. HOW WE USE YOUR INFORMATION
We use the information we collect to:
- Provide and maintain our service
- Process transactions and send notifications
- Respond to your comments and questions
- Improve our service

3. INFORMATION SHARING
We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.

4. DATA SECURITY
We implement appropriate security measures to protect your personal information.

5. YOUR CHOICES
You can update your account information and preferences at any time through your account settings.

6. CONTACT US
If you have questions about this Privacy Policy, please contact us at privacy@mattermost.com.

For the complete privacy policy, please visit our website.''';
  }

  String _getCopyrightNotice() {
    return '''Copyright Notice

© 2023 Mattermost, Inc. All rights reserved.

Mattermost and the Mattermost logo are trademarks of Mattermost, Inc.

This software is licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

Third-party software and libraries used in this application may be subject to their own licenses and copyright notices.''';
  }
}
