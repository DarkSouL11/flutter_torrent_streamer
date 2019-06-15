import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_torrent_streamer');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await TorrentStreamer.platformVersion, '42');
  });
}
