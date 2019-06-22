package in.dotapps.plugins.flutter_torrent_streamer;

import com.github.se_bastiaan.torrentstream.TorrentStream;

import java.io.File;

import fi.iki.elonen.SimpleWebServer;

public class TorrentStreamServer extends SimpleWebServer {
    private static String[] videoMimeTypes = new String[] {
        "video/x-msvideo",
        "mkv=video/x-matroska",
        "mp4=video/mp4"
    };

    private TorrentStream stream;

    TorrentStreamServer(String host, int port, String root, TorrentStream stream) {
        super(host, port, new File(root), true);

        registerVideoServerPlugin();
        this.stream = stream;
    }

    @Override
    public Response serve(IHTTPSession session) { return super.serve(session); }

    private void registerVideoServerPlugin() {
        final VideoServerPlugin plugin = new VideoServerPlugin(stream);
        for (String mimeType: videoMimeTypes) {
            registerPluginForMimeType(null, mimeType, plugin, null);
        }
    }
}
