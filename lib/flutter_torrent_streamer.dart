import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

typedef EventCallback = void Function(dynamic data);

class TorrentStreamerOptions {
  final bool removeFilesAfterStop;
  final String saveLocation;

  TorrentStreamerOptions({
    this.removeFilesAfterStop,
    this.saveLocation
  });

  Map<String, dynamic> toMap() {
    return {
      'saveLocation': saveLocation,
      'removeFilesAfterStop': removeFilesAfterStop
    };
  }
}

class TorrentStreamer {
  static final String _packagePrefix = 'in.dotapps.plugins';
  static final String _pluginName = 'flutter_torrent_streamer';

  static final String _channelName = '$_packagePrefix/$_pluginName';
  static final MethodChannel _channel = MethodChannel(_channelName);
  static final EventChannel _stream = EventChannel('$_channelName/events');

  static final Map<String, EventCallback> _listeners = {};

  static bool isInitialised = false;
  static StreamSubscription _subscription;

  /// Listen to different events emitted by Torrent Streamer.
  /// Supports 'start', 'progress', 'stop' and 'error'.
  /// type: Event type
  /// cb: Callback to invoke when event occurs
  static addEventListener(String type, EventCallback cb) {
    _checkForInitialisation();

    _initialiseListener();
    _listeners[type] = cb;
  }

  /// Initialises Torrent Streamer. Initialisation should be done before
  /// adding torrents.
  static Future<void> init([TorrentStreamerOptions options]) async {
    if (options == null) {
      options = await defaultOptions;
    }
    await _channel.invokeMethod('init', options.toMap());
    isInitialised = true;
  }

  /// Removes event handler for the specified event type
  static removeEventListener(String type) {
    _checkForInitialisation();

    _listeners.remove(type);
    if (_listeners.length == 0) removeEventListeners();
  }

  /// Removes all event listeners
  static void removeEventListeners() {
    _listeners.clear();

    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  /// Starts streaming a torrent identified by the `torrent` or `magnet` link
  /// provided by `uri` argument.
  static Future<void> start(String uri) async {
    _checkForInitialisation();

    await _channel.invokeMethod('start', { 'uri': uri });
  }

  /// Stops streaming current torrent (if there is any)
  static Future<void> stop() async {
    _checkForInitialisation();

    await _channel.invokeMethod('stop');
  }

  static void _checkForInitialisation() {
    if (!isInitialised) {
      throw new Exception('Initialise torrent streamer before using it!');
    }
  }

  /// Initialises event listeners so that dart gets updates from platform
  /// for various events like 'progress', 'start', 'stop' and 'error'.
  static void _initialiseListener() {
    if (_subscription == null) {
      _subscription = _stream.receiveBroadcastStream().listen((event) {
        final String type = event['type'];
        final data = event['data'];
        if (_listeners[type] != null) {
          _listeners[type](data);
        }
      });
    }
  }

  static Future<TorrentStreamerOptions> get defaultOptions async {
    Directory tempDir = await getTemporaryDirectory();
    return TorrentStreamerOptions(
      saveLocation: tempDir.path,
      removeFilesAfterStop: true
    );
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
