# @logicwind/react-native-tvos-keyboard

`@logicwind/react-native-tvos-keyboard` is a React Native package for tvOS that displays a native Apple TV keyboard using UISearchController, with built-in support for voice typing and seamless integration with the tvOS focus engine.

## Installation

Using npm:

```sh md title="Terminal"
npm install @logicwind/react-native-tvos-keyboard
```

or using yarn:

```sh md title="Terminal"
yarn add @logicwind/react-native-tvos-keyboard
```

### Expo Setup

If you're working with this Expo project, make sure to run:

```sh md title="Terminal"
npx expo prebuild
```

### iOS Setup

After installation, make sure to install CocoaPods:

```sh md title="Terminal"
cd ios && pod install
```

### Android Setup

No additional setup is required.

## Usage

Import and use the `TvosKeyboardView` component.

```tsx md title="App.tsx"
import { TvosKeyboardView } from '@logicwind/react-native-tvos-keyboard';

<TvosKeyboardView
  style={styles.keyboard}
  onTextChange={(e) => console.log('Text: ', e.nativeEvent.text)}
  onFocus={(e) => {
    if (e.nativeEvent.focused !== undefined && e.nativeEvent.focused) {
      console.log('Focused: true');
    }
  }}
  onBlur={(e) => {
    if (e.nativeEvent.blurred !== undefined && e.nativeEvent.blurred) {
      console.log('Focused: false');
    }
  }}
/>;

const styles = StyleSheet.create({
  keyboard: {
    height: 200,
    width: '100%',
    backgroundColor: 'transparent',
  },
});
```

## Props

The `TvosKeyboardView` component displays the native Apple TV keyboard and supports the following props:

| Prop           | Type              | Description                                                                                     |
| -------------- | ----------------- | ----------------------------------------------------------------------------------------------- |
| `onTextChange` | `(event) => void` | Callback triggered when the text input changes. Access the text via `event.nativeEvent.text`.   |
| `onFocus`      | `(event) => void` | Called when the keyboard gains focus. Use `event.nativeEvent.focused` to check if it’s focused. |
| `onBlur`       | `(event) => void` | Called when the keyboard loses focus. Use `event.nativeEvent.blurred` to check if it’s blurred. |

> 💡 **Note:** The keyboard has a fixed size and layout. Please use the style shown in the example to ensure proper rendering and alignment.

```tsx md title="App.tsx"
const styles = StyleSheet.create({
  keyboard: {
    height: 200,
    width: '100%',
    backgroundColor: 'transparent',
  },
});
```

## react-native-tvos-keyboard is crafted mindfully at [Logicwind](https://www.logicwind.com?utm_source=github&utm_medium=github.com-logicwind&utm_campaign=react-native-tvos-keyboard)

We are a 130+ people company developing and designing multiplatform applications using the Lean & Agile methodology. To get more information on the solutions that would suit your needs, feel free to get in touch by [email](mailto:sales@logicwind.com) or through or [contact form](https://www.logicwind.com/contact-us?utm_source=github&utm_medium=github.com-logicwind&utm_campaign=react-native-tvos-keyboard)!

We will always answer you with pleasure 😁

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
