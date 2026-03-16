## 0.1.4

- Added `onKeyboardLayoutChange` prop — fires when the keyboard switches between linear and grid layouts, providing `height` and `isGrid` via `event.nativeEvent`.
- Added `gridSeparatorColor` prop to customize the separator color in grid layout.
- Added `linearSeparatorColor` prop to customize the separator color in linear layout.
- Keyboard height is now dynamic — use `onKeyboardLayoutChange` to update the component's height instead of a static value.

## 0.1.3

- Disable RN select gesture intercept during UISearchBar editing

## 0.1.2

**Breaking Changes:**

- Updated name to @logicwind/react-native-tvos-keyboard

## 0.1.1

- Updated UTM source in README.md file

## 0.1.0

- Initial release of `TvosKeyboardView` component.
- Native Apple TV keyboard using `UISearchController`.
- Support for voice typing.
- `onTextChange`, `onFocus`, and `onBlur` props.
