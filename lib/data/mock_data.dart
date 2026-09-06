import '../models/episode.dart';
import '../models/media_item.dart';
import '../models/upcoming_item.dart';
import '../models/user_profile.dart';

class MockData {
  // User Profiles
  static const List<UserProfile> profiles = [
    UserProfile(
      id: 'p1',
      name: 'Alex Vance',
      avatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
    ),
    UserProfile(
      id: 'p2',
      name: 'Maya Lin',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
    ),
    UserProfile(
      id: 'p3',
      name: 'Kids Club',
      avatarUrl:
          'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=200&auto=format&fit=crop&q=80',
      isKids: true,
    ),
    UserProfile(
      id: 'p4',
      name: 'Guest Cinephile',
      avatarUrl:
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&auto=format&fit=crop&q=80',
    ),
  ];

  // Featured Hero Carousel Items
  static final List<MediaItem> heroBanners = [
    const MediaItem(
      id: 'hero-1',
      title: 'CHRONO MATRIX',
      description:
          'When reality begins folding into recursive temporal loops, a rogue theoretical physicist and a cybernetic operative must breach the singularity core before the planetary clock resets forever.',
      posterUrl:
          'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80',
      genres: ['Cyberpunk', 'Sci-Fi', 'Mind-Bending', 'Action'],
      releaseYear: 2025,
      ageRating: '16+',
      durationOrSeasons: '2h 28m',
      matchScore: 99.2,
      type: MediaType.movie,
      isOriginal: true,
      cast: ['David Sterling', 'Elena Rostova', 'Kenji Sato', 'Zendaya Cole'],
      creators: ['Christopher Nolan', 'Denis Villeneuve'],
      tags: ['Mind-Bending', 'Visually Striking', 'Adrenaline Rush', 'Dark'],
    ),
    const MediaItem(
      id: 'hero-2',
      title: 'NEON SHADOWS: TOKYO 2099',
      description:
          'Deep beneath the bioluminescent towers of Neo-Shinjuku, an underground syndicate awakens a synthetic consciousness that possesses memories of an extinct civilization.',
      posterUrl:
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=1200&auto=format&fit=crop&q=80',
      genres: ['Neo-Noir', 'Sci-Fi', 'Thriller', 'Original'],
      releaseYear: 2024,
      ageRating: '18+',
      durationOrSeasons: '3 Seasons',
      matchScore: 97.5,
      type: MediaType.series,
      isOriginal: true,
      cast: ['Hiroshi Tanaka', 'Aria Montgomery', 'Marcus Sterling'],
      creators: ['Shinichiro Watanabe', 'Alex Garland'],
      tags: ['Atmospheric', 'Gritty', 'Futuristic', 'Synthesizer Score'],
      episodes: _mockEpisodesSeason1,
    ),
    const MediaItem(
      id: 'hero-3',
      title: 'THE ABYSSAL DEEP',
      description:
          'An elite deep-sea research crew investigating an uncharted trench in the South Pacific uncovers a prehistoric subterranean biome guarding an ancient tectonic gateway.',
      posterUrl:
          'https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=800&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop&q=80',
      genres: ['Survival', 'Mystery', 'Sci-Fi', 'Drama'],
      releaseYear: 2025,
      ageRating: '13+',
      durationOrSeasons: '2h 14m',
      matchScore: 95.8,
      type: MediaType.movie,
      isOriginal: false,
      cast: ['Rebecca Hall', 'Stellan Skarsgård', 'Brian Tyree Henry'],
      creators: ['James Cameron'],
      tags: ['Claustrophobic', 'Mysterious', 'Epic Scale'],
    ),
    const MediaItem(
      id: 'hero-4',
      title: 'SOLARIS ODYSSEY',
      description:
          'A generation ship traversing interstellar space faces an ethical collapse when the AI navigator begins prioritizing the preservation of digital souls over biological crew members.',
      posterUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=1200&auto=format&fit=crop&q=80',
      genres: ['Cosmic', 'Space Opera', 'Philosophical'],
      releaseYear: 2024,
      ageRating: '16+',
      durationOrSeasons: '2 Seasons',
      matchScore: 98.4,
      type: MediaType.series,
      isOriginal: true,
      cast: ['Matthew McConaughey', 'Jessica Chastain', 'Oscar Isaac'],
      creators: ['Jonathan Nolan'],
      episodes: _mockEpisodesSeason1,
    ),
  ];

