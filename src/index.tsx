import React, { forwardRef } from 'react';
import {
  requireNativeComponent,
  UIManager,
  Platform,
  type ViewStyle,
  type NativeSyntheticEvent,
  type ViewProps,
} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-tvos-keyboard' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

type OnFocusEvent = NativeSyntheticEvent<{
  focused: boolean;
}>;

type OnBlurEvent = NativeSyntheticEvent<{
  blurred: boolean;
}>;

type OnTextChangeEvent = NativeSyntheticEvent<{
  text: string;
}>;

type TvosKeyboardProps = ViewProps & {
  onTextChange?: (event: OnTextChangeEvent) => void;
  onFocus?: (event: OnFocusEvent) => void;
  onBlur?: (event: OnBlurEvent) => void;
  style?: ViewStyle;
};

const ComponentName = 'TvosKeyboardView';

let NativeKeyboardComponent: React.ComponentType<TvosKeyboardProps> | null =
  null;

if (Platform.OS === 'ios' && Platform.isTV) {
  if (UIManager.getViewManagerConfig(ComponentName) != null) {
    NativeKeyboardComponent =
      requireNativeComponent<TvosKeyboardProps>(ComponentName);
  } else {
    throw new Error(LINKING_ERROR);
  }
}

export const TvosKeyboardView = forwardRef<any, TvosKeyboardProps>((props) => {
  if (
    Platform.OS !== 'ios' ||
    !Platform.isTV ||
    NativeKeyboardComponent === null
  ) {
    return null;
  }
  return <NativeKeyboardComponent {...props} />;
});
