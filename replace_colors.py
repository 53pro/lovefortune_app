import os
import re

replacements = [
    (r'const Color\(0xFF5B86E5\)', 'AppTheme.primary'),
    (r'Color\(0xFF5B86E5\)', 'AppTheme.primary'),
    (r'const Color\(0xFFFF8A8A\)', 'AppTheme.brandPink'),
    (r'Color\(0xFFFF8A8A\)', 'AppTheme.brandPink'),
    (r'const Color\(0xFF34C759\)', 'AppTheme.success'),
    (r'Color\(0xFF34C759\)', 'AppTheme.success'),
    (r'const Color\(0xFFFF9F43\)', 'AppTheme.warning'),
    (r'Color\(0xFFFF9F43\)', 'AppTheme.warning'),
    (r'const Color\(0xFFEAEBEE\)', 'AppTheme.hairline'),
    (r'Color\(0xFFEAEBEE\)', 'AppTheme.hairline'),
    (r'Colors\.white\.withOpacity\(0\.9\)', 'AppTheme.onPrimary.withOpacity(0.9)'),
    (r'Colors\.grey\[700\]', 'AppTheme.muted'),
    (r'Colors\.grey\[600\]', 'AppTheme.muted'),
    (r'Colors\.grey\[400\]', 'AppTheme.mutedSoft'),
    (r'Colors\.red\[400\]', 'AppTheme.error'),
    (r'Color\(0xFFDB4437\)', 'AppTheme.brandCoral'),
]

# For Colors.white and Colors.grey, we must be careful with word boundaries
replacements.extend([
    (r'\bColors\.grey\b', 'AppTheme.muted'),
    (r'\bColors\.black87\b', 'AppTheme.ink'),
    (r'\bColors\.red\b', 'AppTheme.error'),
])

files_to_update = [
    "lib/features/today_us/today_us_screen.dart",
    "lib/features/auth/auth_screen.dart",
    "lib/features/personality/personality_screen.dart",
    "lib/features/special_advice/special_advice_screen.dart",
    "lib/features/tips/personality_report_screen.dart",
    "lib/features/tips/tips_screen.dart",
    "lib/features/tips/conflict_guide_screen.dart",
    "lib/common_widgets/common_widgets.dart",
    "lib/features/home/home_screen.dart",
    "lib/features/settings/settings_screen.dart",
    "lib/features/settings/partner_list_screen.dart",
    "lib/features/settings/profile_edit_screen.dart"
]

for filepath in files_to_update:
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            content = f.read()
        
        original_content = content
        
        for old, new in replacements:
            content = re.sub(old, new, content)
            
        # Manually handle Colors.white since it can be onPrimary or canvas
        # If it's a backgroundColor, we might want canvas. But usually it's text/icon on colored backgrounds.
        # Let's map Colors.white to AppTheme.onPrimary in most contexts, except mainBackgroundColor.
        content = content.replace('mainBackgroundColor: Colors.white', 'mainBackgroundColor: AppTheme.canvas')
        content = content.replace('backgroundColor: Colors.white', 'backgroundColor: AppTheme.canvas')
        content = re.sub(r'\bColors\.white\b', 'AppTheme.onPrimary', content)
        
        if content != original_content:
            # Add import if needed
            if "import 'package:lovefortune_app/core/theme/app_theme.dart';" not in content:
                content = "import 'package:lovefortune_app/core/theme/app_theme.dart';\n" + content
            
            with open(filepath, 'w') as f:
                f.write(content)
            print(f"Updated {filepath}")

