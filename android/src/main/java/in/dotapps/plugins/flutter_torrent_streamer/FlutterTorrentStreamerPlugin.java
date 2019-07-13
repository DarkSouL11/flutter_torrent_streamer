package in.dotapps.plugins.flutter_torrent_streamer;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.github.se_bastiaan.torrentstream.StreamStatus;
import com.github.se_bastiaan.torrentstream.Torrent;
import com.github.se_bastiaan.torrentstream.TorrentOptions;
import com.github.se_bastiaan.torrentstream.TorrentStream;
import com.github.se_bastiaan.torrentstream.listeners.TorrentListener;
import com.github.se_bastiaan.torrentstream.utils.FileUtils;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLEncoder;
import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/** TorrentStreamerPlugin */
@TargetApi(16)
public class FlutterTorrentStreamerPlugin implements MethodCallHandler, StreamHandler {
  static private final String TAG = FlutterTorrentStreamerPlugin.class.getCanonicalName();
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
  private String saveLocation;
  private boolean isDownloading = false;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "init":
        initHandler((HashMap) call.arguments, result);
        break;
      case "start":
        startHandler(call.argument("uri"), result);
        break;
      case "stop":
        stopHandler(result);
        break;
      case "getStreamUrl":
        getStreamUrlHandler(result);
        break;
      case "getVideoPath":
        getVideoPathHandler(result);
        break;
      case "launchVideo":
        launchVideoHandler(result);
        break;
      case "clean":
        cleanHandler(result);
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
        isDownloading = true;
        // Called when torrent download starts
        eventSink.success(new EventUpdate("started", null).toMap());
      }

      @Override
      public void onStreamError(Torrent torrent, Exception e) {
        isDownloading = false;
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
        // Not correct to make `isDownloading` false when progress becomes 100 as even after
        // that torrent will be seeding, so `isDownloading` should be made false only on
        // stream stop.
        // if (status.progress == 100) isDownloading = false;
        final HashMap<String, Object> data = new HashMap<>();
        data.put("bufferProgress", status.bufferProgress);
        data.put("downloadSpeed", status.downloadSpeed);
        data.put("progress", status.progress);
        data.put("seeds", status.seeds);
        eventSink.success(new EventUpdate("progress", data).toMap());
      }

      @Override
      public void onStreamStopped() {
        isDownloading = false;
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

  private void initHandler(HashMap options, Result result) {
    final String saveLocation = (String) options.get("saveLocation");
    final boolean removeOnStop = (boolean) options.get("removeFilesAfterStop");
    final int port = (int) options.get("port");

    this.saveLocation = saveLocation;

    final TorrentOptions torrentOptions = new TorrentOptions.Builder()
      .autoDownload(true)
      .saveLocation(saveLocation)
      .removeFilesAfterStop(removeOnStop)
      .build();

    torrentStream = TorrentStream.init(torrentOptions);

    final String host = "localhost";
    try {
      server = new TorrentStreamServer(host, port, saveLocation, torrentStream);
      server.start();
    } catch (IOException e) {
      result.error("INIT_ERROR", null, e);
    }

    Log.d(packagePrefix, "Torrent server listening to http://" +
      server.getHostname() + ":" + server.getListeningPort() + "/");

    registrar.addViewDestroyListener(flutterNativeView -> {
      server.stop();
      return true;
    });

    isDownloading = false;
    result.success(null);
  }

  private void startHandler(String uri, Result result) {
    if (isDownloading) result.error("Download already in progress", null, null);

    torrentStream.startStream(uri);
    result.success(null);
  }

  private void stopHandler(Result result) {
    torrentStream.stopStream();
    result.success(null);
  }

  private void getVideoPathHandler(Result result) {
    if (isDownloading) {
      final Torrent torrent = torrentStream.getCurrentTorrent();
      result.success(torrent.getVideoFile().toURI().toString());
    } else {
      result.error("No active torrent to stream", null, null);
    }
  }

  private void getStreamUrlHandler(Result result) {
    if (isDownloading) {
      final Torrent torrent = torrentStream.getCurrentTorrent();
      result.success(getTorrentStreamingUrl(torrent));
    } else {
      result.error("No active torrent to stream", null, null);
    }
  }

  private void launchVideoHandler(Result result) {
    final Context context = getActiveContext();
    final Torrent torrent = torrentStream.getCurrentTorrent();
    final Intent intent = new Intent(Intent.ACTION_VIEW);

    if (torrent != null) {
      final float progress = torrent.getTorrentHandle().status().progress();

      if (progress != 1) {
        Log.w(TAG, "Launching video that is not yet completely downloaded is still experimental");
      }

      if (registrar.activity() == null) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      }

      intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
      intent.setDataAndType(Uri.parse(getTorrentStreamingUrl(torrent)), "video/*");

      context.startActivity(intent);
      result.success(null);
    } else {
      result.error("No active torrent to launch!", null, null);
    }
  }

  private void cleanHandler(Result result) {
    FileUtils.recursiveDelete(new File(saveLocation));
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

  private Context getActiveContext() {
    return (registrar.activity() != null) ? registrar.activity() : registrar.context();
  }

  private String getTorrentStreamingUrl(Torrent torrent) {
    String host = server.getHostname();
    int port = server.getListeningPort();

    String url = "http://" + host + ":" + port + "/" + getTorrentRelativePath(torrent);
    return encodeURI(url);
  }

  private String getTorrentRelativePath(Torrent torrent) {
    final URI saveDir = new File(saveLocation).toURI();
    final URI torrentFile = torrent.getVideoFile().toURI();
    return saveDir.relativize(torrentFile).getPath();
  }

  private  String encodeURIComponent(String url) {
    try {
      return URLEncoder.encode(url, "UTF-8")
        .replaceAll("\\+", "%20")
        .replaceAll("%21", "!")
        .replaceAll("%27", "'")
        .replaceAll("%28", "(")
        .replaceAll("%29", ")")
        .replaceAll("%7E", "~");
    } catch (UnsupportedEncodingException e) {
      // Should never occur
      return url;
    }
  }

  private String encodeURI(String url) {
    return  encodeURIComponent(url)
      .replaceAll("%3A", ":")
      .replaceAll("%2F", "/")
      .replaceAll("%3F", "?")
      .replaceAll("%3D", "=")
      .replaceAll("%26", "&");
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
