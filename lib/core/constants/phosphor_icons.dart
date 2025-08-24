import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Comprehensive Phosphor Icons organization system for project categories
/// 
/// Provides organized access to 200+ Phosphor icons categorized by domain
/// with string-to-IconData mapping for database storage and UI display.
/// All icons are organized by functional domains for easy discovery.
class PhosphorIconConstants {
  // Private constructor to prevent instantiation
  PhosphorIconConstants._();

  // ============================================================================
  // WORK & BUSINESS DOMAIN - Professional and corporate activities
  // ============================================================================
  
  /// Work & Business icons for professional projects
  static final Map<String, IconData> workIcons = {
    'briefcase': PhosphorIcons.briefcase(),
    'presentation': PhosphorIcons.presentation(),
    'chart-bar': PhosphorIcons.chartBar(),
    'handshake': PhosphorIcons.handshake(),
    'building-office': PhosphorIcons.buildingOffice(),
    'calculator': PhosphorIcons.calculator(),
    'clipboard': PhosphorIcons.clipboard(),
    'notebook': PhosphorIcons.notebook(),
    'folder': PhosphorIcons.folder(),
    'file': PhosphorIcons.file(),
    'calendar': PhosphorIcons.calendar(),
    'clock': PhosphorIcons.clock(),
    'timer': PhosphorIcons.timer(),
    'target': PhosphorIcons.target(),
    'trophy': PhosphorIcons.trophy(),
    'medal': PhosphorIcons.medal(),
    'certificate': PhosphorIcons.certificate(),
    'stamp': PhosphorIcons.stamp(),
    'scales': PhosphorIcons.scales(),
    'gavel': PhosphorIcons.gavel(),
  };

  // ============================================================================
  // PERSONAL DOMAIN - Individual and lifestyle activities
  // ============================================================================
  
  /// Personal icons for individual activities and self-care
  static final Map<String, IconData> personalIcons = {
    'user': PhosphorIcons.user(),
    'heart': PhosphorIcons.heart(),
    'house': PhosphorIcons.house(),
    'family': PhosphorIcons.users(),
    'baby': PhosphorIcons.baby(),
    'smiley': PhosphorIcons.smiley(),
    'star': PhosphorIcons.star(),
    'bookmark': PhosphorIcons.bookmark(),
    'gift': PhosphorIcons.gift(),
    'cake': PhosphorIcons.cake(),
    'balloon': PhosphorIcons.balloon(),
    'coffee': PhosphorIcons.coffee(),
    'wine': PhosphorIcons.wine(),
    'pizza': PhosphorIcons.pizza(),
    'ice-cream': PhosphorIcons.iceCream(),
    'flower': PhosphorIcons.flower(),
    'sun': PhosphorIcons.sun(),
    'moon': PhosphorIcons.moon(),
    'umbrella': PhosphorIcons.umbrella(),
    'rainbow': PhosphorIcons.rainbow(),
  };

  // ============================================================================
  // CREATIVE DOMAIN - Artistic and creative pursuits
  // ============================================================================
  
  /// Creative icons for artistic and design projects
  static final Map<String, IconData> creativeIcons = {
    'paint-brush': PhosphorIcons.paintBrush(),
    'palette': PhosphorIcons.palette(),
    'camera': PhosphorIcons.camera(),
    'music-note': PhosphorIcons.musicNote(),
    'film-strip': PhosphorIcons.filmStrip(),
    'microphone': PhosphorIcons.microphone(),
    'pen': PhosphorIcons.pen(),
    'pencil': PhosphorIcons.pencil(),
    'scissors': PhosphorIcons.scissors(),
    'mask-happy': PhosphorIcons.maskHappy(),
    'mask-sad': PhosphorIcons.maskSad(),
    'video-camera': PhosphorIcons.videoCamera(),
    'headphones': PhosphorIcons.headphones(),
    'speaker-high': PhosphorIcons.speakerHigh(),
    'guitar': PhosphorIcons.guitar(),
    'piano-keys': PhosphorIcons.pianoKeys(),
    'image': PhosphorIcons.image(),
    'shapes': PhosphorIcons.shapes(),
    'magic-wand': PhosphorIcons.magicWand(),
    'eyedropper': PhosphorIcons.eyedropper(),
  };

