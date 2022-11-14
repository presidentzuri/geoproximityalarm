
class Noti {
  final String? trackid;
  final String message;
  final String time;
  final bool read;
  final String senderId;
  final String notiId;

  const Noti({
    required this.trackid,
    required this.message,
    required this.time,
    required this.read,
    required this.senderId,
    required this.notiId
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'dataId': trackid,
      'message': message,
      'time' : time,
      'read' : read,
      'senderId' :senderId,
      'notiId':notiId
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Notification{ dataId: $trackid,  message: $message, time: $time, read: $read, senderId: $senderId}';
  }
}