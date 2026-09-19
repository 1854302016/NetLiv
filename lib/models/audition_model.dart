class AuditionCall {
  final int id;
  final String title;
  final String category;
  final String description;
  final String bannerUrl;
  final double registrationFee;
  final String? deadline;
  final List<String> rolesWanted;

  AuditionCall({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.bannerUrl,
    required this.registrationFee,
    this.deadline,
    this.rolesWanted = const [],
  });

  factory AuditionCall.fromJson(Map<String, dynamic> json) {
    return AuditionCall(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'all',
      description: json['description'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String? ?? '',
      registrationFee: (json['registrationFee'] as num?)?.toDouble() ?? 199.0,
      deadline: json['deadline'] as String?,
      rolesWanted: (json['rolesWanted'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class AuditionSubmissionItem {
  final int id;
  final String auditionTitle;
  final String roleCategory;
  final String? targetRole;
  final String fullName;
  final String status;
  final String statusBadge;
  final String? callbackDate;
  final String? candidateFeedback;
  final String? scriptTitle;
  final String? scriptUrl;
  final String? videoUrl;
  final List<String> headshots;
  final String submittedAt;

  AuditionSubmissionItem({
    required this.id,
    required this.auditionTitle,
    required this.roleCategory,
    this.targetRole,
    required this.fullName,
    required this.status,
    required this.statusBadge,
    this.callbackDate,
    this.candidateFeedback,
    this.scriptTitle,
    this.scriptUrl,
    this.videoUrl,
    this.headshots = const [],
    required this.submittedAt,
  });

  factory AuditionSubmissionItem.fromJson(Map<String, dynamic> json) {
    return AuditionSubmissionItem(
      id: json['id'] as int? ?? 0,
      auditionTitle: json['auditionTitle'] as String? ?? 'NetLiv Talent Hunt',
      roleCategory: json['roleCategory'] as String? ?? 'Actor',
      targetRole: json['targetRole'] as String?,
      fullName: json['fullName'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      statusBadge: json['statusBadge'] as String? ?? '⏳ Under Review',
      callbackDate: json['callbackDate'] as String?,
      candidateFeedback: json['candidateFeedback'] as String?,
      scriptTitle: json['scriptTitle'] as String?,
      scriptUrl: json['scriptUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      headshots: (json['headshots'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      submittedAt: json['submittedAt'] as String? ?? '',
    );
  }
}

class AuditionFeeInfo {
  final double registrationFee;
  final String currency;
  final bool hasPaidPass;
  final int submissionCount;

  AuditionFeeInfo({
    required this.registrationFee,
    required this.currency,
    required this.hasPaidPass,
    required this.submissionCount,
  });

  factory AuditionFeeInfo.fromJson(Map<String, dynamic> json) {
    return AuditionFeeInfo(
      registrationFee: (json['registrationFee'] as num?)?.toDouble() ?? 199.0,
      currency: json['currency'] as String? ?? 'INR',
      hasPaidPass: json['hasPaidPass'] as bool? ?? false,
      submissionCount: json['submissionCount'] as int? ?? 0,
    );
  }
}
