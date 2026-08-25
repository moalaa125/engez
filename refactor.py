import os
import shutil

lib_dir = r"c:\flutter\Engez\lib"

mappings = {
    "features/auth/presentation/screens/home_screen.dart": "features/home/presentation/screens/home_screen.dart",
    "features/auth/presentation/screens/add_edit_place_screen.dart": "features/place/presentation/screens/add_edit_place_screen.dart",
    "features/auth/presentation/screens/all_places.dart": "features/place/presentation/screens/all_places.dart",
    "features/auth/presentation/screens/place_details.dart": "features/place/presentation/screens/place_details.dart",
    "features/auth/presentation/screens/map_picker_screen.dart": "features/location/presentation/screens/map_picker_screen.dart",
    "features/auth/presentation/screens/manage_menu_screen.dart": "features/menu/presentation/screens/manage_menu_screen.dart",
    "features/auth/presentation/screens/offers_screen.dart": "features/offer/presentation/screens/offers_screen.dart",
    "features/auth/presentation/screens/owner_dashboard_screen.dart": "features/owner/presentation/screens/owner_dashboard_screen.dart",
    "features/auth/presentation/screens/profile.dart": "features/profile/presentation/screens/profile.dart",
    "features/auth/presentation/screens/loading_screen.dart": "features/onboarding/presentation/screens/loading_screen.dart"
}

# 1. Create dirs and move files
for old_rel, new_rel in mappings.items():
    old_abs = os.path.join(lib_dir, os.path.normpath(old_rel))
    new_abs = os.path.join(lib_dir, os.path.normpath(new_rel))
    
    if os.path.exists(old_abs):
        os.makedirs(os.path.dirname(new_abs), exist_ok=True)
        shutil.move(old_abs, new_abs)
        print(f"Moved {old_rel} -> {new_rel}")
    else:
        print(f"Warning: {old_rel} not found!")

# 2. Update import statements
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            for old_rel, new_rel in mappings.items():
                old_import = f"package:engez/{old_rel.replace('\\\\', '/')}"
                new_import = f"package:engez/{new_rel.replace('\\\\', '/')}"
                content = content.replace(old_import, new_import)
                
                # Also handle relative imports if any existed in the auth folder itself
                # E.g. import 'home_screen.dart'; -> this is tricky because we moved it. 
                # Let dart analyze handle relative imports later, we'll just do absolute.
                
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated imports in {os.path.relpath(file_path, lib_dir)}")

print("Done.")
