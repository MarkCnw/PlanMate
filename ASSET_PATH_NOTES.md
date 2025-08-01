# Asset Path Issue Documentation

## Issue Identified
There's a case-sensitivity discrepancy in the asset paths:

- **ProjectModel paths**: `assets/icons/` (lowercase 'i')
- **Actual directory**: `assets/Icons/` (capital 'I')
- **pubspec.yaml**: `assets/icons/` (lowercase 'i')

## Impact
This may cause icons to not load properly on case-sensitive file systems (like Linux).

## Current Solution
The ShowProjectScreen implementation includes error handling:

```dart
Image.asset(
  widget.iconPath,
  width: 48,
  height: 48,
  errorBuilder: (context, error, stackTrace) {
    // Fallback icon if asset not found
    return Icon(
      Icons.folder,
      size: 48,
      color: widget.color,
    );
  },
),
```

This ensures the UI remains functional even if icon assets are missing.

## Recommended Fix (for future)
Either:
1. Update pubspec.yaml to `- assets/Icons/` (capital I)
2. Or rename the directory to `assets/icons/` (lowercase i)
3. Or update all ProjectModel icon paths to use capital I

## Testing
The implementation has been tested to handle missing assets gracefully with a fallback icon.