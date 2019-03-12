class Gmt {
	
	static final List weekdays = [
		'Mon','Tue','Wed','Thu','Fri','Sat','Sun'
	];
	
	static final List months =[
		'Jan','Feb','Mar','Apr','May','July','Aug','Sept','Oct','Nov','Dec'
	];
	
	static format(int millisecondsSinceEpoch) {
		DateTime now = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,isUtc: true);
		String hour = now.hour>9?now.hour.toString():"0${now.hour}";
		String minute = now.minute>9?now.minute.toString():"0${now.minute}";
		String second = now.second>9?now.second.toString():"0${now.second}";
		return "${weekdays[now.weekday-1]}, ${now.day} ${months[now.month-1]} ${now.year} $hour:$minute:$second GMT";
	}
}