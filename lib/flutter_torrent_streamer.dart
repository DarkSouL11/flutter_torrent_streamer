import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

typedef EventCallback = void Function(dynamic data);

class TorrentStreamerOptions {
  /// If true torrent file will be deleted when stop download is called
  final bool removeFilesAfterStop;
  /// Location where torrents should be downloaded to
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

  static bool _isInitialised = false;
  static StreamSubscription _subscription;

  /// Cleans save location
  static Future<void> clean() async {
    _checkForInitialisation();

    await _channel.invokeMethod('clean');
  }

  /// Listen to different events emitted by Torrent Streamer.
  ///
  /// Supports Events:
  /// * started - When new torrent download starts
  /// * prepared - When torrent finished fetching meta data
  /// * progress - When currently downloading torrent progresses
  /// * ready - When torrent has downloaded enough data to start streaming
  /// * stopped - When currently downloading torrent is stopped
  /// * error - When torrent download encounters some error
  /// type: Event type
  /// cb: Callback to invoke when event occurs
  static addEventListener(String type, EventCallback cb) {
    _checkForInitialisation();

    _initialiseListener();
    _listeners[type] = cb;
  }

  /// Returns the url using which current torrent video file can be streamed
  static Future<String> getStreamUrl() async {
    _checkForInitialisation();

    return await _channel.invokeMethod('getStreamUrl');
  }

  /// Returns the path to downloaded torrent video
  static Future<String> getVideoPath() async {
    _checkForInitialisation();

    return await _channel.invokeMethod('getVideoPath');
  }

  /// Initialises Torrent Streamer.
  ///
  /// Initialisation should be done before adding torrents.
  static Future<void> init([TorrentStreamerOptions options]) async {
    if (_isInitialised) return;

    await dispose();
    if (options == null) {
      options = await defaultOptions;
    }
    await _channel.invokeMethod('init', options.toMap());
    _isInitialised = true;
  }

  /// Launches video in a action_view intent.
  ///
  /// Launching video while download in progress is experimental and will
  /// work only in limited set of apps
  static Future<void> launchVideo() async {
    _checkForInitialisation();

    await _channel.invokeMethod('launchVideo');
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

  /// Will destroy all event listeners and stop the server.
  ///
  /// Call it whenever the widget in which it is initialised is destroyed
  static Future<void> dispose() async {
    try {
      removeEventListeners();
      await _channel.invokeMethod('dispose');
    } catch (e) {
      print('Ignored dispose error:' + e.toString());
    }
  }

  static void _checkForInitialisation() {
    if (!_isInitialised) {
      throw new Exception('Initialise torrent streamer before using it!');
    }
  }

  /// Initialises event listeners.
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

  /// Default value used for [TorrentStreamerOptions]
  static Future<TorrentStreamerOptions> get defaultOptions async {
    Directory tempDir = await getTemporaryDirectory();
    return TorrentStreamerOptions(
      saveLocation: tempDir.path,
      removeFilesAfterStop: true
    );
  }

  /// Indicates if [TorrentStreamer] has been initialised or not
  static bool get isInitialised => _isInitialised;
}
