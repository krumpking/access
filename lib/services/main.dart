import 'package:access/models/attendee.dart';

abstract class AttendeeRepository {
  Future<int> uploadAttendees(Attendee attendee);

  Future checkReceipt(String receipt);

  Future<List<Attendee>> getAllAttendees();
}
