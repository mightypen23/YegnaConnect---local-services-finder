import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../storage/database_helper.dart';
import '../../models/service_request.dart';

class OfflineQueueService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void initialize(Future<void> Function(ServiceRequest request) syncCallback) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected) {
        await syncQueuedRequests(syncCallback);
      }
    });
  }

  Future<void> queueRequest(ServiceRequest request) async {
    await DatabaseHelper.instance.insertOfflineRequest(request);
  }

  Future<void> syncQueuedRequests(Future<void> Function(ServiceRequest request) syncCallback) async {
    try {
      final pendingRequests = await DatabaseHelper.instance.getOfflineRequests();
      for (final req in pendingRequests) {
        await syncCallback(req);
        await DatabaseHelper.instance.deleteOfflineRequest(req.syncToken);
      }
    } catch (_) {
      // Retain in DB if sync fails
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
