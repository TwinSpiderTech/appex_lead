import 'package:ts_fieldforce/service/db_helper.dart';
import 'package:ts_fieldforce/view/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ts_fieldforce/main.dart';
import 'package:intl/intl.dart';

class RouteMapScreen extends StatefulWidget {
  final int routeId;
  final String startTime;
  const RouteMapScreen({
    super.key,
    required this.routeId,
    required this.startTime,
  });

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final db = DbHelper();
  List<LatLng> _points = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  Future<void> _loadRouteData() async {
    final pointsData = await db.getPointsForRoute(widget.routeId);

    final List<LatLng> latLngs = pointsData.map((p) {
      return LatLng(p['latitude'] as double, p['longitude'] as double);
    }).toList();

    setState(() {
      _points = latLngs;
      _isLoading = false;
    });

    if (latLngs.isNotEmpty) {
      // Fit bounds after a short delay to ensure map is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final bounds = LatLngBounds.fromPoints(latLngs);
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Route Map",
              style: TextStyle(color: colorManager.textColor, fontSize: 18),
            ),
            Text(
              DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(DateTime.parse(widget.startTime)),
              style: TextStyle(
                color: colorManager.textColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: colorManager.bgDark,
        elevation: 0,
        iconTheme: IconThemeData(color: colorManager.textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _points.isEmpty
          ? _buildNoDataState()
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _points.isNotEmpty
                        ? _points.first
                        : const LatLng(0, 0),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.twinspider.ts_fieldforce',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _points,
                          color: colorManager.primaryColor,
                          strokeWidth: 5.0,
                          // isDotted: false,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // Start Marker
                        Marker(
                          point: _points.first,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                        // End Marker
                        Marker(
                          point: _points.last,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.flag,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // _buildStatsOverlay(),
              ],
            ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            color: colorManager.textColor.withOpacity(0.2),
            size: 100,
          ),
          const SizedBox(height: 16),
          Text(
            "No location points recorded for this route",
            style: TextStyle(
              color: colorManager.textColor.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorManager.bgDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorManager.primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Points", _points.length.toString()),
            Container(
              width: 1,
              height: 30,
              color: colorManager.textColor.withOpacity(0.2),
            ),
            _buildStatItem("Status", "Offline Map"),
            Container(
              width: 1,
              height: 30,
              color: colorManager.textColor.withOpacity(0.2),
            ),
            _buildStatItem("Accuracy", "High"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorManager.textColor.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colorManager.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
