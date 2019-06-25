package in.dotapps.plugins.flutter_torrent_streamer;

import java.io.File;

import com.github.se_bastiaan.torrentstream.TorrentStream;
import fi.iki.elonen.SimpleWebServer;

public class TorrentStreamServer extends SimpleWebServer {
  private static String[] videoMimeTypes = new String[] {
    "video/x-msvideo",
    "video/x-matroska",
    "video/mp4"
  };

  private final TorrentStream stream;

  TorrentStreamServer(String host, int port, String root, TorrentStream stream) {
    super(host, port, new File(root), true);

    this.stream = stream;
    registerVideoServerPlugin();
  }

  private void registerVideoServerPlugin() {
    final VideoServerPlugin plugin = new VideoServerPlugin(stream);
    for (String mimeType: videoMimeTypes) {
      registerPluginForMimeType(null, mimeType, plugin, null);
    }
  }
}
