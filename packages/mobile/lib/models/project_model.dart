class ProjectModel {
  final String id;
  final String title;
  final String mode;
  final String aspectRatio;
  final String status;
  final String? finalVideoUrl;
  final String? visualMedium;
  final String? bgmTrack;
  final String? lutFilter;
  final List<StoryModel> stories;

  ProjectModel({
    required this.id,
    required this.title,
    required this.mode,
    required this.aspectRatio,
    required this.status,
    this.finalVideoUrl,
    this.visualMedium,
    this.bgmTrack,
    this.lutFilter,
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
      visualMedium: json['visualMedium'] ?? 'REAL_HUMAN',
      bgmTrack: json['bgmTrack'] ?? '🎻 Epic Orchestral',
      lutFilter: json['lutFilter'] ?? '🎬 Hollywood 70mm',
      stories: (json['stories'] as List<dynamic>?)
              ?.map((s) => StoryModel.fromJson(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'mode': mode,
        'aspectRatio': aspectRatio,
        'status': status,
        'finalVideoUrl': finalVideoUrl,
        'visualMedium': visualMedium,
        'bgmTrack': bgmTrack,
        'lutFilter': lutFilter,
        'stories': stories.map((s) => s.toJson()).toList(),
      };

  ProjectModel copyWith({
    String? id,
    String? title,
    String? mode,
    String? aspectRatio,
    String? status,
    String? finalVideoUrl,
    String? visualMedium,
    String? bgmTrack,
    String? lutFilter,
    List<StoryModel>? stories,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      mode: mode ?? this.mode,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      status: status ?? this.status,
      finalVideoUrl: finalVideoUrl ?? this.finalVideoUrl,
      visualMedium: visualMedium ?? this.visualMedium,
      bgmTrack: bgmTrack ?? this.bgmTrack,
      lutFilter: lutFilter ?? this.lutFilter,
      stories: stories ?? this.stories,
    );
  }
}

class CharacterModel {
  final String name;
  final String appearance;
  final String voiceStyle;
  final String? referenceImageUrl;
  final String? role;
  final String? voicePersona;
  final String? voiceId;

  CharacterModel({
    required this.name,
    required this.appearance,
    required this.voiceStyle,
    this.referenceImageUrl,
    this.role,
    this.voicePersona,
    this.voiceId,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      name: json['name'] ?? '',
      appearance: json['appearance'] ?? '',
      voiceStyle: json['voiceStyle'] ?? '',
      referenceImageUrl: json['referenceImageUrl'],
      role: json['role'] ?? 'Lead',
      voicePersona: json['voicePersona'] ?? 'Adam (Deep Authoritative)',
      voiceId: json['voiceId'] ?? 'adam_deep',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'appearance': appearance,
        'voiceStyle': voiceStyle,
        'referenceImageUrl': referenceImageUrl,
        'role': role,
        'voicePersona': voicePersona,
        'voiceId': voiceId,
      };

  CharacterModel copyWith({
    String? name,
    String? appearance,
    String? voiceStyle,
    String? referenceImageUrl,
    String? role,
    String? voicePersona,
    String? voiceId,
  }) {
    return CharacterModel(
      name: name ?? this.name,
      appearance: appearance ?? this.appearance,
      voiceStyle: voiceStyle ?? this.voiceStyle,
      referenceImageUrl: referenceImageUrl ?? this.referenceImageUrl,
      role: role ?? this.role,
      voicePersona: voicePersona ?? this.voicePersona,
      voiceId: voiceId ?? this.voiceId,
    );
  }
}

class StoryModel {
  final String id;
  final String synopsis;
  final String genre;
  final String scriptText;
  final List<CharacterModel> characters;
  final List<ShotModel> shots;

  StoryModel({
    required this.id,
    required this.synopsis,
    this.genre = 'Revenge Drama',
    required this.scriptText,
    this.characters = const [],
    required this.shots,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? '',
      synopsis: json['synopsis'] ?? '',
      genre: json['genre'] ?? 'Revenge Drama',
      scriptText: json['scriptText'] ?? '',
      characters: (json['characters'] as List<dynamic>?)
              ?.map((c) => CharacterModel.fromJson(c is Map<String, dynamic> ? c : {}))
              .toList() ??
          [],
      shots: (json['shots'] as List<dynamic>?)
              ?.map((s) => ShotModel.fromJson(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'synopsis': synopsis,
        'genre': genre,
        'scriptText': scriptText,
        'characters': characters.map((c) => c.toJson()).toList(),
        'shots': shots.map((s) => s.toJson()).toList(),
      };

  StoryModel copyWith({
    String? id,
    String? synopsis,
    String? genre,
    String? scriptText,
    List<CharacterModel>? characters,
    List<ShotModel>? shots,
  }) {
    return StoryModel(
      id: id ?? this.id,
      synopsis: synopsis ?? this.synopsis,
      genre: genre ?? this.genre,
      scriptText: scriptText ?? this.scriptText,
      characters: characters ?? this.characters,
      shots: shots ?? this.shots,
    );
  }
}

class ShotModel {
  final String id;
  final int sequenceIndex;
  final String sceneDescription;
  final String cameraDirection;
  final String? cameraMotion;
  final String? lightingStyle;
  final String? sfxCue;
  final String? dialogue;
  final int durationSeconds;
  final String? keyframePrompt;
  final String? keyframeImageUrl;
  final String? videoClipUrl;
  final String? audioVoiceoverUrl;
  final String status;

  ShotModel({
    required this.id,
    required this.sequenceIndex,
    required this.sceneDescription,
    required this.cameraDirection,
    this.cameraMotion,
    this.lightingStyle,
    this.sfxCue,
    this.dialogue,
    required this.durationSeconds,
    this.keyframePrompt,
    this.keyframeImageUrl,
    this.videoClipUrl,
    this.audioVoiceoverUrl,
    required this.status,
  });

  factory ShotModel.fromJson(Map<String, dynamic> json) {
    return ShotModel(
      id: json['id'] ?? '',
      sequenceIndex: json['sequenceIndex'] ?? 0,
      sceneDescription: json['sceneDescription'] ?? '',
      cameraDirection: json['cameraDirection'] ?? '',
      cameraMotion: json['cameraMotion'] ?? 'Dynamic Push-in',
      lightingStyle: json['lightingStyle'] ?? 'Volumetric Cinematic',
      sfxCue: json['sfxCue'] ?? 'Rain on glass & ambient tension',
      dialogue: json['dialogue'],
      durationSeconds: json['durationSeconds'] ?? 5,
      keyframePrompt: json['keyframePrompt'],
      keyframeImageUrl: json['keyframeImageUrl'],
      videoClipUrl: json['videoClipUrl'],
      audioVoiceoverUrl: json['audioVoiceoverUrl'],
      status: json['status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sequenceIndex': sequenceIndex,
        'sceneDescription': sceneDescription,
        'cameraDirection': cameraDirection,
        'cameraMotion': cameraMotion,
        'lightingStyle': lightingStyle,
        'sfxCue': sfxCue,
        'dialogue': dialogue,
        'durationSeconds': durationSeconds,
        'keyframePrompt': keyframePrompt,
        'keyframeImageUrl': keyframeImageUrl,
        'videoClipUrl': videoClipUrl,
        'audioVoiceoverUrl': audioVoiceoverUrl,
        'status': status,
      };

  ShotModel copyWith({
    String? id,
    int? sequenceIndex,
    String? sceneDescription,
    String? cameraDirection,
    String? cameraMotion,
    String? lightingStyle,
    String? sfxCue,
    String? dialogue,
    int? durationSeconds,
    String? keyframePrompt,
    String? keyframeImageUrl,
    String? videoClipUrl,
    String? audioVoiceoverUrl,
    String? status,
  }) {
    return ShotModel(
      id: id ?? this.id,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      sceneDescription: sceneDescription ?? this.sceneDescription,
      cameraDirection: cameraDirection ?? this.cameraDirection,
      cameraMotion: cameraMotion ?? this.cameraMotion,
      lightingStyle: lightingStyle ?? this.lightingStyle,
      sfxCue: sfxCue ?? this.sfxCue,
      dialogue: dialogue ?? this.dialogue,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      keyframePrompt: keyframePrompt ?? this.keyframePrompt,
      keyframeImageUrl: keyframeImageUrl ?? this.keyframeImageUrl,
      videoClipUrl: videoClipUrl ?? this.videoClipUrl,
      audioVoiceoverUrl: audioVoiceoverUrl ?? this.audioVoiceoverUrl,
      status: status ?? this.status,
    );
  }
}
