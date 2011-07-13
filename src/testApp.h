#pragma once

// usual openframeworks includes
#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

// import PGMidi files
#import "PGMidi.h"
#import "iOSVersionDetection.h"

class testApp : public ofxiPhoneApp{
	public:
		void	setup();
		void	update();
		void	draw();
		void	audioRequested( float * output, int bufferSize, int nChannels );
		void	touchDown(ofTouchEventArgs &touch);
		void	touchMoved(ofTouchEventArgs &touch);
		void	touchUp(ofTouchEventArgs &touch);
		void	touchDoubleTap(ofTouchEventArgs &touch);
		
		PGMidi	*midi;
		UInt8	noteValue[10];
	
		int notePositionX[10];
		int	notePositionY[10];
		bool noteDown[10];
		ofImage backing;
};