  // Continue Watching Mock List
  static final List<MediaItem> continueWatching = [
    const MediaItem(
      id: 'cw-1',
      title: 'Neon Shadows: Tokyo 2099',
      description: 'S2:E4 "Signal in the Static"',
      posterUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=1200&auto=format&fit=crop&q=80',
      genres: ['Sci-Fi', 'Cyberpunk'],
      releaseYear: 2024,
      ageRating: '18+',
      durationOrSeasons: 'Season 2',
      matchScore: 98.0,
      type: MediaType.series,
      watchProgress: 0.68,
      episodes: _mockEpisodesSeason1,
    ),
    const MediaItem(
      id: 'cw-2',
      title: 'The Silent Horizon',
      description: 'An arctic expedition discovers forgotten cold-war tech.',
      posterUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1517411032315-54ef2cb783bb?w=1200&auto=format&fit=crop&q=80',
      genres: ['Mystery', 'Thriller'],
      releaseYear: 2023,
      ageRating: '16+',
      durationOrSeasons: '1h 58m',
      matchScore: 94.2,
      type: MediaType.movie,
      watchProgress: 0.35,
    ),
    const MediaItem(
      id: 'cw-3',
      title: 'Kingdom of Sands',
      description: 'S1:E8 "The Golden Eclipse"',
      posterUrl:
          'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1547234935-80c7145ec969?w=1200&auto=format&fit=crop&q=80',
      genres: ['Epic Fantasy', 'Action'],
      releaseYear: 2024,
      ageRating: '16+',
      durationOrSeasons: 'Season 1',
      matchScore: 96.7,
      type: MediaType.series,
      watchProgress: 0.88,
      episodes: _mockEpisodesSeason1,
    ),
  ];

  // Top 10 in NetLiv Today
  static final List<MediaItem> topTenToday = [
    const MediaItem(
      id: 'top-1',
      title: 'Chrono Matrix',
      description: 'A mind-bending loop paradox threatening spacetime.',
      posterUrl:
          'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80',
      genres: ['Action', 'Sci-Fi'],
      releaseYear: 2025,
      ageRating: '16+',
      durationOrSeasons: '2h 28m',
      matchScore: 99.2,
      type: MediaType.movie,
      topTenRank: 1,
      isOriginal: true,
    ),
    const MediaItem(
      id: 'top-2',
      title: 'The Alchemist Syndicate',
      description: 'Modern bankers wield forbidden esoteric formulas.',
      posterUrl:
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=1200&auto=format&fit=crop&q=80',
      genres: ['Drama', 'Dark Thriller'],
      releaseYear: 2024,
      ageRating: '18+',
      durationOrSeasons: '2 Seasons',
      matchScore: 98.1,
      type: MediaType.series,
      topTenRank: 2,
      isOriginal: true,
      episodes: _mockEpisodesSeason1,
    ),
    const MediaItem(
      id: 'top-3',
      title: 'Neon Shadows: Tokyo 2099',
      description: 'Neo-Shinjuku cyber thriller.',
      posterUrl:
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=1200&auto=format&fit=crop&q=80',
      genres: ['Cyberpunk', 'Mystery'],
      releaseYear: 2024,
      ageRating: '18+',
      durationOrSeasons: '3 Seasons',
      matchScore: 97.5,
      type: MediaType.series,
      topTenRank: 3,
      isOriginal: true,
      episodes: _mockEpisodesSeason1,
    ),
    const MediaItem(
      id: 'top-4',
      title: 'Midnight Speed',
      description: 'Hypercar racers across subterranean highway tunnels.',
      posterUrl:
          'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=1200&auto=format&fit=crop&q=80',
      genres: ['Action', 'Adrenaline'],
      releaseYear: 2024,
      ageRating: '13+',
      durationOrSeasons: '1h 52m',
      matchScore: 95.0,
      type: MediaType.movie,
      topTenRank: 4,
    ),
    const MediaItem(
      id: 'top-5',
      title: 'The Abyssal Deep',
      description: 'Prehistoric ocean trench discovery.',
      posterUrl:
          'https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop&q=80',
      genres: ['Survival', 'Sci-Fi'],
      releaseYear: 2025,
      ageRating: '13+',
      durationOrSeasons: '2h 14m',
      matchScore: 95.8,
      type: MediaType.movie,
      topTenRank: 5,
    ),
    const MediaItem(
      id: 'top-6',
      title: 'Echoes of Valhalla',
      description: 'Viking warriors face mythological storm spirits.',
      posterUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200&auto=format&fit=crop&q=80',
      genres: ['Historical', 'Mythology'],
      releaseYear: 2023,
      ageRating: '16+',
      durationOrSeasons: '4 Seasons',
      matchScore: 94.7,
      type: MediaType.series,
      topTenRank: 6,
      episodes: _mockEpisodesSeason1,
    ),
  ];

