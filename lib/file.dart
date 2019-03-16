import 'package:path/path.dart' as path;

class File {

    String prefix;
    bool isDir;
    String name;
    String size;
    String date;

    //图片相册索引
    int index;
    String ext;

    String key;

    bool isImage = false;
    bool isVideo = false;
    bool isMusic = false;

    File(this.isDir,this.name,this.prefix,{this.size,this.date}) {
        key = name;
        name = prefix==null?name:name.replaceFirst(prefix, '');
        if(isDir) {
            name = name.replaceAll('/', '');
        }
        else {
            ext = path.extension(name);
            switch(ext) {
                case '.jpg':
                case '.jpeg':
                case '.png':
                    isImage = true;
                    break;
                case '.mp4':
                    isVideo = true;
                    break;
                case '.mp3':
                    isMusic = true;
                    break;
            }
        }
    }

    String sizeFmt() {
        String unit = 'kb';
        double s = double.parse(size);
        s = s/1024;
        if(s > 1024) {
            s = s/1024;
            unit = 'mb';
        }
        return '${s.toStringAsFixed(2)} $unit';
    }

    String dateFmt() {
        return '2019-12-15 8:00';
    }
}