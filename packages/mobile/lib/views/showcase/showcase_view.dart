import 'package:flutter/material.dart';
import '../../core/cinematic_image.dart';
import '../../core/theme.dart';
import '../../models/project_model.dart';

class TrendingDrama {
  final String id;
  final String title;
  final String genre;
  final String prompt;
  final String synopsis;
  final String creator;
  final String views;
  final String likes;
  final String duration;
  final String thumbnailUrl;
  final String videoUrl;
  final List<String> characterNames;

  const TrendingDrama({
    required this.id,
    required this.title,
    required this.genre,
    required this.prompt,
    required this.synopsis,
    required this.creator,
    required this.views,
    required this.likes,
    required this.duration,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.characterNames,
  });
}

class ShowcaseView extends StatefulWidget {
  final Function(String prompt, String genre) onRemixPrompt;

  const ShowcaseView({Key? key, required this.onRemixPrompt}) : super(key: key);

  @override
  State<ShowcaseView> createState() => _ShowcaseViewState();
}

class _ShowcaseViewState extends State<ShowcaseView> {
  String _selectedGenre = 'All';

  final List<String> _filterGenres = [
    'All',
    'Revenge Drama',
    'Billionaire Romance',
    'Cyberpunk Thriller',
    'Fantasy Epic',
    'Noir Mystery',
  ];

  final List<TrendingDrama> _trendingDramas = [
    TrendingDrama(
      id: 'trend_1',
      title: 'The Silent Heirloom',
      genre: 'Revenge Drama',
      prompt: 'A disowned heir attends his stepbrother\'s trillion-dollar wedding banquet and unveils the original will.',
      synopsis: 'Seven years after being framed and cast out, Julian returns to the Sterling grand estate during the wedding of the century. As crystal glasses clink, he reveals the encrypted deed that proves the entire empire belongs to him.',
      creator: '@CinemaAI',
      views: '2.4M',
      likes: '184K',
      duration: '45s',
      thumbnailUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=900&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      characterNames: ['Julian Vance', 'Arthur Sterling'],
    ),
    TrendingDrama(
      id: 'trend_2',
      title: 'Neon Ronin 2099',
      genre: 'Cyberpunk Thriller',
      prompt: 'In a rain-drenched Neo-Tokyo alley, an augmented ronin protects a rogue android holding human consciousness.',
      synopsis: 'Hunted by syndicate drone swarms across neon billboards, Jin activates his thermal blade to hold off a cybernetic strike team, buying time for the memory core to upload.',
      creator: '@NeoStudio',
      views: '1.8M',
      likes: '142K',
      duration: '35s',
      thumbnailUrl: 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=900&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      characterNames: ['Jin Sakai', 'Vespera'],
    ),
    TrendingDrama(
      id: 'trend_3',
      title: 'Mask of the Empress',
      genre: 'Billionaire Romance',
      prompt: 'An undercover billionaire heiress serves champagne at a gala, only for the billionaire host to recognize her ring.',
      synopsis: 'Disguised as a banquet attendant, Vivienne uncovers a sabotage attempt against the Vance conglomerate, but CEO Marcus catches her wrist before she can slip away into the shadows.',
      creator: '@ReelMaster',
      views: '3.1M',
      likes: '290K',
      duration: '30s',
      thumbnailUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=900&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      characterNames: ['Vivienne Sterling', 'Marcus Sterling'],
    ),
    TrendingDrama(
      id: 'trend_4',
      title: 'The Alchemist\'s Vow',
      genre: 'Fantasy Epic',
      prompt: 'A banished court alchemist reveals an ancient dragon relic during an eclipse to save the besieged citadel.',
      synopsis: 'With dark sorcery shattering the city gates, Kenneth breaks the sacred seal on the celestial vial, summoning azure dragonfire that turns the tide of the war.',
      creator: '@FantasyForge',
      views: '920K',
      likes: '78K',
      duration: '40s',
      thumbnailUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=900&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
      characterNames: ['Kenneth', 'Queen Selene'],
    ),
  ];

  void _showDramaDetail(TrendingDrama drama) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryPurple),
                    ),
                    child: Text(drama.genre, style: const TextStyle(fontSize: 11, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Thumbnail / Video Preview Box
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CinematicImage(imageUrl: drama.thumbnailUrl, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    const Center(
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.play_arrow, size: 36, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Duration: ${drama.duration}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                          Row(
                            children: [
                              const Icon(Icons.favorite, size: 14, color: AppTheme.accentRose),
                              const SizedBox(width: 4),
                              Text(drama.likes, style: const TextStyle(fontSize: 11, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(drama.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text('By ${drama.creator} • ${drama.views} views', style: const TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 14),

              const Text('Original Story Prompt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldCoin)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Text(
                  drama.prompt,
                  style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
                ),
              ),
              const SizedBox(height: 14),

              const Text('Synopsis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    drama.synopsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white60, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onRemixPrompt(drama.prompt, drama.genre);
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('⚡ Remix This Drama (1-Tap Creation)'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedGenre == 'All'
        ? _trendingDramas
        : _trendingDramas.where((d) => d.genre == _selectedGenre).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Genre Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filterGenres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final genre = _filterGenres[i];
                final isSelected = _selectedGenre == genre;
                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryPurple,
                  backgroundColor: AppTheme.surfaceCard,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedGenre = genre);
                  },
                );
              },
            ),
          ),
        ),

        // Drama List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final drama = filtered[i];

              return GestureDetector(
                onTap: () => _showDramaDetail(drama),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Video Banner
                      Stack(
                        children: [
                          CinematicImage(
                            imageUrl: drama.thumbnailUrl,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 190,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.8)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(drama.genre, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility, size: 12, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(drama.views, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const Positioned.fill(
                            child: Center(
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.play_arrow, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Card Content
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    drama.title,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => widget.onRemixPrompt(drama.prompt, drama.genre),
                                  icon: const Icon(Icons.auto_awesome, size: 14, color: AppTheme.goldCoin),
                                  label: const Text('Remix', style: TextStyle(fontSize: 11, color: Colors.white)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppTheme.primaryPurple),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              drama.prompt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
