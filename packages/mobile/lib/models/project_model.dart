class ProjectModel {
  final String id;
  final String title;
  final String mode;
  final String aspectRatio;
  final String status;
  final String? finalVideoUrl;
  final List<StoryModel> stories;

  ProjectModel({
    required this.id,
    required this.title,
    required this.mode,
    required this.aspectRatio,
    required this.status,
    this.finalVideoUrl,
    required this.stories,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      mode: json['mode'] ?? 'STUDIO',
      aspectRatio: json['aspectRatio'] ?? 'PORTRAIT_9_16',
      status: json['status'] ?? 'DRAFT',
      finalVideoUrl: json['finalVideoUrl'],
      stories: (json['stories'] as List<dynamic>?)
              ?.map((s) => StoryModel.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class StoryModel {
  final String id;
  final String synopsis;
  final String scriptText;
  final List<ShotModel> shots;

  StoryModel({
    required this.id,
    required this.synopsis,
    required this.scriptText,
    required this.shots,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? '',
      synopsis: json['synopsis'] ?? '',
      scriptText: json['scriptText'] ?? '',
      shots: (json['shots'] as List<dynamic>?)
              ?.map((s) => ShotModel.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class ShotModel {
  final String id;
  final int sequenceIndex;
  final String sceneDescription;
  final String cameraDirection;
  final String? dialogue;
  final int durationSeconds;
  final String? keyframeImageUrl;
  final String? videoClipUrl;
  final String status;

  ShotModel({
    required this.id,
    required this.sequenceIndex,
    required this.sceneDescription,
    required this.cameraDirection,
    this.dialogue,
    required this.durationSeconds,
    this.keyframeImageUrl,
    this.videoClipUrl,
    required this.status,
  });

  factory ShotModel.fromJson(Map<String, dynamic> json) {
    return ShotModel(
      id: json['id'] ?? '',
      sequenceIndex: json['sequenceIndex'] ?? 0,
      sceneDescription: json['sceneDescription'] ?? '',
      cameraDirection: json['cameraDirection'] ?? '',
      dialogue: json['dialogue'],
      durationSeconds: json['durationSeconds'] ?? 5,
      keyframeImageUrl: json['keyframeImageUrl'],
      videoClipUrl: json['videoClipUrl'],
      status: json['status'] ?? 'PENDING',
    );
  }
}