  // ============================================================================
  // TECHNOLOGY DOMAIN - Digital and tech-related activities
  // ============================================================================
  
  /// Technology icons for digital and programming projects
  static final Map<String, IconData> technologyIcons = {
    'laptop': PhosphorIcons.laptop(),
    'code': PhosphorIcons.code(),
    'gear': PhosphorIcons.gear(),
    'database': PhosphorIcons.database(),
    'cloud': PhosphorIcons.cloud(),
    'device-mobile': PhosphorIcons.deviceMobile(),
    'desktop': PhosphorIcons.desktop(),
    'globe': PhosphorIcons.globe(),
    'wifi': PhosphorIcons.wifiHigh(),
    'bluetooth': PhosphorIcons.bluetooth(),
    'cpu': PhosphorIcons.cpu(),
    'hard-drive': PhosphorIcons.hardDrive(),
    'usb': PhosphorIcons.usb(),
    'battery': PhosphorIcons.batteryHigh(),
    'lightning': PhosphorIcons.lightning(),
    'plug': PhosphorIcons.plug(),
    'robot': PhosphorIcons.robot(),
    'circuit-board': PhosphorIcons.cpu(),
    'terminal': PhosphorIcons.terminal(),
    'bug': PhosphorIcons.bug(),
  };

  // ============================================================================
  // HEALTH & FITNESS DOMAIN - Wellness and physical activities
  // ============================================================================
  
  /// Health & Fitness icons for wellness and exercise projects
  static final Map<String, IconData> healthIcons = {
    'heartbeat': PhosphorIcons.heartbeat(),
    'activity': PhosphorIcons.pulse(),
    'medical-bag': PhosphorIcons.firstAidKit(),
    'pill': PhosphorIcons.pill(),
    'leaf': PhosphorIcons.leaf(),
    'dumbbell': PhosphorIcons.barbell(),
    'bicycle': PhosphorIcons.bicycle(),
    'sneaker': PhosphorIcons.sneaker(),
    'swimming-pool': PhosphorIcons.swimmingPool(),
    'football': PhosphorIcons.football(),
    'basketball': PhosphorIcons.basketball(),
    'tennis-ball': PhosphorIcons.circle(),
    'soccer-ball': PhosphorIcons.soccerBall(),
    'medal-military': PhosphorIcons.medalMilitary(),
    'thermometer': PhosphorIcons.thermometer(),
    'bandaids': PhosphorIcons.bandaids(),
    'syringe': PhosphorIcons.syringe(),
    'tooth': PhosphorIcons.tooth(),
    'eye': PhosphorIcons.eye(),
    'ear': PhosphorIcons.ear(),
  };

  // ============================================================================
  // FINANCE DOMAIN - Money and financial activities
  // ============================================================================
  
  /// Finance icons for money management and business
  static final Map<String, IconData> financeIcons = {
    'wallet': PhosphorIcons.wallet(),
    'credit-card': PhosphorIcons.creditCard(),
    'bank': PhosphorIcons.bank(),
    'coins': PhosphorIcons.coins(),
    'trending-up': PhosphorIcons.trendUp(),
    'trending-down': PhosphorIcons.trendDown(),
    'money': PhosphorIcons.money(),
    'receipt': PhosphorIcons.receipt(),
    'piggy-bank': PhosphorIcons.piggyBank(),
    'safe': PhosphorIcons.vault(),
    'vault': PhosphorIcons.vault(),
    'invoice': PhosphorIcons.invoice(),
    'percent': PhosphorIcons.percent(),
    'diamond': PhosphorIcons.diamond(),
    'currency-circle-dollar': PhosphorIcons.currencyCircleDollar(),
    'currency-eur': PhosphorIcons.currencyEur(),
    'currency-gbp': PhosphorIcons.currencyGbp(),
    'currency-jpy': PhosphorIcons.currencyJpy(),
    'chart-pie': PhosphorIcons.chartPie(),
    'chart-line': PhosphorIcons.chartLine(),
  };

  // ============================================================================
  // TRAVEL DOMAIN - Transportation and travel activities
  // ============================================================================
  