  // NetLiv Originals
  static final List<MediaItem> netlivOriginals = [
    const MediaItem(
      id: 'orig-1',
      title: 'SYNTHESIS ZERO',
      description:
          'In a society where memories can be uploaded, a detective hunts a memory architect who erased his own past.',
      posterUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1200&auto=format&fit=crop&q=80',
      genres: ['Sci-Fi', 'Psychological'],
      releaseYear: 2025,
      ageRating: '18+',
      durationOrSeasons: '1 Season',
      matchScore: 98.9,
      type: MediaType.series,
      isOriginal: true,
      episodes: _mockEpisodesSeason1,
    ),
    const MediaItem(
      id: 'orig-2',
      title: 'AETHER VOYAGER',
      description:
          'A crew navigates cosmic clouds of dark matter to restore humanity’s dwindling orbital beacon.',
      posterUrl:
          'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop&q=80',
      genres: ['Sci-Fi', 'Adventure'],
      releaseYear: 2024,
      ageRating: '13+',
      durationOrSeasons: '2h 10m',
      matchScore: 96.3,
      type: MediaType.movie,
      isOriginal: true,
    ),
    const MediaItem(
      id: 'orig-3',
      title: 'PHANTOM PROTOCOL',
      description:
          'A counter-intelligence unit battles an invisible cyber phantom capable of hijacking biometric implants.',
      posterUrl:
          'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=1200&auto=format&fit=crop&q=80',
      genres: ['Cyber Thriller', 'Action'],
      releaseYear: 2024,
      ageRating: '16+',
      durationOrSeasons: '3 Seasons',
      matchScore: 97.1,
      type: MediaType.series,
      isOriginal: true,
      episodes: _mockEpisodesSeason1,
    ),
    const MediaItem(
      id: 'orig-4',
      title: 'SILICA DRIFT',
      description:
          'Nomadic miners on a crystalline planet uncover an acoustic monolith that predicts supernova bursts.',
      posterUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80',
      genres: ['Sci-Fi', 'Mystery'],
      releaseYear: 2025,
      ageRating: '13+',
      durationOrSeasons: '1h 48m',
      matchScore: 93.4,
      type: MediaType.movie,
      isOriginal: true,
    ),
  ];

  // Action & Thrillers
  static final List<MediaItem> actionThrillers = [
    const MediaItem(
      id: 'act-1',
      title: 'Blackout Protocol',
      description: 'Citywide EMP trap engineered by an underground syndicate.',
      posterUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80',
      genres: ['Action', 'Heist'],
      releaseYear: 2023,
      ageRating: '16+',
      durationOrSeasons: '2h 05m',
      matchScore: 95.5,
      type: MediaType.movie,
    ),
    const MediaItem(
      id: 'act-2',
      title: 'Zero Hour: Extraction',
      description: 'Special forces rescue operation across hostile desert borders.',
      posterUrl:
          'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1547234935-80c7145ec969?w=1200&auto=format&fit=crop&q=80',
      genres: ['Action', 'Tactical'],
      releaseYear: 2024,
      ageRating: '18+',
      durationOrSeasons: '1h 56m',
      matchScore: 92.8,
      type: MediaType.movie,
    ),
    const MediaItem(
      id: 'act-3',
      title: 'Neon Ronin',
      description: 'Vengeance story of an outcast blade runner in Kyoto.',
      posterUrl:
          'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80',
      backdropUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=1200&auto=format&fit=crop&q=80',
      genres: ['Martial Arts', 'Cyberpunk'],
      releaseYear: 2025,
      ageRating: '18+',
      durationOrSeasons: '2h 12m',
      matchScore: 97.8,
      type: MediaType.movie,
      isOriginal: true,
    ),
  ];

