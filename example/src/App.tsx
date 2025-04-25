import { useState } from 'react';
import { View, StyleSheet, Text, TouchableOpacity } from 'react-native';
import { TvosKeyboardView } from 'react-native-tvos-keyboard';

export default function App() {
  const [text, setText] = useState('');
  const [focused, setFocused] = useState(false);

  return (
    <View style={styles.container}>
      <Text style={styles.text}>Text: {text}</Text>
      <Text style={styles.text}>isFocused: {focused ? 'true' : 'false'}</Text>
      {/* Top Button */}
      <TouchableOpacity
        style={styles.button}
        activeOpacity={0.8}
        onPress={() => console.log('Top Button Pressed')}
        hasTVPreferredFocus={true}
        focusable={true}
      >
        <Text style={styles.buttonText}>↑ Top Button</Text>
      </TouchableOpacity>

      {/* TV Keyboard */}
      <TvosKeyboardView
        style={styles.keyboard}
        onTextChange={(e) => setText(e.nativeEvent.text)}
        onFocus={(e) => {
          if (e.nativeEvent.focused !== undefined && e.nativeEvent.focused) {
            setFocused(true);
          }
        }}
        onBlur={(e) => {
          if (e.nativeEvent.blurred !== undefined && e.nativeEvent.blurred) {
            setFocused(false);
          }
        }}
      />

      {/* Bottom Button */}
      <TouchableOpacity
        style={styles.button}
        activeOpacity={0.8}
        onPress={() => console.log('Bottom Button Pressed')}
        focusable={true}
      >
        <Text style={styles.buttonText}>↓ Bottom Button</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#111',
  },
  text: {
    fontSize: 22,
    color: '#fff',
    marginBottom: 20,
  },
  keyboard: {
    height: 200,
    width: '100%',
    backgroundColor: 'transparent',
  },
  button: {
    marginVertical: 10,
    paddingVertical: 20,
    paddingHorizontal: 50,
    borderRadius: 12,
    backgroundColor: '#1e90ff',
  },
  buttonText: {
    fontSize: 22,
    color: '#fff',
  },
});
