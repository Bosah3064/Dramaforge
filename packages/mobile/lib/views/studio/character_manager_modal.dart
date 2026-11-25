import 'package:flutter/material.dart';
import '../../core/cinematic_image.dart';
import '../../core/generation_service.dart';
import '../../core/theme.dart';
import '../../models/project_model.dart';

class CharacterManagerModal extends StatefulWidget {
  final List<CharacterModel> initialCharacters;
  final Function(List<CharacterModel> updatedCharacters) onSave;

  const CharacterManagerModal({
    Key? key,
    required this.initialCharacters,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CharacterManagerModal> createState() => _CharacterManagerModalState();
}

class _CharacterManagerModalState extends State<CharacterManagerModal> {
  late List<CharacterModel> _characters;

  @override
  void initState() {
    super.initState();
    _characters = List.from(widget.initialCharacters);
  }

  void _showAddOrEditDialog({CharacterModel? character, int? index}) {
    final nameCtrl = TextEditingController(text: character?.name ?? '');
    final roleCtrl = TextEditingController(text: character?.role ?? 'Supporting');
    final descCtrl = TextEditingController(text: character?.appearance ?? '');
    String selectedImageUrl = character?.referenceImageUrl ?? GenerationService.castArchetypes[0].imageUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          character == null ? 'Add New Character' : 'Edit Character Image & Role',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Avatar Preview & Archetype Picker
                    Center(
                      child: Stack(
                        children: [
                          CinematicImage(
                            imageUrl: selectedImageUrl,
                            width: 100,
                            height: 100,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Choose AI Visual Face Anchor',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),

                    // Quick archetype avatars with Medium Filter
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: GenerationService.castArchetypes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final arch = GenerationService.castArchetypes[i];
                          final isSelected = selectedImageUrl == arch.imageUrl;

                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedImageUrl = arch.imageUrl;
                                if (nameCtrl.text.isEmpty) nameCtrl.text = arch.name;
                                if (descCtrl.text.isEmpty) descCtrl.text = arch.appearance;
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppTheme.goldCoin : Colors.transparent,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: CinematicImage(
                                    imageUrl: arch.imageUrl,
                                    width: 56,
                                    height: 56,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      arch.medium == 'CARTOON_3D'
                                          ? '✨'
                                          : arch.medium == 'ANIME_2D'
                                              ? '🎌'
                                              : '🎬',
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Input
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Character Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Role Input
                    TextField(
                      controller: roleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Role / Archetype',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Appearance Description
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Visual Appearance & Wardrobe',
                        prefixIcon: Icon(Icons.style_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;

                        final newChar = CharacterModel(
                          name: nameCtrl.text.trim(),
                          role: roleCtrl.text.trim(),
                          appearance: descCtrl.text.trim(),
                          voiceStyle: 'Articulate, cinematic',
                          referenceImageUrl: selectedImageUrl,
                        );

                        setState(() {
                          if (index != null && index >= 0 && index < _characters.length) {
                            _characters[index] = newChar;
                          } else {
                            _characters.add(newChar);
                          }
                        });

                        Navigator.pop(ctx);
                      },
                      child: Text(character == null ? 'Add Character' : 'Save Changes'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.face_retouching_natural, color: AppTheme.goldCoin, size: 22),
                  SizedBox(width: 8),
                  Text('Analyzed Characters & Faces', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'The AI synthesized these characters from your prompt. You can change their reference photos or add new characters to anchor visual consistency across every scene.',
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Character List
          Expanded(
            child: ListView.separated(
              itemCount: _characters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final char = _characters[i];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      // Character Avatar
                      CinematicImage(
                        imageUrl: char.referenceImageUrl,
                        width: 58,
                        height: 58,
                        borderRadius: BorderRadius.circular(12),
                        placeholderText: char.name,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(char.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryPurple.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(char.role ?? 'Cast', style: const TextStyle(fontSize: 10, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              char.appearance,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryPurple, size: 20),
                        onPressed: () => _showAddOrEditDialog(character: char, index: i),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddOrEditDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('+ Add Character'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.primaryPurple),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(_characters);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply to Scenes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
