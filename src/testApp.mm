#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
	
	// check that the device we're loading the app onto actually supports CoreMIDI
	IF_IOS_HAS_COREMIDI
    (
		midi = [[PGMidi alloc] init];
		[midi enableNetwork:YES];
	)
	
	// set up all the usual openframeworks-type stuff!
	ofRegisterTouchEvents(this);
	ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	ofBackground(255,255,255);
	backing.loadImage("backing.png");
}

//--------------------------------------------------------------
void testApp::update(){
	
}

//--------------------------------------------------------------
void testApp::draw(){
	
	ofSetColor(255, 255, 255);
	backing.draw(0, 0);
	
	for (int linePos = 0; linePos < 36; linePos++) {
		ofSetColor(224, 224, 224);
		ofLine(linePos*(1024.0f/36.0f), 0, linePos*(1024.0f/36.0f), 768);
	}

	// draw some circles on the screen corresponding with the position
	// of the users fingers on the screen...
	for (int notePos = 0; notePos < 10; notePos++) {
		ofSetColor(255, (notePos*(255.0f/10.0f)), 0);
		if (noteDown[notePos]) {
			ofCircle(notePositionX[notePos], notePositionY[notePos], 75);
		}
	}
}

//--------------------------------------------------------------
void testApp::audioRequested(float * output, int bufferSize, int nChannels){
		
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
	
	// record position of touch
	notePositionX[touch.id] = touch.x;
	notePositionY[touch.id] = touch.y;
	
	// register that the finger is 'down'
	noteDown[touch.id] = true;
	
	// calculate a note value to send out via MIDI based on the position of the finger across
	// the screen of the iPad.  Here, we have 3 octaves (including semitones) ranging from note 46 thru 82
	// i.e. the middle 36 notes of the 128 note range available to MIDI :)
	noteValue[touch.id] = (36.0f*(touch.x/1024.0f))+46.0f;
	
	// put all the data together and send...
	const UInt8 note      = noteValue[touch.id];
	const UInt8 noteOn[]  = { 0x90, note, 127 };
	[midi sendBytes:noteOn size:sizeof(noteOn)];
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
	
	// update position of touch
	notePositionX[touch.id] = touch.x;
	notePositionY[touch.id] = touch.y;
	
	// calculate the midi note value to check against the current value
	const UInt8 tempNote = (36.0f*(touch.x/1024.0f))+46.0f;
	
	// if the note value we've just calculated doens't match the current value then this means
	// the finger has moved sufficiently to be playing a new note, so change and send MIDI!
	// (doing it like this stops the same note from being sent multiple times which causes
	//  a nasty stuttering effect, mind you, you might want that hehe...)
	if (tempNote!=noteValue[touch.id]) {
		
		// turn off the currently playing note
		const UInt8 note      = noteValue[touch.id];
		const UInt8 noteOff[] = { 0x80, note, 0   };
		[midi sendBytes:noteOff size:sizeof(noteOff)];
		
		// update the note value to the new one!
		noteValue[touch.id] = tempNote;
		const UInt8 note2      = noteValue[touch.id];
		const UInt8 noteOn[]  = { 0x90, note2, 127 };
		[midi sendBytes:noteOn size:sizeof(noteOn)];
	}
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
	
	// register that the finger is 'up'
	noteDown[touch.id] = false;
	
	// prepare data to send a note off signal for the particular note
	const UInt8 note      = noteValue[touch.id];
	const UInt8 noteOff[] = { 0x80, note, 0   };
	
	// put all the data together and send...
	[midi sendBytes:noteOff size:sizeof(noteOff)];
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){

}