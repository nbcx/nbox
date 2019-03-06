import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'util.dart';

class Oss {
	
	//验证文本域
	static String policyText = '{"expiration": "2020-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}';

	//进行utf8编码
	static List<int> policyText_utf8 = utf8.encode(policyText);

	//进行base64编码
	static String policy_base64 = base64.encode(policyText_utf8);

	//再次进行utf8编码
	static List<int> policy = utf8.encode(policy_base64);
	
	
	static String accessid= '';
	static String accesskey= '';

	//进行utf8 编码
	static List<int> key = utf8.encode(accesskey);

	//通过hmac,使用sha1进行加密
	static List<int> signature_pre  = new Hmac(sha1, key).convert(policy).bytes;

	//最后一步，将上述所得进行base64 编码
	String signature = base64.encode(signature_pre);
	
	test() {
		var goodXmlString = '''<?xml version="1.0"?>
			<bookshelf>
			  <book>
				<title lang="english">Growing a Language</title>
				<price>29.99</price>
			  </book>
			  <book>
				<title lang="english">Learning XML</title>
				<price>39.95</price>
			  </book>
			  <price>132.00</price>
			</bookshelf>''';
		Map map = xml2map(goodXmlString);
		print(map['version']);
		List array = map["bookshelf"]['book'];
		print(array[0]['title']);
	}
	
	upload() async {
		
		//要上传的文件，此处为从相册选择照片
		File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

		//dio的请求配置，这一步非常重要！
		Options options = new Options();
		options.responseType = ResponseType.PLAIN;

		//创建dio对象
		Dio dio = new Dio(options);

		//文件名
		String fileName = "uploadImage.jpg";

		//创建一个formdata，作为dio的参数
		FormData data = new FormData.from({
			'Filename': fileName,
			'key' : "test/" + fileName,//可以填写文件夹名（对应于oss服务中的文件夹）/
			'policy': policy_base64,
			'OSSAccessKeyId': accessid,
			'success_action_status' : '200', //让服务端返回200，不然，默认会返回204
			'signature': signature,
			'file': new UploadFileInfo(imageFile, "imageFileName")
		});
		
		try {
			Response response = await dio.post("https://picbox.oss-cn-beijing.aliyuncs.com",data: data);//oss的服务器地址（包含地址前缀的那一串）
			print(response.headers);
			print(response.data);
		}
		on DioError catch(e) {
			print(e.message);
			print(e.response.data);
			print(e.response.headers);
			print(e.response.request);
		}
	}
	
	list() async {
		//dio的请求配置，这一步非常重要！
		Options options = new Options();
		options.responseType = ResponseType.PLAIN;
		
		//创建dio对象
		Dio dio = new Dio(options);
		
		try {
			//https://picbox.oss-cn-beijing.aliyuncs.com
			String url = 'https://picbox.oss-cn-beijing.aliyuncs.com/?OSSAccessKeyId=LTAIjKicGfE7GxKX&Expires=1551867689&Signature=izOK%2Fg09M8Phmj79QgWR1zBMQWQ%3D';
			Response response = await dio.get(url);//oss的服务器地址（包含地址前缀的那一串）
			print("url $url");
			print(response.headers);
			print(response.data);
			Map map = xml2map(response.data);
			print(map);
			List contents = map['ListBucketResult']['Contents'];
			print(contents);
			print("key ${contents[0]['Key']}");
		}
		on DioError catch(e) {
			print(e.message);
			print(e.response.data);
			print(e.response.headers);
			print(e.response.request);
		}
	}
}