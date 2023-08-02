String getDayInIndonesia(String day) {
  if (day == "Monday") {
    return "Senin";
  } else if (day == "Tuesday") {
    return "Selasa";
  } else if (day == "Wednesday") {
    return "Rabu";
  } else if (day == "Thursday") {
    return "Kamis";
  } else if (day == "Friday") {
    return "Jumat";
  } else if (day == "Saturday") {
    return "Sabtu";
  }
  return "Minggu";
}
