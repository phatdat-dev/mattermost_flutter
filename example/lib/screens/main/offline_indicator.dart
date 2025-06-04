/*
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';

class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _isOnline = true;
  bool _isSyncing = false;
  String _message = '';
  
  @override
  void initState() {
    super.initState();
    _listenToSyncStatus();
  }
  
  void _listenToSyncStatus() {
    AppRoutes.syncService.syncStatusStream.listen((status) {
      setState(() {
        _isOnline = status.isOnline;
        _isSyncing = status.isSyncing;
        _message = status.message;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isOnline && !_isSyncing) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      color: _isOnline ? Colors.blue : Colors.orange,
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.sync : Icons.cloud_off,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          if (_isSyncing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
*/