  /// Travel icons for transportation and adventure
  static final Map<String, IconData> travelIcons = {
    'airplane': PhosphorIcons.airplane(),
    'car': PhosphorIcons.car(),
    'map-pin': PhosphorIcons.mapPin(),
    'compass': PhosphorIcons.compass(),
    'suitcase': PhosphorIcons.suitcase(),
    'train': PhosphorIcons.train(),
    'bus': PhosphorIcons.bus(),
    'boat': PhosphorIcons.boat(),
    'motorcycle': PhosphorIcons.motorcycle(),
    'truck': PhosphorIcons.truck(),
    'taxi': PhosphorIcons.taxi(),
    'gas-pump': PhosphorIcons.gasPump(),
    'traffic-cone': PhosphorIcons.trafficCone(),
    'road-horizon': PhosphorIcons.roadHorizon(),
    'signpost': PhosphorIcons.signpost(),
    'tent': PhosphorIcons.tent(),
    'campfire': PhosphorIcons.campfire(),
    'mountains': PhosphorIcons.mountains(),
    'tree': PhosphorIcons.tree(),
    'binoculars': PhosphorIcons.binoculars(),
  };

  // ============================================================================
  // FOOD & COOKING DOMAIN - Culinary activities
  // ============================================================================
  
  /// Food & Cooking icons for culinary projects
  static final Map<String, IconData> foodIcons = {
    'fork-knife': PhosphorIcons.forkKnife(),
    'chef-hat': PhosphorIcons.chefHat(),
    'cooking-pot': PhosphorIcons.cookingPot(),
    'oven': PhosphorIcons.oven(),
    'refrigerator': PhosphorIcons.house(),
    'blender': PhosphorIcons.funnel(),
    'knife': PhosphorIcons.knife(),
    'cutting-board': PhosphorIcons.knife(),
    'apple': PhosphorIcons.leaf(),
    'orange': PhosphorIcons.orange(),
    'carrot': PhosphorIcons.carrot(),
    'fish': PhosphorIcons.fish(),
    'egg': PhosphorIcons.egg(),
    'bread': PhosphorIcons.bread(),
    'martini': PhosphorIcons.martini(),
    'beer': PhosphorIcons.beerBottle(),
    'champagne': PhosphorIcons.champagne(),
    'shopping-bag': PhosphorIcons.shoppingBag(),
    'basket': PhosphorIcons.basket(),
    'fire': PhosphorIcons.fire(),
  };

  // ============================================================================
  // EDUCATION & LEARNING DOMAIN - Academic and educational activities
  // ============================================================================
  
  /// Education icons for learning and academic projects
  static final Map<String, IconData> educationIcons = {
    'graduation-cap': PhosphorIcons.graduationCap(),
    'book': PhosphorIcons.book(),
    'books': PhosphorIcons.books(),
    'bookmark-simple': PhosphorIcons.bookmarkSimple(),
    'student': PhosphorIcons.student(),
    'teacher': PhosphorIcons.chalkboardTeacher(),
    'chalkboard': PhosphorIcons.chalkboard(),
    'pencil-ruler': PhosphorIcons.pencilRuler(),
    'exam': PhosphorIcons.exam(),
    'certificate': PhosphorIcons.certificate(),
    'microscope': PhosphorIcons.microscope(),
    'test-tube': PhosphorIcons.testTube(),
    'atom': PhosphorIcons.atom(),
    'math-operations': PhosphorIcons.mathOperations(),
    'function': PhosphorIcons.function(),
    'equals': PhosphorIcons.equals(),
    'globe-hemisphere-west': PhosphorIcons.globeHemisphereWest(),
    'flag': PhosphorIcons.flag(),
    'language': PhosphorIcons.translate(),
    'lightbulb': PhosphorIcons.lightbulb(),
  };

  // ============================================================================
  // COMMUNICATION DOMAIN - Messaging and social activities
  // ============================================================================
  
  /// Communication icons for messaging and social projects
  static final Map<String, IconData> communicationIcons = {
    'envelope': PhosphorIcons.envelope(),
    'phone': PhosphorIcons.phone(),
    'chat-circle': PhosphorIcons.chatCircle(),
    'video': PhosphorIcons.videoCamera(),
    'megaphone': PhosphorIcons.megaphone(),
    'bell': PhosphorIcons.bell(),
    'share': PhosphorIcons.share(),
    'broadcast': PhosphorIcons.broadcast(),
    'radio': PhosphorIcons.radio(),
    'newspaper': PhosphorIcons.newspaper(),
    'article': PhosphorIcons.article(),
    'quotes': PhosphorIcons.quotes(),
    'at': PhosphorIcons.at(),
    'hash': PhosphorIcons.hash(),
    'link': PhosphorIcons.link(),
    'paperclip': PhosphorIcons.paperclip(),
    'thumbs-up': PhosphorIcons.thumbsUp(),
    'thumbs-down': PhosphorIcons.thumbsDown(),
    'hand-waving': PhosphorIcons.handWaving(),
    'handshake': PhosphorIcons.handshake(),
  };