  // Upcoming Releases
  static const List<UpcomingItem> upcomingList = [
    UpcomingItem(
      id: 'up-1',
      title: 'QUANTUM REACH: GENESIS',
      description:
          'The definitive conclusion to the cosmic saga. When the last gravitational fold opens, heroes must sacrifice eternity to preserve tomorrow.',
      releaseDateText: 'Arriving This Friday',
      monthBadge: 'OCT',
      dayBadge: '18',
      videoTeaserBackdrop:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80',
      genres: ['Sci-Fi', 'Blockbuster', 'NetLiv Original'],
      isOriginal: true,
    ),
    UpcomingItem(
      id: 'up-2',
      title: 'SHADOW OVER VENICE',
      description:
          'In flooded Renaissance waterways transformed into high-tech canals, an international art forgery heist turns into a deadly game of espionage.',
      releaseDateText: 'Coming November 4',
      monthBadge: 'NOV',
      dayBadge: '04',
      videoTeaserBackdrop:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=1200&auto=format&fit=crop&q=80',
      genres: ['Heist', 'Thriller', 'Mystery'],
      isOriginal: true,
    ),
    UpcomingItem(
      id: 'up-3',
      title: 'APEX HUNTER: FROSTLINE',
      description:
          'An apex predator awakened from permafrost traps a drilling community during an endless polar blizzard night.',
      releaseDateText: 'Coming December 12',
      monthBadge: 'DEC',
      dayBadge: '12',
      videoTeaserBackdrop:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1200&auto=format&fit=crop&q=80',
      genres: ['Survival', 'Horror', 'Creature Feature'],
      isOriginal: false,
    ),
  ];

  // Episodes for series
  static const List<Episode> _mockEpisodesSeason1 = [
    Episode(
      episodeNumber: 1,
      seasonNumber: 1,
      title: 'The Glitch in Shinjuku',
      duration: '54m',
      synopsis:
          'Detective Ren investigates a murder where the victim’s cybernetic retina was wiped with military-grade scrambler software.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=600&auto=format&fit=crop&q=80',
    ),
    Episode(
      episodeNumber: 2,
      seasonNumber: 1,
      title: 'Ghost in the Machine',
      duration: '49m',
      synopsis:
          'An anonymous hacker leaks classified neural archives, revealing illegal corporate memory synthesis labs.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80',
    ),
    Episode(
      episodeNumber: 3,
      seasonNumber: 1,
      title: 'Sub-Level Nine',
      duration: '58m',
      synopsis:
          'A breach in the underground cooling aqueduct exposes a rogue server farm computing forbidden predictive algorithms.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=600&auto=format&fit=crop&q=80',
    ),
    Episode(
      episodeNumber: 4,
      seasonNumber: 1,
      title: 'Singularity Drift',
      duration: '62m',
      synopsis:
          'Ren and Aria confront the synthetic consciousness inside the core reactor before the quarantine protocol detonates.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  // Search trending keywords
  static const List<String> trendingKeywords = [
    'Cyberpunk',
    'Chrono Matrix',
    'Nolan',
    'Anime',
    '4K Ultra HD',
    'Time Travel',
    'Neo-Tokyo',
    'Psychological Thrillers',
  ];

  // Helper to get all media items for search
  static List<MediaItem> get allItems {
    final Map<String, MediaItem> map = {};
    for (final item in [
      ...heroBanners,
      ...continueWatching,
      ...topTenToday,
      ...netlivOriginals,
      ...actionThrillers,
    ]) {
      map[item.id] = item;
    }
    return map.values.toList();
  }
}
