class Messages{
  Messages._();
  static const progressCheckAuth = "Checking Authentication...";
  static const progressInProgress = "In Progress...";

  static const errorNoRecordFound = "No record found";
  static const errorLeaveTypeEmpty = "Please select a leave type";
  static const errorDurationMin = "Duration minimum 1 hour";
  static const errorDurationMax = "Duration maximum 22 hours";
  static const errorDurationLeaveDayMin = "Duration minimum 1 day";
  static const errorDurationLeaveDayMax = "Duration maximum 10 days";
  static const errorDurationLeaveDayBalance = "Duration cross the leave balance";
  static const errorOvertimeDeleteExist = "Failed to delete overtime because of already approved";
  static const errorOvertimeModifyExist = "Failed to modify overtime because of already approved";
  static const errorLeaveDeleteExist = "Failed to delete leave because of already approved";
  static const errorLeaveModifyExist = "Failed to modify leave because of already approved";
  static const errorReasonEmpty = "Reason can not be empty";
  static const errorReasonMaxLength = "Reason required maximum 300 characters";
  static const errorHolidayNameEmpty = "Holiday name can not be empty";
  static const errorHolidayTypeEmpty = "Please select a holiday type";
  static const errorHolidayDateRange = "End date can not be before start date";
  static const errorOfficeNameEmpty = "Office name can not be empty";
  static const errorOfficeCoordinatesEmpty = "Please enter latitude and longitude";
  static const errorOfficeLatitudeRange = "Latitude must be between -90 and 90";
  static const errorOfficeLongitudeRange = "Longitude must be between -180 and 180";
  static const errorOfficeRadiusRange = "Radius must be greater than 0 meters";
  static const errorUserNameEmpty = "Please enter user email";
  static const errorPasswordEmpty = "Please enter password";
  static const errorPasswordDigit = "Password required minimum 6 characters";
  static const errorCellNoEmpty = "Cell No. can not be empty";
  static const errorCellNoDigit = "Cell No. must be 11 digit(01XXXXXXXXX)";
  static const errorNameEmpty = "Name can not be empty";
  static const errorOldPasswordEmpty = "Please enter old password";
  static const errorNewPasswordEmpty = "Please enter new password";
  static const errorConfirmPasswordMatch = "Confirm password is not matched with new password";
  static const errorNewPasswordDigit = "New password required minimum 6 characters";

  static const successRequestSent = "Request has been sent successfully";
  static const successRequestDelete = "Request has been deleted successfully";
  static const successOvertimeDelete = "Overtime has been deleted successfully";
  static const successSettingsUpdate = "Settings are updated successfully";
  static const successForgetPasswordRequest = "Your password reset request has been sent to administrator. After changed you will get another email/notification from system.";

  static const warningEndOfMonthPopup = "Please update your Attendance / Overtime / Leave as soon as possible. Otherwise it may affected on your salary...";
  static const warningNotificationCheckIn = "You didn't check in yet...";
  static const warningNotificationCheckOut = "You didn't check out yet...";
  static const warningCheckInAddress = "You are trying to check in from";
  static const warningCheckOutAddress = "You are trying to check out from";
  static const warningDoContinue = "Do you want to continue";
  static const warningLocationNotFound = "Location not found";
  static const warningCheckOutOvertime = "You have seem to do done some extra effort today";
  static const warningDoAddOvertime = "Do you want to add overtime";

  static const errorLocationRequired = "Location could not be obtained. Check-in is blocked without a valid GPS location.";
  static const errorOutsideOfficeRange = "You are not within the allowed office range. Proxy attendance is blocked.";
  static const errorOutsideHomeRange = "You are not within the allowed home range. Proxy attendance is blocked.";
  static const errorDistanceFromOffice = "Distance from the nearest office";
  static const errorDistanceFromHome = "Distance from home";
  static const unitMeters = "m";
  static const errorHomeCoordinatesRequired = "Home latitude and longitude are required when the attendance location is 'Home'.";
  static const errorHomeRadiusRange = "Home radius must be greater than 0 meters";

  static const warningFaceVerification = "Face verification is required to prevent proxy attendance";
  static const warningFaceVerificationCancel = "Face verification cancelled. Attendance is not recorded.";
  static const errorFaceNotDetected = "No face detected. Please look straight at the camera and try again.";
  static const errorMultipleFacesDetected = "Multiple faces detected. Only one person is allowed.";
  static const errorFaceTooSmall = "Face is too far from the camera. Please move closer.";
  static const errorFaceCaptureFailed = "Failed to capture your face. Please try again.";
  static const btnTextRetakeFace = "Retake";
  static const btnTextUseFace = "USE THIS PHOTO";
  static const faceVerificationTitle = "Face Verification";
  static const faceVerificationHint = "Look straight at the camera. Your photo will be verified against your registered profile.";
  static const blinkChallengeHint = "Blink now to confirm you are a real person";
  static const blinkChallengeDetected = "Blink detected. Capturing your photo...";
  static const blinkChallengeTimeout = "Blink was not detected. Please try again.";
  static const blinkChallengeSetupFailed = "Could not start live verification. Please check your connection and try again.";

  static const infoPaySlip = "You can see the current month pay-slip after salary disbursement";
  static const infoLongTapTooltip = "'LONG TAP' to view tooltip of table cell value";

}