  // ============================================================================
  // ENTERTAINMENT DOMAIN - Fun and recreational activities
  // ============================================================================
  
  /// Entertainment icons for fun and recreational projects
  static final Map<String, IconData> entertainmentIcons = {
    'game-controller': PhosphorIcons.gameController(),
    'dice-one': PhosphorIcons.diceOne(),
    'dice-six': PhosphorIcons.diceSix(),
    'cards': PhosphorIcons.cards(),
    'puzzle-piece': PhosphorIcons.puzzlePiece(),
    'ticket': PhosphorIcons.ticket(),
    'popcorn': PhosphorIcons.popcorn(),
    'television': PhosphorIcons.television(),
    'monitor-play': PhosphorIcons.monitorPlay(),
    'spotify-logo': PhosphorIcons.spotifyLogo(),
    'youtube-logo': PhosphorIcons.youtubeLogo(),
    'instagram-logo': PhosphorIcons.instagramLogo(),
    'facebook-logo': PhosphorIcons.facebookLogo(),
    'twitter-logo': PhosphorIcons.twitterLogo(),
    'party': PhosphorIcons.confetti(),
    'confetti': PhosphorIcons.confetti(),
    'fireworks': PhosphorIcons.sparkle(),
    'musical-note': PhosphorIcons.musicNote(),
    'disco-ball': PhosphorIcons.discoBall(),
    'magic-wand': PhosphorIcons.magicWand(),
  };

  // ============================================================================
  // SHOPPING DOMAIN - Commerce and retail activities
  // ============================================================================
  
  /// Shopping icons for commerce and retail projects
  static final Map<String, IconData> shoppingIcons = {
    'shopping-cart': PhosphorIcons.shoppingCart(),
    'storefront': PhosphorIcons.storefront(),
    'package': PhosphorIcons.package(),
    'tag': PhosphorIcons.tag(),
    'barcode': PhosphorIcons.barcode(),
    'qr-code': PhosphorIcons.qrCode(),
    'handbag': PhosphorIcons.handbag(),
    't-shirt': PhosphorIcons.tShirt(),
    'dress': PhosphorIcons.dress(),
    'pants': PhosphorIcons.pants(),
    'sneaker-move': PhosphorIcons.sneakerMove(),
    'watch': PhosphorIcons.watch(),
    'sunglasses': PhosphorIcons.sunglasses(),
    'crown': PhosphorIcons.crown(),
    'diamond': PhosphorIcons.diamond(),
    'gem': PhosphorIcons.diamond(),
    'shopping-bag-open': PhosphorIcons.shoppingBagOpen(),
    'receipt': PhosphorIcons.receipt(),
    'credit-card': PhosphorIcons.creditCard(),
    'percent': PhosphorIcons.percent(),
  };

  // ============================================================================
  // UTILITIES & TOOLS DOMAIN - Practical tools and utilities
  // ============================================================================
  
  /// Utility icons for tools and practical projects
  static final Map<String, IconData> utilityIcons = {
    'wrench': PhosphorIcons.wrench(),
    'hammer': PhosphorIcons.hammer(),
    'screwdriver': PhosphorIcons.screwdriver(),
    'toolbox': PhosphorIcons.toolbox(),
    'ladder': PhosphorIcons.ladder(),
    'paint-roller': PhosphorIcons.paintRoller(),
    'drill': PhosphorIcons.gear(),
    'saw': PhosphorIcons.knife(),
    'ruler': PhosphorIcons.ruler(),
    'level': PhosphorIcons.ruler(),
    'flashlight': PhosphorIcons.flashlight(),
    'battery': PhosphorIcons.batteryHigh(),
    'lock': PhosphorIcons.lock(),
    'key': PhosphorIcons.key(),
    'shield': PhosphorIcons.shield(),
    'warning': PhosphorIcons.warning(),
    'info': PhosphorIcons.info(),
    'question': PhosphorIcons.question(),
    'exclamation': PhosphorIcons.warning(),
    'check': PhosphorIcons.check(),
  };

