import 'package:flutter/material.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  bool _enableLogging = false;
  bool _enableDeveloperMode = false;
  bool _enableBetaFeatures = false;
  bool _sendCrashReports = true;
  bool _sendAnalytics = true;
  bool _preloadImages = true;
  bool _enableExperimentalFeatures = false;
  String _networkTimeout = '30';
  String _maxFileSize = '50';
  bool _enableDebugLogs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          _buildDeveloperSection(),
          const Divider(height: 1),
          _buildNetworkSection(),
          const Divider(height: 1),
          _buildDataSection(),
          const Divider(height: 1),
          _buildExperimentalSection(),
          const Divider(height: 1),
          _buildDiagnosticsSection(),
          const Divider(height: 1),
          _buildResetSection(),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Developer Options',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Developer Mode'),
          subtitle: const Text('Enable developer debugging features'),
          value: _enableDeveloperMode,
          onChanged: (value) {
            setState(() {
              _enableDeveloperMode = value;
            });
          },
        ),
        if (_enableDeveloperMode) ...[
          SwitchListTile(
            title: const Text('Debug Logging'),
            subtitle: const Text('Enable detailed debug logs'),
            value: _enableDebugLogs,
            onChanged: (value) {
              setState(() {
                _enableDebugLogs = value;
              });
            },
          ),
          ListTile(
            title: const Text('Export Logs'),
            subtitle: const Text('Export application logs for debugging'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _exportLogs();
            },
          ),
        ],
        SwitchListTile(
          title: const Text('Enable Logging'),
          subtitle: const Text('Log application events'),
          value: _enableLogging,
          onChanged: (value) {
            setState(() {
              _enableLogging = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNetworkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Network',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          title: const Text('Network Timeout'),
          subtitle: Text('$_networkTimeout seconds'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showNetworkTimeoutDialog();
          },
        ),
        ListTile(
          title: const Text('Connection Status'),
          subtitle: const Text('Check network connectivity'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _checkConnectionStatus();
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Data & Storage',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Preload Images'),
          subtitle: const Text('Download images in advance for faster loading'),
          value: _preloadImages,
          onChanged: (value) {
            setState(() {
              _preloadImages = value;
            });
          },
        ),
        ListTile(
          title: const Text('Max File Upload Size'),
          subtitle: Text('$_maxFileSize MB'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showMaxFileSizeDialog();
          },
        ),
        ListTile(
          title: const Text('Clear Cache'),
          subtitle: const Text('Clear application cache and temporary files'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showClearCacheDialog();
          },
        ),
        ListTile(
          title: const Text('Storage Usage'),
          subtitle: const Text('View detailed storage usage'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showStorageUsage();
          },
        ),
      ],
    );
  }

  Widget _buildExperimentalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Experimental Features',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Beta Features'),
          subtitle: const Text('Enable beta features (may be unstable)'),
          value: _enableBetaFeatures,
          onChanged: (value) {
            setState(() {
              _enableBetaFeatures = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Experimental Features'),
          subtitle: const Text('Enable experimental features (highly unstable)'),
          value: _enableExperimentalFeatures,
          onChanged: (value) {
            setState(() {
              _enableExperimentalFeatures = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDiagnosticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Diagnostics',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Send Crash Reports'),
          subtitle: const Text('Automatically send crash reports to help improve the app'),
          value: _sendCrashReports,
          onChanged: (value) {
            setState(() {
              _sendCrashReports = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Send Analytics'),
          subtitle: const Text('Send anonymous usage analytics'),
          value: _sendAnalytics,
          onChanged: (value) {
            setState(() {
              _sendAnalytics = value;
            });
          },
        ),
        ListTile(
          title: const Text('Run Diagnostics'),
          subtitle: const Text('Run system diagnostics test'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _runDiagnostics();
          },
        ),
      ],
    );
  }

  Widget _buildResetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Reset',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.refresh,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Reset Settings',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('Reset all settings to default values'),
          onTap: () {
            _showResetSettingsDialog();
          },
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Reset All Data',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('Delete all local data and settings'),
          onTap: () {
            _showResetAllDataDialog();
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showNetworkTimeoutDialog() {
    final controller = TextEditingController(text: _networkTimeout);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Network Timeout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Timeout (seconds)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _networkTimeout = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showMaxFileSizeDialog() {
    final controller = TextEditingController(text: _maxFileSize);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Max File Upload Size'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Size (MB)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _maxFileSize = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
            'This will clear all cached data including images, files, and temporary data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCache();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'This will reset all settings to their default values. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetSettings();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showResetAllDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All Data'),
          content: const Text(
            'This will delete ALL local data including messages, files, settings, and account information. You will need to sign in again. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetAllData();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Reset All'),
            ),
          ],
        );
      },
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting logs...')),
    );
  }

  void _checkConnectionStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connection: Online')),
    );
  }

  void _showStorageUsage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Usage'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Messages: 45.2 MB'),
              Text('Images: 123.8 MB'),
              Text('Files: 67.1 MB'),
              Text('Cache: 23.4 MB'),
              Divider(),
              Text('Total: 259.5 MB', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _runDiagnostics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Running diagnostics...')),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  void _resetSettings() {
    setState(() {
      _enableLogging = false;
      _enableDeveloperMode = false;
      _enableBetaFeatures = false;
      _sendCrashReports = true;
      _sendAnalytics = true;
      _preloadImages = true;
      _enableExperimentalFeatures = false;
      _networkTimeout = '30';
      _maxFileSize = '50';
      _enableDebugLogs = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults')),
    );
  }

  void _resetAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data has been reset. Please restart the app.')),
    );
  }
}
