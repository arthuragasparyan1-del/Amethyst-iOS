
#import "KeyboardInput.h"
#import "../utils.h"
#import <string.h>

#include "../glfw_keycodes.h"

extern bool isUseStackQueueCall;

static int keycodeTable[UIKeyboardHIDUsageKeyboardRightGUI + 1];

@implementation KeyboardInput

+ (void)initKeycodeTable {
    memset(keycodeTable, 0, sizeof(keycodeTable));

    // Letters A-Z
    for (int i = UIKeyboardHIDUsageKeyboardA;
         i <= UIKeyboardHIDUsageKeyboardZ; i++) {
        keycodeTable[i] = i - UIKeyboardHIDUsageKeyboardA + GLFW_KEY_A;
    }

    // Number keys
    keycodeTable[UIKeyboardHIDUsageKeyboard0] = GLFW_KEY_0;
    for (int i = UIKeyboardHIDUsageKeyboard1;
         i <= UIKeyboardHIDUsageKeyboard9; i++) {
        keycodeTable[i] = i - UIKeyboardHIDUsageKeyboard1 + GLFW_KEY_1;
    }

    // Arrow keys
    keycodeTable[UIKeyboardHIDUsageKeyboardUpArrow] = GLFW_KEY_DPAD_UP;
    keycodeTable[UIKeyboardHIDUsageKeyboardDownArrow] = GLFW_KEY_DPAD_DOWN;
    keycodeTable[UIKeyboardHIDUsageKeyboardLeftArrow] = GLFW_KEY_DPAD_LEFT;
    keycodeTable[UIKeyboardHIDUsageKeyboardRightArrow] = GLFW_KEY_DPAD_RIGHT;

    // Punctuation
    keycodeTable[UIKeyboardHIDUsageKeyboardComma] = GLFW_KEY_COMMA;
    keycodeTable[UIKeyboardHIDUsageKeyboardPeriod] = GLFW_KEY_PERIOD;
    keycodeTable[UIKeyboardHIDUsageKeyboardOpenBracket] = GLFW_KEY_LEFT_BRACKET;
    keycodeTable[UIKeyboardHIDUsageKeyboardCloseBracket] = GLFW_KEY_RIGHT_BRACKET;
    keycodeTable[UIKeyboardHIDUsageKeyboardSlash] = GLFW_KEY_SLASH;
    keycodeTable[UIKeyboardHIDUsageKeyboardBackslash] = GLFW_KEY_BACKSLASH;
    keycodeTable[UIKeyboardHIDUsageKeyboardHyphen] = GLFW_KEY_MINUS;
    keycodeTable[UIKeyboardHIDUsageKeyboardEqualSign] = GLFW_KEY_EQUAL;
    keycodeTable[UIKeyboardHIDUsageKeyboardSemicolon] = GLFW_KEY_SEMICOLON;
    keycodeTable[UIKeyboardHIDUsageKeyboardGraveAccentAndTilde] = GLFW_KEY_GRAVE_ACCENT;

    // Modifier keys
    keycodeTable[UIKeyboardHIDUsageKeyboardLeftAlt] = GLFW_KEY_LEFT_ALT;
    keycodeTable[UIKeyboardHIDUsageKeyboardRightAlt] = GLFW_KEY_RIGHT_ALT;
    keycodeTable[UIKeyboardHIDUsageKeyboardLeftControl] = GLFW_KEY_LEFT_CONTROL;
    keycodeTable[UIKeyboardHIDUsageKeyboardRightControl] = GLFW_KEY_RIGHT_CONTROL;
    keycodeTable[UIKeyboardHIDUsageKeyboardLeftShift] = GLFW_KEY_LEFT_SHIFT;
    keycodeTable[UIKeyboardHIDUsageKeyboardRightShift] = GLFW_KEY_RIGHT_SHIFT;

    // Navigation and editing
    keycodeTable[UIKeyboardHIDUsageKeyboardPageUp] = GLFW_KEY_PAGE_UP;
    keycodeTable[UIKeyboardHIDUsageKeyboardPageDown] = GLFW_KEY_PAGE_DOWN;
    keycodeTable[UIKeyboardHIDUsageKeyboardHome] = GLFW_KEY_HOME;
    keycodeTable[UIKeyboardHIDUsageKeyboardEscape] = GLFW_KEY_ESCAPE;
    keycodeTable[UIKeyboardHIDUsageKeyboardTab] = GLFW_KEY_TAB;
    keycodeTable[UIKeyboardHIDUsageKeyboardReturnOrEnter] = GLFW_KEY_ENTER;
    keycodeTable[UIKeyboardHIDUsageKeyboardSpacebar] = GLFW_KEY_SPACE;
    keycodeTable[UIKeyboardHIDUsageKeyboardDeleteOrBackspace] = GLFW_KEY_BACKSPACE;
    keycodeTable[UIKeyboardHIDUsageKeyboardDeleteForward] = GLFW_KEY_DELETE;

    // Lock keys
    keycodeTable[UIKeyboardHIDUsageKeyboardCapsLock] = GLFW_KEY_CAPS_LOCK;
    keycodeTable[UIKeyboardHIDUsageKeypadNumLock] = GLFW_KEY_NUM_LOCK;
    keycodeTable[UIKeyboardHIDUsageKeyboardScrollLock] = GLFW_KEY_SCROLL_LOCK;

    // Numeric keypad
    keycodeTable[UIKeyboardHIDUsageKeypadSlash] = GLFW_KEY_NUMPAD_DIVIDE;
    keycodeTable[UIKeyboardHIDUsageKeypadAsterisk] = GLFW_KEY_NUMPAD_MULTIPLY;
    keycodeTable[UIKeyboardHIDUsageKeypadHyphen] = GLFW_KEY_NUMPAD_SUBTRACT;
    keycodeTable[UIKeyboardHIDUsageKeypadPlus] = GLFW_KEY_NUMPAD_ADD;
    keycodeTable[UIKeyboardHIDUsageKeypadEnter] = GLFW_KEY_NUMPAD_ENTER;
    keycodeTable[UIKeyboardHIDUsageKeypadEqualSign] = GLFW_KEY_NUMPAD_EQUAL;
    keycodeTable[UIKeyboardHIDUsageKeypad0] = GLFW_KEY_NUMPAD_0;

    for (int i = UIKeyboardHIDUsageKeypad1;
         i <= UIKeyboardHIDUsageKeypad9; i++) {
        keycodeTable[i] = i - UIKeyboardHIDUsageKeypad1 + GLFW_KEY_NUMPAD_1;
    }

    // Function keys F1-F12
    for (int i = UIKeyboardHIDUsageKeyboardF1;
         i <= UIKeyboardHIDUsageKeyboardF12; i++) {
        keycodeTable[i] = i - UIKeyboardHIDUsageKeyboardF1 + GLFW_KEY_F1;
    }
}

