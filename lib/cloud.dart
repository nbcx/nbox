import 'dart:convert' show json;

class Cloud {

    int id;
    String name;
    String bucket;
    String endpoint;
    int enable;
    Map config;
    String key;
    String secret;

    Cloud.page(Map cloud) {
        id = cloud['id'];
        name = cloud['name'];
        bucket = cloud['bucket'];
        endpoint = cloud['endpoint'];
        enable = cloud['enable'];
        config = json.decode(cloud['config']);
        key = config['key'];
        secret = config['secret'];
    }

    String toJson() {
        return json.encode({
            "key":key,
            "secret":secret,
        });
    }
}