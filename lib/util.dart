import 'package:xml2json/xml2json.dart';
import 'dart:convert' show json;

xml2map(String xmlstring) {
	final Xml2Json myTransformer = Xml2Json();
	myTransformer.parse(xmlstring);
	String jsonstr = myTransformer.toParker();
	Map map = json.decode(jsonstr);
	return map;
}

xml2list(String xmlstring) {
	final Xml2Json myTransformer = Xml2Json();
	myTransformer.parse(xmlstring);
	String jsonstr = myTransformer.toGData();
	List list = json.decode(jsonstr);
	return list;
}