+ (BOOL)sendKeyEvent:(UIKey *)key down:(BOOL)isDown {
    return [self sendKeyEvent:key down:isDown textFieldActive:NO];
}

+ (BOOL)sendKeyEvent:(UIKey *)key
                down:(BOOL)isDown
     textFieldActive:(BOOL)textFieldActive {

    // Let UIKit handle input while the chat field is active.
    // This avoids sending the same keystroke to UIKit and SDL.
    if (textFieldActive) {
        return NO;
    }

    if (key == nil) {
        return NO;
    }

    NSUInteger usage = (NSUInteger)key.keyCode;

    // Prevent an invalid keyboard usage from accessing outside the table.
    if (usage >= (sizeof(keycodeTable) / sizeof(keycodeTable[0]))) {
        return NO;
    }

    char modifiers = 0;
    UIKeyModifierFlags flags = key.modifierFlags;

    if (flags & UIKeyModifierAlphaShift) modifiers |= GLFW_MOD_CAPS_LOCK;
    if (flags & UIKeyModifierShift) modifiers |= GLFW_MOD_SHIFT;
    if (flags & UIKeyModifierAlternate) modifiers |= GLFW_MOD_ALT;
    if (flags & UIKeyModifierControl) modifiers |= GLFW_MOD_CONTROL;

    int keycode = keycodeTable[usage];

    if (keycode == 0) {
        return NO;
    }

    CallbackBridge_nativeSendKey(keycode, 0, isDown, modifiers);

    // Send character input through only one callback.
    if (isDown && key.characters.length > 0 &&
        key.characters.length < 11) {

        for (NSUInteger i = 0; i < key.characters.length; i++) {
            unichar character = [key.characters characterAtIndex:i];

            if (isUseStackQueueCall) {
                CallbackBridge_nativeSendCharMods((int)character, modifiers);
            } else {
                CallbackBridge_nativeSendChar((int)character);
            }
        }
    }

    return YES;
}

@end
