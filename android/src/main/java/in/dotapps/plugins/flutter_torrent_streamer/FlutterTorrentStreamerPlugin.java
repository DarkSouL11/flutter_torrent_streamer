package in.dotapps.plugins.flutter_torrent_streamer;

import android.annotation.TargetApi;
import android.util.Log;

import com.github.se_bastiaan.torrentstream.StreamStatus;
import com.github.se_bastiaan.torrentstream.Torrent;
import com.github.se_bastiaan.torrentstream.TorrentOptions;
import com.github.se_bastiaan.torrentstream.TorrentStream;
import com.github.se_bastiaan.torrentstream.listeners.TorrentListener;

import java.io.IOException;
import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterNativeView;

/** TorrentStreamerPlugin */
@TargetApi(16)
public class FlutterTorrentStreamerPlugin implements MethodCallHandler, StreamHandler {
  static private final String pluginName = "flutter_torrent_streamer";
  static private final String packagePrefix = "in.dotapps.plugins";
  static private final String channelName = packagePrefix + "/" + pluginName;
  static private Registrar registrar;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    FlutterTorrentStreamerPlugin.registrar = registrar;

    final MethodChannel methodChannel = new MethodChannel(
            registrar.messenger(), channelName);

    final EventChannel eventChannel = new EventChannel(
            registrar.messenger(), channelName + "/events");

    final FlutterTorrentStreamerPlugin instance = new FlutterTorrentStreamerPlugin();

    eventChannel.setStreamHandler(instance);
    methodChannel.setMethodCallHandler(instance);
  }

  private TorrentListener torrentListener;
  private TorrentStream torrentStream;
  private TorrentStreamServer server;
  private boolean isDownloading = false;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "init":
        initHandler((HashMap<String, Object>) call.arguments, result);
        break;
      case "start":
        startHandler(call.argument("uri"), result);
        break;
      case "stop":
        stopHandler(result);
        break;
      case "dispose":
        disposeHandler(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onListen(Object o, final EventSink eventSink) {
    torrentListener = new TorrentListener() {
      @Override
      public void onStreamPrepared(Torrent torrent) {
        // Called when torrent file/magnet meta data have been fetched
        // If auto download is disabled then this is a safe place to start download.
        eventSink.success(new EventUpdate("prepared", null).toMap());
      }

      @Override
      public void onStreamStarted(Torrent torrent) {
        // Called when torrent download starts
        eventSink.success(new EventUpdate("started", null).toMap());
      }

      @Override
      public void onStreamError(Torrent torrent, Exception e) {
        final HashMap<String, Object> data = new HashMap<>();
        data.put("message", e.getMessage());
        eventSink.success(new EventUpdate("error", data).toMap());
      }

      @Override
      public void onStreamReady(Torrent torrent) {
        // Called when enough bits have been downloaded to stream video
        final HashMap<String, Object> data = new HashMap<>();
        data.put("url", getTorrentStreamingUrl(torrent));
        eventSink.success(new EventUpdate("ready", data).toMap());
      }

      @Override
      public void onStreamProgress(Torrent torrent, StreamStatus status) {
        final HashMap<String, Object> data = new HashMap<>();
        data.put("bufferProgress", status.bufferProgress);
        data.put("downloadSpeed", status.downloadSpeed);
        data.put("progress", status.progress);
        data.put("seeds", status.seeds);
        eventSink.success(new EventUpdate("progress", data).toMap());
      }

      @Override
      public void onStreamStopped() {
        // Called when torrent has been stopped
        eventSink.success(new EventUpdate("stopped", null).toMap());
      }
    };
    torrentStream.addListener(torrentListener);
  }

  @Override
  public void onCancel(Object o) {
    torrentStream.removeListener(torrentListener);
    torrentListener = null;
  }

  private void initHandler(HashMap<String, Object> options, Result result) {
    final String saveLocation = (String) options.get("saveLocation");
    final boolean removeOnStop = (boolean) options.get("removeFilesAfterStop");

    final TorrentOptions torrentOptions = new TorrentOptions.Builder()
            .autoDownload(true)
            .saveLocation(saveLocation)
            .removeFilesAfterStop(removeOnStop)
            .build();

    torrentStream = TorrentStream.init(torrentOptions);

    final String host = "127.0.0.1";
    final int port = 8080;

    try {
      server = new TorrentStreamServer(host, port, saveLocation, torrentStream);
      server.start();
    } catch (IOException e) {
      result.error("INIT_ERROR", null, e);
    }

    Log.d(packagePrefix, "Torrent server listening to http://" +
      server.getHostname() + ":" + server.getListeningPort() + "/");

    registrar.addViewDestroyListener(new PluginRegistry.ViewDestroyListener() {
      @Override
      public boolean onViewDestroy(FlutterNativeView flutterNativeView) {
        server.stop();
        return true;
      }
    });

    result.success(null);
  }

  private void startHandler(String uri, Result result) {
    if (isDownloading) result.error("Download already in progress", null, null);

    torrentStream.startStream(uri);
    result.success(null);
  }

  private void stopHandler(Result result) {
    torrentStream.stopStream();
    isDownloading = false;
    result.success(null);
  }

  private void disposeHandler(Result result) {
    if (server != null) {
      server.stop();
    }

    if (torrentStream != null) {
      torrentStream.stopStream();
      if (torrentListener != null) {
        torrentStream.removeListener(torrentListener);
      }
    }

    result.success(null);
  }

  private String getTorrentStreamingUrl(Torrent torrent) {
    String host = server.getHostname();
    int port = server.getListeningPort();
    String fileName = torrent.getVideoFile().getName();

    return "http://" + host + ":" + port + "/" + fileName;
  }

  private class EventUpdate {
    String type;
    HashMap<String, Object> data;

    EventUpdate(String type, HashMap<String, Object> data) {
      this.type = type;
      this.data = data;
    }

    HashMap<String, Object> toMap() {
      final HashMap<String, Object> hm = new HashMap<>();
      hm.put("type", type);
      hm.put("data", data);
      return hm;
    }
  }
}
