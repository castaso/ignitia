class SettingsModel{
  String officeStartTime;
  String officeEndTime;
  String officeNetwork;
  bool allowAutoCheckIn;
  bool alertForMissingCheckIn;
  bool alertForMissingCheckOut;
  bool alertForMissingOvertime;

  SettingsModel(
      this.officeStartTime,
      this.officeEndTime,
      this.officeNetwork,
      this.allowAutoCheckIn,
      this.alertForMissingCheckIn,
      this.alertForMissingCheckOut,
      this.alertForMissingOvertime);
}