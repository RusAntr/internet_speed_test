// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:internet_speed_test/src/callbacks_enum.dart';
import 'package:internet_speed_test/src/connectivity_util.dart';
import 'package:internet_speed_test/src/internet_speed_test_platform_interface.dart';
import 'package:internet_speed_test/src/models/server_selection_response.dart';
import 'package:logger/web.dart';
import 'package:tuple_dart/tuple.dart';

/// An implementation of [FlutterInternetSpeedTestPlatform]
/// that uses method channels.
class MethodChannelFlutterInternetSpeedTest
    extends FlutterInternetSpeedTestPlatform {
  /// The method channel used to interact with the native platform.
  final _channel = const MethodChannel('com.tahamalas.plugin.fist/method');
  final _logger = Logger();

  Future<void> _methodCallHandler(MethodCall call) async {
    if (isLogEnabled) {
      _logger
        ..d('arguments are ${call.arguments}')
        ..d(
          'callbacks are $callbacksById',
        );
    }
    switch (call.method) {
      case 'callListener':
        if (call.arguments['id'] as int ==
            CallbacksEnum.startDownLoadTesting.index) {
          if (call.arguments['type'] == ListenerEnum.complete.index) {
            downloadSteps++;
            downloadRate +=
                int.parse((call.arguments['transferRate'] ~/ 1000).toString());
            if (isLogEnabled) {
              _logger
                ..d('download steps is $downloadSteps}')
                ..d(
                  'download steps is $downloadRate}',
                );
            }
            var average = (downloadRate ~/ downloadSteps).toDouble();
            var unit = SpeedUnit.kbps;
            average /= 1000;
            unit = SpeedUnit.mbps;
            callbacksById[call.arguments['id']]!.item3(average, unit);
            downloadSteps = 0;
            downloadRate = 0;
            callbacksById.remove(call.arguments['id']);
          } else if (call.arguments['type'] == ListenerEnum.error.index) {
            if (isLogEnabled) {
              _logger
                ..d('onError : ${call.arguments["speedTestError"]}')
                ..d(
                  'onError : ${call.arguments["errorMessage"]}',
                );
            }
            callbacksById[call.arguments['id']]!.item1(
              call.arguments['errorMessage'] as String,
              call.arguments['speedTestError'] as String,
            );
            downloadSteps = 0;
            downloadRate = 0;
            callbacksById.remove(call.arguments['id']);
          } else if (call.arguments['type'] == ListenerEnum.progress.index) {
            var rate =
                ((call.arguments['transferRate'] as num) ~/ 1000).toDouble();
            if (isLogEnabled) {
              _logger.d('rate is $rate');
            }
            if (rate != 0) downloadSteps++;
            downloadRate += rate.toInt();
            var unit = SpeedUnit.kbps;
            rate /= 1000;
            unit = SpeedUnit.mbps;
            callbacksById[call.arguments['id']]!.item2(
              (call.arguments['percent'] as num).toDouble(),
              rate,
              unit,
            );
          } else if (call.arguments['type'] == ListenerEnum.cancel.index) {
            if (isLogEnabled) {
              _logger.d('onCancel : ${call.arguments["id"]}');
            }
            callbacksById[call.arguments['id']]!.item4();
            downloadSteps = 0;
            downloadRate = 0;
            callbacksById.remove(call.arguments['id']);
          }
        } else if (call.arguments['id'] as int ==
            CallbacksEnum.startUploadTesting.index) {
          if (call.arguments['type'] == ListenerEnum.complete.index) {
            if (isLogEnabled) {
              _logger.d('onComplete : ${call.arguments['transferRate']}');
            }

            uploadSteps++;
            uploadRate +=
                int.parse((call.arguments['transferRate'] ~/ 1000).toString());
            if (isLogEnabled) {
              _logger
                ..d('download steps is $uploadSteps}')
                ..d(
                  'download steps is $uploadRate}',
                );
            }
            var average = (uploadRate ~/ uploadSteps).toDouble();
            var unit = SpeedUnit.kbps;
            average /= 1000;
            unit = SpeedUnit.mbps;
            callbacksById[call.arguments['id']]!.item3(average, unit);
            uploadSteps = 0;
            uploadRate = 0;
            callbacksById.remove(call.arguments['id']);
          } else if (call.arguments['type'] == ListenerEnum.error.index) {
            if (isLogEnabled) {
              _logger
                ..d('onError : ${call.arguments["speedTestError"]}')
                ..d(
                  'onError : ${call.arguments["errorMessage"]}',
                );
            }
            callbacksById[call.arguments['id']]!.item1(
              call.arguments['errorMessage'] as String,
              call.arguments['speedTestError'] as String,
            );
          } else if (call.arguments['type'] == ListenerEnum.progress.index) {
            var rate =
                ((call.arguments['transferRate'] as num) ~/ 1000).toDouble();
            if (isLogEnabled) {
              _logger.d('rate is $rate');
            }
            if (rate != 0) uploadSteps++;
            uploadRate += rate.toInt();
            var unit = SpeedUnit.kbps;
            rate /= 1000.0;
            unit = SpeedUnit.mbps;
            callbacksById[call.arguments['id']]!.item2(
              (call.arguments['percent'] as num).toDouble(),
              rate,
              unit,
            );
          } else if (call.arguments['type'] == ListenerEnum.cancel.index) {
            if (isLogEnabled) {
              _logger.d('onCancel : ${call.arguments["id"]}');
            }
            callbacksById[call.arguments['id']]!.item4();
            downloadSteps = 0;
            downloadRate = 0;
            callbacksById.remove(call.arguments['id']);
          }
        }
//        callbacksById[call.arguments["id"]](call.arguments["args"]);
        return;
      default:
        if (isLogEnabled) {
          _logger.d(
            'TestFairy: Ignoring invoke from native. '
            "This normally shouldn't happen.",
          );
        }
    }

    await _channel.invokeMethod('cancelListening', call.arguments['id']);
  }

  Future<CancelListening> _startListening(
    Tuple4<ErrorCallback, ProgressCallback, DoneCallback, CancelCallback>
        callback,
    CallbacksEnum callbacksEnum,
    String testServer, {
    Map<String, dynamic>? args,
    int fileSize = 10000000,
  }) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    final currentListenerId = callbacksEnum.index;
    if (isLogEnabled) {
      _logger.d('test $currentListenerId');
    }
    callbacksById[currentListenerId] = callback;
    await _channel.invokeMethod(
      'startListening',
      {
        'id': currentListenerId,
        'args': args,
        'testServer': testServer,
        'fileSize': fileSize,
      },
    );
    return () {
      _channel.invokeMethod('cancelListening', currentListenerId);
      callbacksById.remove(currentListenerId);
    };
  }

  Future<void> _toggleLog(bool value) async {
    await _channel.invokeMethod(
      'toggleLog',
      {
        'value': value,
      },
    );
  }

  @override
  Future<CancelListening> startDownloadTesting({
    required DoneCallback onDone,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required CancelCallback onCancel,
    required int fileSize,
    required String testServer,
  }) async {
    return _startListening(
      Tuple4(onError, onProgress, onDone, onCancel),
      CallbacksEnum.startDownLoadTesting,
      testServer,
      fileSize: fileSize,
    );
  }

  @override
  Future<CancelListening> startUploadTesting({
    required DoneCallback onDone,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required CancelCallback onCancel,
    required int fileSize,
    required String testServer,
  }) async {
    return _startListening(
      Tuple4(onError, onProgress, onDone, onCancel),
      CallbacksEnum.startUploadTesting,
      testServer,
      fileSize: fileSize,
    );
  }

  @override
  Future<void> toggleLog({required bool value}) async {
    logEnabled = value;
    await _toggleLog(logEnabled);
  }

  @override
  Future<ServerSelectionResponse?> getDefaultServer() async {
    try {
      final isInternetAvailable = await ConnectivityUtil.isInternetAvailable();
      if (isInternetAvailable) {
        const tag = 'token:"';
        final tokenUrl = Uri.parse('https://fast.com/app-a32983.js');
        final tokenResponse = await http.get(tokenUrl);
        if (tokenResponse.body.contains(tag)) {
          final start = tokenResponse.body.lastIndexOf(tag) + tag.length;
          final token = tokenResponse.body.substring(start, start + 32);
          final serverUrl = Uri.parse(
            'https://api.fast.com/netflix/speedtest/v2?https=true&token=$token&urlCount=5',
          );
          final serverResponse = await http.get(serverUrl);
          final serverSelectionResponse = ServerSelectionResponse.fromJson(
            json.decode(serverResponse.body) as Map<String, dynamic>,
          );
          if (serverSelectionResponse.targets != null &&
              serverSelectionResponse.targets!.isNotEmpty) {
            return serverSelectionResponse;
          }
        }
      }
    } catch (e) {
      if (logEnabled) {
        _logger.d(e);
      }
    }
    return null;
  }

  @override
  Future<bool> cancelTest() async {
    var result = false;
    try {
      result = await _channel.invokeMethod('cancelTest', {
        'id1': CallbacksEnum.startDownLoadTesting.index,
        'id2': CallbacksEnum.startUploadTesting.index,
      }) as bool;
    } on PlatformException {
      result = false;
    }
    return result;
  }
}
