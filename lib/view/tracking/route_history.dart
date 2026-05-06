import 'package:appex_lead/service/db_helper.dart';
import 'package:appex_lead/view/dashboard.dart';
import 'package:appex_lead/view/tracking/route_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:appex_lead/main.dart';
import 'package:hugeicons/hugeicons.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({super.key});

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  final db = DbHelper();
  List<Map<String, dynamic>> _routes = [];
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
    _checkTrackingStatus();
  }

  Future<void> _loadRoutes() async {
    final routes = await db.getAllRoutes();
    setState(() {
      _routes = routes;
    });
  }

  Future<void> _checkTrackingStatus() async {
    final isRunning = await FlutterBackgroundService().isRunning();
    setState(() {
      _isTracking = isRunning;
    });
  }

  Future<void> _toggleTracking() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();

    if (isRunning) {
      service.invoke("stopTracking");
    } else {
      await service.startService();
    }

    // Give it a moment to update
    await Future.delayed(const Duration(milliseconds: 500));
    _checkTrackingStatus();
    _loadRoutes();
  }

  Future<void> _syncRoutes() async {
    final unsyncedRoutes = _routes.where((r) => r['is_synced'] == 0 && r['status'] == 'completed').toList();
    
    if (unsyncedRoutes.isEmpty) {
      Get.snackbar("No Routes", "All completed routes are already synced.", 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.showOverlay(
      asyncFunction: () async {
        for (var route in unsyncedRoutes) {
          final points = await db.getPointsForRoute(route['id']);
          final data = {
            'route': route,
            'points': points,
          };
          
          final result = await api.syncRoute(data);
          if (result != null && result['response_status'] == 'success') {
            await db.markAsSynced(route['id']);
          }
        }
        await _loadRoutes();
      },
      loadingWidget: Center(child: CircularProgressIndicator(color: colorManager.primaryColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: AppBar(
        title: Text('Route History', style: TextStyle(color: colorManager.textColor)),
        backgroundColor: colorManager.bgDark,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _syncRoutes,
            icon: Icon(Icons.cloud_upload, color: colorManager.primaryColor),
            tooltip: "Sync All",
          ),
          IconButton(
            onPressed: _loadRoutes,
            icon: Icon(Icons.refresh, color: colorManager.textColor),
          )
        ],
      ),
      body: Column(
        children: [
          _buildTrackingStatusCard(),
          Expanded(
            child: _routes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      final route = _routes[index];
                      return _buildRouteCard(route);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorManager.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorManager.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isTracking ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedLocation01,
              color: _isTracking ? Colors.green : Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isTracking ? "Tracking is Active" : "Tracking is Stopped",
                  style: TextStyle(
                    color: colorManager.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isTracking ? "Your location is being recorded in background." : "Tap to start recording your movement.",
                  style: TextStyle(color: colorManager.textColor.withOpacity(0.6), fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: _isTracking,
            onChanged: (val) => _toggleTracking(),
            activeColor: colorManager.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedRoute01, color: colorManager.textColor.withOpacity(0.2), size: 100),
          const SizedBox(height: 16),
          Text(
            "No routes recorded yet",
            style: TextStyle(color: colorManager.textColor.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    final startTime = DateTime.parse(route['start_time']);
    final endTimeStr = route['end_time'];
    final isCompleted = route['status'] == 'completed';
    final isSynced = route['is_synced'] == 1;

    return GestureDetector(
      onTap: () {
        // Navigate to map view
        Get.to(() => RouteMapScreen(routeId: route['id'], startTime: route['start_time']));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorManager.bgLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  DateFormat('dd').format(startTime),
                  style: TextStyle(color: colorManager.primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('MMM').format(startTime).toUpperCase(),
                  style: TextStyle(color: colorManager.textColor.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Route #${route['id']}",
                    style: TextStyle(color: colorManager.textColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: colorManager.textColor.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        "${DateFormat('hh:mm a').format(startTime)}${endTimeStr != null ? ' - ${DateFormat('hh:mm a').format(DateTime.parse(endTimeStr))}' : ''}",
                        style: TextStyle(color: colorManager.textColor.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isCompleted ? "Completed" : "In Progress",
                    style: TextStyle(color: isCompleted ? Colors.blue : Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  isSynced ? Icons.cloud_done : Icons.cloud_upload_outlined,
                  color: isSynced ? Colors.green : Colors.orange,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
