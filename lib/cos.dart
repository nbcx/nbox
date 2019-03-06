import 'dart:convert';

import 'package:crypto/crypto.dart';

class TencentCos {
	
	static bool debug = true;
	/// auth signature expired time in seconds
	static final int signExpireTimeInSeconds = 10;
	
	static final String secretId = '';
	static final String secretKey = '';
	static final String bucketHost = 'picbox-1251213374.cos.ap-chengdu.myqcloud.com/'; //<BucketName-APPID>.cos.<Region>.myqcloud.com
	
	static TencentCos _cos;
	
	TencentCos._();
	
	static TencentCos get() {
		if (_cos == null) {
			_cos = TencentCos._();
		}
		return _cos;
	}
	
	
	Future<String> bucket(String fileName, String saveDir) async {
		
		var url = '/$fileName';
		return '';
	}
	
	/// download $fileName and save to $saveDir(absolute path)
	Future<String> downloadFile(String fileName, String saveDir) async {
		/*
		var url = '/$fileName';
			final taskId = await FlutterDownloader.enqueue(
			headers: buildHeaders(url),
			url: 'https://$bucketHost$url',
			savedDir: saveDir,
			fileName: fileName,
			showNotification: false,
			openFileFromNotification: false,
		);
		return taskId;
		*/
		return '';
	}
	
	Map<String, String> buildHeaders(String url) {
		Map<String, String> headers = Map();
		headers['HOST'] = bucketHost;
		headers['Authorization'] = _auth('get', url, headers: headers);
		if(debug) {
			print(headers);
		}
		return headers;
	}
	
	String _auth(String httpMethod, String httpUrl,{Map<String, String> headers, Map<String, String> params}) {
		headers = headers ?? Map();
		params = params ?? Map();
	
		int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
		var keyTime ='$currentTimestamp;${currentTimestamp + signExpireTimeInSeconds}';
		
		headers = headers.map((key, value) => MapEntry(key.toLowerCase(), value));
		params = params.map((key, value) => MapEntry(key.toLowerCase(), value));
		List<String> headerKeys = headers.keys.toList();
		headerKeys.sort();
		var headerList = headerKeys.join(';');
		var httpHeaders = headerKeys.map((item) => '$item=${Uri.encodeFull(headers[item])}').join('&');
		List<String> paramKeys = params.keys.toList();
		paramKeys.sort();
		var urlParamList = paramKeys.join(';');
		var httpParameters = paramKeys.map((item) => '$item=${Uri.encodeFull(params[item])}').join('&');
		
	
		var signKey = new Hmac(sha1, utf8.encode(secretKey)).convert(utf8.encode(keyTime));
		String httpString ='${httpMethod.toLowerCase()}\n$httpUrl\n$httpParameters\n$httpHeaders\n';
		var httpStringData = sha1.convert(utf8.encode(httpString));
		String stringToSign = 'sha1\n$keyTime\n$httpStringData\n';
		var signature =new Hmac(sha1, utf8.encode(signKey.toString())).convert(utf8.encode(stringToSign));
		String auth ='q-sign-algorithm=sha1&q-ak=$secretId&q-sign-time=$keyTime&q-key-time=$keyTime&q-header-list=$headerList&q-url-param-list=$urlParamList&q-signature=$signature';
		
		return auth;
	}
}
