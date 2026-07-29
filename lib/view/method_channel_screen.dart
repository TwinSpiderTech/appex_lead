import 'package:ts_fieldforce/component/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelScreen extends StatefulWidget {
  const MethodChannelScreen({super.key});

  @override
  State<MethodChannelScreen> createState() => _MethodChannelScreenState();
}

class _MethodChannelScreenState extends State<MethodChannelScreen> {
  String deviceModel = '';
  _getDeviceModel() async {
    const platform = MethodChannel('ts_fieldforce_channel');
    try {
      final String result = await platform.invokeMethod('getDeviceModel');
      if (mounted) {
        setState(() {
          deviceModel = result;
        });
      }
    } on PlatformException catch (e) {
      deviceModel = e.message.toString();
    }
  }

  // @override
  // void initState() {
  //   _getDeviceModel();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Method Channels'),
      body: Center(
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(deviceModel),
            ElevatedButton(
              onPressed: () async {
                _getDeviceModel();
              },
              child: Text('Get Device Model'),
            ),
          ],
        ),
      ),
    );
  }
}
