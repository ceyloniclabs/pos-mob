import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'error_brand_name_empty': 'Brand name cannot be empty',
          'error_brand_name_too_short':
              'Brand name must be at least 2 characters long',
          'good_morning': 'Good Morning',
          'good_afternoon': 'Good Afternoon',
          'good_evening': 'Good Evening',
          'good_night': 'Good Night',
        },
        'si_LK': {
          'error_brand_name_empty': 'සන්නාම නාමය හිස්ව තැබිය නොහැක',
          'error_brand_name_too_short':
              'සන්නාම නාමය අවම වශයෙන් අක්ෂර 2ක් විය යුතුය',
          'good_morning': 'සුභ උදෑසනක්',
          'good_afternoon': 'සුභ දහවලක්',
          'good_evening': 'සුභ සැන්දෑවක්',
          'good_night': 'සුභ රාත්‍රියක්',
        },
      };
}
