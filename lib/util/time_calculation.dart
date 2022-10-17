import 'package:intl/intl.dart';

class TimeCalculation {
  static String getTimeDiff(DateTime createDate) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy.MM.dd.');
    Duration timeDiff = now.difference(createDate);
    if (timeDiff.inHours < 24) {
      if (timeDiff.inHours < 1) {
        if (timeDiff.inMinutes < 1) {
          return '방금 전';
        } else {
          return '${timeDiff.inMinutes}분 전';
        }
      } else {
        return '${timeDiff.inHours}시간 전';
      }
    } else {
      if (timeDiff.inDays > 7) {
        return '${formatter.format(createDate)}';
      } else {
        return '${timeDiff.inDays}일 전';
      }
    }
  }

  static String getToday(DateTime createDate) {
    DateFormat formatter = DateFormat('yyyy.MM.dd. HH:mm');
    var strToday = formatter.format(createDate);
    return strToday;
  }
}
