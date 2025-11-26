// --- Pin Setup ---
const int ledPins[8] = {2,3,4,5,6,7,8,9};  
const int buttonPin = 10;

unsigned char mode = 0;
#define TOTAL_MODES 4  // Now 4 modes after removing binary counter (modes 0..3)

// ------------------------
// Delay functions
// ------------------------
void delay_short() {
  delay(150);   // Slower for Knight Rider
}

void delay_blink() {
  delay(500);   // Christmas-style blinking
}

void delay_chase() {
  delay(100);   // Chase light speed
}

// ------------------------
// Button check
// ------------------------
bool check_button() {
  if (digitalRead(buttonPin) == LOW) {
    delay(30); // debounce
    if (digitalRead(buttonPin) == LOW) {

      mode++;
      if (mode >= TOTAL_MODES) mode = 0;

      // Wait for release
      while (digitalRead(buttonPin) == LOW);
      return true;
    }
  }
  return false;
}

// ------------------------
// Write to "P1" replacement
// ------------------------
void writePort(unsigned char value) {
  for (int i = 0; i < 8; i++) {
    int bitVal = (value >> i) & 0x01;
    digitalWrite(ledPins[i], bitVal);
  }
}

// ------------------------
// Arduino Setup
// ------------------------
void setup() {
  for (int i = 0; i < 8; i++) {
    pinMode(ledPins[i], OUTPUT);
  }
  pinMode(buttonPin, INPUT_PULLUP); // Active LOW like AT89S52
}

// ------------------------
// MAIN LOOP
// ------------------------
void loop() {
  switch (mode)
  {
    // --- MODE 0: Knight Rider ---
    case 0:
      for (int i = 0; i < 8; i++) {
        writePort(1 << i);
        delay_short();
        if (check_button()) return;
      }
      for (int i = 6; i >= 1; i--) {
        writePort(1 << i);
        delay_short();
        if (check_button()) return;
      }
      break;

    // --- MODE 1: Chase Light (accumulating) ---
    case 1:
      {
        unsigned char pattern = 0;
        for (int i = 0; i < 8; i++) {
          pattern |= (1 << i);  // Add each LED, keeping previous ones on
          writePort(pattern);
          delay_chase();
          if (check_button()) return;
        }
        delay(300);  // Pause when all are on
        writePort(0x00);  // Clear all
        delay(300);
      }
      break;

    // --- MODE 2: Blink All LEDs ---
    case 2:
      writePort(0xFF); // All ON
      delay_blink();
      if (check_button()) return;

      writePort(0x00); // All OFF
      delay_blink();
      if (check_button()) return;
      break;

    // (Mode 3 removed)

    // --- MODE 3: Odd-Even Lights ---
    case 3:
      // All odd pins (1,3,5,7) ON
      writePort(0xAA); // Binary: 10101010
      delay_blink();
      if (check_button()) return;
      
      // All even pins (0,2,4,6) ON
      writePort(0x55); // Binary: 01010101
      delay_blink();
      if (check_button()) return;
      break;
  }
}
