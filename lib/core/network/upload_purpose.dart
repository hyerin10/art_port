/// `POST /uploads/presign` purpose 값.
enum UploadPurpose {
  avatar('AVATAR'),
  background('BACKGROUND'),
  portfolio('PORTFOLIO'),
  verification('VERIFICATION'),
  commissionThumbnail('COMMISSION_THUMBNAIL'),
  commissionSample('COMMISSION_SAMPLE'),
  orderReference('ORDER_REFERENCE'),
  chatAttachment('CHAT_ATTACHMENT'),
  reviewImage('REVIEW_IMAGE'),
  supportAttachment('SUPPORT_ATTACHMENT');

  const UploadPurpose(this.apiValue);

  final String apiValue;
}
