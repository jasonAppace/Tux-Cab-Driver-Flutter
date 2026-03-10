import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import 'ride_completed_screen.dart';

enum RideStatus { assigned, started, completed }

class RideDetailScreen extends StatefulWidget {
  final String bookingId;
  final String type;
  final String date;
  final String pickup;
  final String dropoff;
  final String passengerName;

  const RideDetailScreen({
    super.key,
    required this.bookingId,
    required this.type,
    required this.date,
    required this.pickup,
    required this.dropoff,
    required this.passengerName,
  });

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  RideStatus _status = RideStatus.assigned;
  bool _isLoading = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.363947, -121.928938), // Near SJC coords for placeholder
    zoom: 14.4746,
  );

  void _updateStatus() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      if (_status == RideStatus.assigned) {
        _status = RideStatus.started;
      } else if (_status == RideStatus.started) {
        _status = RideStatus.completed;
      }
      _isLoading = false;
    });

    if (_status == RideStatus.completed) {
      Get.off(
        () => RideCompletedScreen(
          bookingId: widget.bookingId,
          pickup: widget.pickup,
          dropoff: widget.dropoff,
          passengerName: widget.passengerName,
          rent: '\$823.47', // Standard rent placeholder matching the design
        ),
      );
    }
  }

  String _getButtonText() {
    switch (_status) {
      case RideStatus.assigned:
        return 'Start Ride';
      case RideStatus.started:
        return 'End Ride';
      case RideStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ride Details - ${widget.bookingId}')),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildRideDetailsSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetailsSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _status.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.border,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.passengerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '+1 (555) 123-4567',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.phone, color: Colors.green),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.message, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          _buildLocationRow(
            Icons.my_location,
            AppColors.primary,
            'Pickup',
            widget.pickup,
          ),
          const SizedBox(height: 16),
          _buildLocationRow(
            Icons.location_on,
            Colors.blue,
            'Drop-off',
            widget.dropoff,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ride Type: ${widget.type}',
                style: const TextStyle(color: AppColors.textGrey),
              ),
              const Text(
                'Extra Waiting: 0 Hrs',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Car Assigned: ',
                style: TextStyle(color: AppColors.textGrey),
              ),
              Text(
                'Mercedes-Benz S-Class',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_status != RideStatus.completed)
            CustomButton(
              text: _getButtonText(),
              isLoading: _isLoading,
              onPressed: _updateStatus,
            ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    Color iconColor,
    String title,
    String address,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
