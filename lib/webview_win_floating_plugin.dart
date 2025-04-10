import 'package:flutter/services.dart';
import 'dart:convert';

class WebviewWinFloatingPlugin {
  static const MethodChannel _channel = MethodChannel('webview_win_floating');

  static Future<void> registerWith(Registrar registrar) async {
    final MethodChannel channel = MethodChannel(
      'webview_win_floating',
      const StandardMethodCodec(),
      registrar.messenger,
    );

    final pluginInstance = WebviewWinFloatingPlugin();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);

    // Add JavaScript channel for logging
    final jsChannel = JavaScriptChannel(
      name: 'cookieLogger',
      onMessageReceived: (JavaScriptMessage message) {
        final data = json.decode(message.message);
        switch (data['type']) {
          case 'info':
            print('Cookie Info: ${data['message']}');
            break;
          case 'error':
            print('Cookie Error: ${data['message']}');
            break;
          case 'cookie':
            print('Cookie: ${data['name']}=${data['value']}');
            break;
          case 'summary':
            print('Cookie Summary: ${data['message']}');
            break;
        }
      },
    );

    // Register the JavaScript channel
    channel.invokeMethod('addScriptChannelByName', {'channelName': 'cookieLogger'});
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getPlatformVersion':
        return _getPlatformVersion();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'webview_win_floating for Windows doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<String> _getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version ?? 'Unknown Windows version';
  }
} 