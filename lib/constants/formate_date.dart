String formatDate(DateTime date)
{
  //today
  if(date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year)
    return 'Today ${date.hour > 9 ? date.hour : '0${date.hour}'}:${date.minute > 9 ? date.minute : '0${date.minute}'}';
  //yesterday
  if(date.day == DateTime.now().day - 1  && date.month == DateTime.now().month && date.year == DateTime.now().year)
    return 'Yesterday ${date.hour > 9 ? date.hour : '0${date.hour}'}:${date.minute > 9 ? date.minute : '0${date.minute}'}';

  return '  ${date.day>9?date.day : '0${date.day}'}/${date.month > 9 ? date.month : '0${date.month}'}/${date.year}  ${date.hour > 9 ? date.hour : '0${date.hour}'}:${date.minute > 9 ? date.minute : '0${date.minute}'}';
}