  // ============================================================================
  // MASTER ICON REGISTRY - All icons organized by domain
  // ============================================================================
  
  /// Complete registry of all available icons organized by domain
  static final Map<String, Map<String, IconData>> iconsByDomain = {
    'work': workIcons,
    'personal': personalIcons,
    'creative': creativeIcons,
    'technology': technologyIcons,
    'health': healthIcons,
    'finance': financeIcons,
    'travel': travelIcons,
    'food': foodIcons,
    'education': educationIcons,
    'communication': communicationIcons,
    'entertainment': entertainmentIcons,
    'shopping': shoppingIcons,
    'utility': utilityIcons,
  };

  /// Flattened map of all icons for direct access by name
  static final Map<String, IconData> allIcons = {
    for (final domain in iconsByDomain.values)
      ...domain,
  };

  /// Domain display names for UI
  static const Map<String, String> domainDisplayNames = {
    'work': 'Work & Business',
    'personal': 'Personal & Lifestyle',
    'creative': 'Creative & Arts',
    'technology': 'Technology & Digital',
    'health': 'Health & Fitness',
    'finance': 'Finance & Money',
    'travel': 'Travel & Adventure',
    'food': 'Food & Cooking',
    'education': 'Education & Learning',
    'communication': 'Communication & Social',
    'entertainment': 'Entertainment & Fun',
    'shopping': 'Shopping & Commerce',
    'utility': 'Tools & Utilities',
  };

  // ============================================================================
  // UTILITY METHODS - Helper functions for icon management
  // ============================================================================

  /// Gets an icon by its name, returns default if not found
  static IconData getIconByName(String iconName, {IconData? defaultIcon}) {
    return allIcons[iconName] ?? defaultIcon ?? PhosphorIcons.tag();
  }

  /// Checks if an icon name exists in the registry
  static bool hasIcon(String iconName) {
    return allIcons.containsKey(iconName);
  }

  /// Gets all icon names for a specific domain
  static List<String> getIconNamesForDomain(String domain) {
    return iconsByDomain[domain]?.keys.toList() ?? [];
  }

  /// Gets all icons for a specific domain
  static Map<String, IconData> getIconsForDomain(String domain) {
    return iconsByDomain[domain] ?? {};
  }

  /// Gets all available domain names
  static List<String> getAllDomains() {
    return iconsByDomain.keys.toList();
  }

  /// Gets all available icon names
  static List<String> getAllIconNames() {
    return allIcons.keys.toList()..sort();
  }

  /// Gets the domain for a specific icon name
  static String? getDomainForIcon(String iconName) {
    for (final entry in iconsByDomain.entries) {
      if (entry.value.containsKey(iconName)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Searches icons by name (case-insensitive)
  static List<String> searchIconNames(String query) {
    if (query.isEmpty) return getAllIconNames();
    
    final lowercaseQuery = query.toLowerCase();
    return allIcons.keys
        .where((name) => name.toLowerCase().contains(lowercaseQuery))
        .toList()
      ..sort();
  }

  /// Gets popular/recommended icons for quick access
  static const List<String> popularIconNames = [
    'briefcase',
    'user',
    'heart',
    'house',
    'paint-brush',
    'laptop',
    'heartbeat',
    'wallet',
    'airplane',
    'fork-knife',
    'graduation-cap',
    'envelope',
    'game-controller',
    'shopping-cart',
    'gear',
  ];

  /// Gets popular icons as a map
  static Map<String, IconData> get popularIcons {
    return {
      for (final name in popularIconNames)
        if (allIcons.containsKey(name))
          name: allIcons[name]!,
    };
  }

  /// Validates that an icon name is valid
  static bool isValidIconName(String iconName) {
    return iconName.isNotEmpty && 
           iconName.trim() == iconName && 
           !iconName.contains(' ') &&
           iconName.toLowerCase() == iconName;
  }

  /// Gets icon statistics
  static Map<String, int> getIconStatistics() {
    return {
      'total_icons': allIcons.length,
      'total_domains': iconsByDomain.length,
      for (final entry in iconsByDomain.entries)
        '${entry.key}_icons': entry.value.length,
    };
  }
}

