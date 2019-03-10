import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'util.dart';
import 'session.dart';

class Oss {

	static String accessid  = Session.getString('_key');
	static String accesskey = Session.getString('_secret');
	static String domain = Session.getString('_domain');
	

	upload() async {
		//验证文本域
		String policyText = '{"expiration": "2020-01-01T12:00:00.000Z","conditions": [["content-length-range", 0, 1048576000]]}';
		//进行utf8编码
		List<int> policyText_utf8 = utf8.encode(policyText);
		//进行base64编码
		String policy_base64 = base64.encode(policyText_utf8);
		//再次进行utf8编码
		List<int> policy = utf8.encode(policy_base64);
		//进行utf8 编码
		List<int> key = utf8.encode(accesskey);
		//通过hmac,使用sha1进行加密
		List<int> signature_pre  = new Hmac(sha1, key).convert(policy).bytes;
		
		//最后一步，将上述所得进行base64 编码
		String signature = base64.encode(signature_pre);
		
		
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
			Response response = await dio.post("https://$domain",data: data);//oss的服务器地址（包含地址前缀的那一串）
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
	
	Future<List> list() async {
		//dio的请求配置，这一步非常重要！
		Options options = new Options();
		options.responseType = ResponseType.PLAIN;
		
		//创建dio对象
		Dio dio = new Dio(options);
		
		try {
			//https://picbox.oss-cn-beijing.aliyuncs.com
			//String url = 'https://$domain/?OSSAccessKeyId=LTAIjKicGfE7GxKX&Expires=1552031597&Signature=5F4sg0rdjVmoxLs1mTER68oP1GU%3D';
			String url = _signUrl();
			Response response = await dio.get(url);//oss的服务器地址（包含地址前缀的那一串）
			//print(response.data);
			Map map = xml2map(response.data);
			//print(map);
			List contents = map['ListBucketResult']['Contents'];
			//print(contents);
			print("key ${contents[0]['Key']}");
			return contents;
		}
		on DioError catch(e) {
			print(e.message);
			print(e.response.data);
			print(e.response.headers);
			print(e.response.request);
			return null;
		}
	}
	
	String _signUrl() {
		//进行utf8 编码
		List<int> key = utf8.encode(accesskey);
		print("accesskey $accesskey");

		String bucketname="picbox";

		int expire = (DateTime.now().millisecondsSinceEpoch/1000).ceil() + 3600;
		print("expire $expire");
		String StringToSign="GET\n\n\n$expire\n/$bucketname/";//.$file;
		//进行utf8编码
		List<int> policyText_utf8 = utf8.encode(StringToSign);//policyText
		List<int> signature_pre  = Hmac(sha1, key).convert(policyText_utf8).bytes;//policy
		String sign = base64.encode(signature_pre);
		print("sign $sign");
		String url="https://$domain?OSSAccessKeyId=$accessid&Expires=$expire&Signature=$sign";
		print(url);
		return url;
	}
}