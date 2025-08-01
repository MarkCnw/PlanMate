# ShowProjectScreen Test Scenarios

This document describes manual testing scenarios for the ShowProjectScreen implementation.

## Test Scenarios

### 1. Basic Project Display
```dart
// Test with complete ProjectModel
final project = ProjectModel.create(
  title: 'Flutter Development',
  iconKey: 'computer',
  userId: 'user123',
  description: 'Building awesome Flutter applications',
);

ShowProjectScreen.fromProject(project: project)
```

**Expected Results:**
- Blue gradient background card
- Computer icon with colored background
- Title "Flutter Development" displayed prominently
- Description shown below title
- Task count shows "0 tasks"
- Creation date shows "Today"
- Two action buttons (View Tasks, Edit)

### 2. Project with Direct Parameters
```dart
ShowProjectScreen(
  title: 'Direct Parameters Test',
  iconPath: 'assets/icons/rocket.png',
  color: Colors.purple,
)
```

**Expected Results:**
- Blue gradient background (primary)
- Purple-colored elements (buttons, icon background)
- Rocket icon displayed
- No description or statistics section
- Only title and icon visible

### 3. Long Title and Description
```dart
final project = ProjectModel.create(
  title: 'This is a Very Long Project Title That Should Test Text Overflow',
  iconKey: 'book',
  userId: 'user123',
  description: 'This is a very long description that should test how the UI handles text overflow and wrapping in the description area of the project card.',
);
```

**Expected Results:**
- Title truncated with ellipsis if too long
- Description wrapped to 2 lines with ellipsis
- Layout remains intact

### 4. Missing Icon Asset
```dart
ShowProjectScreen(
  title: 'Missing Icon Test',
  iconPath: 'assets/icons/nonexistent.png',
  color: Colors.green,
)
```

**Expected Results:**
- Fallback folder icon displayed
- Green color applied to buttons and icon background
- No crash or error

### 5. Project Without Description
```dart
final project = ProjectModel.create(
  title: 'No Description Project',
  iconKey: 'chess',
  userId: 'user123',
  // No description provided
);
```

**Expected Results:**
- Only title displayed in text area
- No description text visible
- Statistics section still shows task count and date

## Visual Checklist

### Card Design
- [ ] Blue gradient background
- [ ] Rounded corners (20px)
- [ ] Shadow with blue tint
- [ ] Proper padding (24px)

### Icon Section
- [ ] Icon displays correctly
- [ ] Colored background container
- [ ] Rounded corners on icon container
- [ ] Border with opacity effect

### Typography
- [ ] Title: White, 24px, bold
- [ ] Description: White with 80% opacity, 14px
- [ ] Statistics: White, proper sizing
- [ ] Dates: Proper formatting

### Action Buttons
- [ ] "View Tasks" button: Filled with project color
- [ ] "Edit" button: Outlined with project color
- [ ] Proper spacing between buttons
- [ ] Correct padding (16px vertical)

### Interactions
- [ ] Buttons show snackbar when tapped
- [ ] Smooth animations
- [ ] Proper touch targets

### Responsive Design
- [ ] Works on different screen sizes
- [ ] Text doesn't overflow containers
- [ ] Proper spacing maintained
- [ ] Icons scale appropriately

## Color Integration Test

Test with different ProjectModel colors:
- Red (arrow icon)
- Blue (book icon)
- Purple (check icon)
- Pink (check&cal icon)
- Green (Chess icon)
- Yellow (computer icon)

Verify that each color appears in:
- Icon background
- Action buttons
- Outlined button border