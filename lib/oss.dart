import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'util.dart';
import 'gmt.dart';
import 'sqlite.dart';
import 'cloud.dart';
import 'event_bus.dart';

class Oss {

	String name;
	String key;
	String secret;
	String endpoint;
	String bucketName;

	//私有构造函数
	Oss._internal();

	//保存单例
	static Oss _singleton = new Oss._internal();

	//工厂构造函数
	factory Oss()=> _singleton;
	
	Future<void> init() async {
		await _init();
		bus.on("oss.updateAccount", (args) {
			_init();
		});
	}

	_init() async {
		Map oss = await db.get("select * from cloud where enable=1");
		if(oss == null) {
			return;
		}
		name = oss['name'];
		bucketName = oss['bucket'];
		endpoint = oss['endpoint'];
		Map conf = json.decode(oss['config']);
		key  = conf['key'];
		secret  = conf['secret'];
	}


	bool get have {
		return name != null;
	}

	changeBucket(Map bucket) {
		bucketName = bucket['name'];
		endpoint = bucket['endpoint'];
	}

	changeAccount(Cloud cloud) {
		bucketName = cloud.name;
		endpoint   = cloud.endpoint;
		key = cloud.key;
		secret = cloud.secret;
		bucketName = cloud.bucket;
	}
	
	//获取使用账号下的所有buckets
	Future<Map> buckets() async{
		//创建dio对象
		Dio dio = new Dio();
		Map returns = Map();
		try {
			Response response = await dio.get(
				"https://$endpoint",
				options: headerSign()
			);
			Map map = xml2map(response.data);
			print(map);
			returns['code'] = 0;
			returns['bucket'] = map['ListAllMyBucketsResult']['Buckets']['Bucket'];
		}
		on DioError catch(e) {
			print(e.message);
			print(e.response.data);
			print(e.response.headers);
			print(e.response.request);
		}
		return returns;
	}

	Future<Map> bucket({String prefix,String delimiter='/',int maxKeys=1000,String marker}) async {
		//创建dio对象
		Dio dio = new Dio();
		Map returns = Map();
		String url = "https://$bucketName.$endpoint?max-keys=$maxKeys";
		try {
			if(delimiter != null) {
				url ="$url&delimiter=$delimiter";
			}
			if(prefix != null) {
				url ="$url&prefix=$prefix";
			}
			print("oss bucket marker $marker");
			if(marker != null) {
				url ="$url&marker=$marker";
			}
			print(url);
			Response response = await dio.get(url,
				options: headerSign(args: bucketName)
			);
			Map map = xml2map(response.data);
			print(map);
			returns['code'] = 0;

			returns['contents'] = map['ListBucketResult']['Contents']??[];
			if(returns['contents'] is Map) {
				returns['contents'] = [returns['contents']];
			}
			returns['commonPrefixes'] = map['ListBucketResult']['CommonPrefixes']??[];
			if(returns['commonPrefixes'] is Map) {
				returns['commonPrefixes'] = [returns['commonPrefixes']];
			}
			returns['more'] =  map['ListBucketResult']['IsTruncated'] == 'true';
			returns['marker'] =  returns['more']?map['ListBucketResult']['NextMarker']:null;
			returns['prefix'] =  map['ListBucketResult']['Prefix'];
			
			return returns;
		}
		on DioError catch(e) {
			return _error(e,returns);
		}
	}
	
	Map _error(DioError e,Map returns) {
		print(e.message);
		Map map = xml2map(e.response.data);
		if(map.containsKey('Error')) {
			returns['code'] = map['Error']['Code'];
			returns['message'] = map['Error']['Message'];
		}
		print(e.response.data);
		print(e.response.headers);
		print(e.response.request);
		return returns;
	}
	
	Options headerSign({String args}) {
		String gmt = Gmt.format(DateTime.now().millisecondsSinceEpoch+10*1000);//'Tue, 12 Mar 2019 05:11:16 GMT';//DateTime.now().toIso8601String();
		if(args == null) {
			args = '/';
		}
		else {
			args = "/$args/";
		}
		String signature = base64.encode(Hmac(sha1, utf8.encode(secret)).convert(
			utf8.encode("GET\n\n\n$gmt\n$args")
		).bytes);
		
		Options options = Options(
			headers: {
				'Authorization':"OSS " + key + ":" + signature,
				'Date':gmt,
			}
		);
		return options;
	}
	
	Future<Map> upload([String path]) async {
		if(path == null) {
			path = '';
		}
		else {
			path = "$path/";
		}
		String policyBase64 = base64.encode(utf8.encode(
			'{"expiration": "2020-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}'
		));
		
		String signature = base64.encode(Hmac(sha1, utf8.encode(secret)).convert(
			utf8.encode(policyBase64)).bytes
		);
		
		//要上传的文件，此处为从相册选择照片
		File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
		
		Options options = new Options();
		options.responseType = ResponseType.PLAIN;
		//创建dio对象
		Dio dio = new Dio(options);
		//文件名
		String fileName = (DateTime.now().millisecondsSinceEpoch/1000).ceil().toString()+".jpg";
	
		FormData data = new FormData.from({
			'Filename': fileName,
			'key' : path + fileName,//可以填写文件夹名（对应于oss服务中的文件夹）/
			'policy': policyBase64,
			'OSSAccessKeyId': key,
			'success_action_status' : '200',//让服务端返回200，不然，默认会返回204
			'signature': signature,
			'file': new UploadFileInfo(imageFile, "imageFileName")
		});
		
		Map returns = Map();
		try {
			Response response = await dio.post("https://$bucketName.$endpoint",data: data);
			returns['code'] = 0;
			print(response.headers);
			print(response.data);
			return returns;
		}
		on DioError catch(e) {
			return _error(e, returns);
		}
	}
	
	Future<Map> list() async {
		//dio的请求配置，这一步非常重要！
		Options options = new Options();
		options.responseType = ResponseType.PLAIN;
		
		//创建dio对象
		Dio dio = new Dio(options);
		Map returns = {};
		try {
			String url = _signUrl();
			Response response = await dio.get(url);//oss的服务器地址（包含地址前缀的那一串）
			print(response.data);
			Map map = xml2map(response.data);
			returns['code'] = 0;
			returns['data'] = map['ListBucketResult']['Contents'];
			return returns;
		}
		on DioError catch(e) {
			print(e.message);
			Map map = xml2map(e.response.data);
			if(map.containsKey('Error')) {
				returns['code'] = map['Error']['Code'];
				returns['message'] = map['Error']['Message'];
			}
			print(e.response.data);
			print(e.response.headers);
			print(e.response.request);
			return returns;
		}
	}
	
	String _signUrl() {
		//进行utf8 编码
		List<int> key = utf8.encode(secret);

		String bucketname="picbox";
		
		
		int expire = DateTime.now().millisecondsSinceEpoch ~/1000;//(DateTime.now().millisecondsSinceEpoch/1000).ceil() + 10600;
		print("expire $expire");
		String StringToSign="GET\n\n\n$expire\n/$bucketname/";//.$file;
		//进行utf8编码
		List<int> policyText_utf8 = utf8.encode(StringToSign);//policyText
		List<int> signature_pre  = Hmac(sha1, key).convert(policyText_utf8).bytes;//policy
		String sign = base64.encode(signature_pre);
		sign = Uri.encodeFull(sign);
		print("sign $sign");
		String url="https://$endpoint?OSSAccessKeyId=$key&Expires=$expire&Signature=$sign";
		print(url);
		return url;
	}
	
}